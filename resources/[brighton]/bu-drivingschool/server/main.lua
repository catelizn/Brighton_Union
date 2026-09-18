local QBCore = exports['qb-core']:GetCoreObject()

-- Активные экзамены: citizenid -> { category, entity, model, school, bucket }
local activeExams = {}

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_driving_theory` (
            `citizenid` varchar(50) NOT NULL,
            `passed` tinyint(1) NOT NULL DEFAULT 0,
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

local function cleanExam(cid)
    local exam = activeExams[cid]
    if not exam then return end
    if DoesEntityExist(exam.entity) then
        DeleteEntity(exam.entity)
    end
    activeExams[cid] = nil
end

local function sendBack(src, school)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    SetPlayerRoutingBucket(src, 0)
    local returnPos = Config.Schools[school].returnPos
    local target = vec3(returnPos.x, returnPos.y, returnPos.z)
    local ped = GetPlayerPed(src)
    SetEntityCoords(ped, target.x, target.y, target.z)
    SetEntityHeading(ped, returnPos.w)
end

local function theoryPassed(cid)
    local result = MySQL.query.await('SELECT passed FROM bu_driving_theory WHERE citizenid = ? LIMIT 1', { cid })
    return result and result[1] and result[1].passed == 1
end

local function getOwnedCategories(Player)
    local owned = {}
    local license = Player.Functions.GetItemByName('driver_license')
    if license and license.info and license.info.type then
        for cat in tostring(license.info.type):gmatch('[^,]+') do
            owned[cat] = true
        end
    end
    return owned
end

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    local exam = activeExams[cid]
    if exam then
        SetPlayerRoutingBucket(src, 0)
        cleanExam(cid)
    end
end)

QBCore.Functions.CreateCallback('bu-drivingschool:server:getCategories', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local owned = getOwnedCategories(Player)
    local list = {}
    for key, cat in pairs(Config.Categories) do
        list[#list + 1] = {
            key = key,
            label = cat.label,
            price = cat.price,
            school = cat.school,
            theory = cat.theory,
            owned = owned[key] == true
        }
    end
    table.sort(list, function(a, b) return a.price < b.price end)

    cb({
        categories = list,
        theory = Config.Theory,
        theoryPassed = theoryPassed(Player.PlayerData.citizenid),
        active = activeExams[Player.PlayerData.citizenid] ~= nil
    })
end)

-- Теория: проверяется на сервере, для зачёта нужно Config.TheoryPassCount верных ответов
RegisterNetEvent('bu-drivingschool:server:submitTheory', function(answers)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    if theoryPassed(cid) then
        TriggerClientEvent('bu-drivingschool:client:notify', src, 'Теория уже сдана.', 'error')
        return
    end

    local schoolPos = Config.Schools.ground.coords
    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - vec3(schoolPos.x, schoolPos.y, schoolPos.z)) > 40.0 then
        TriggerClientEvent('bu-drivingschool:client:notify', src, 'Подойди к автошколе, чтобы сдать теорию.', 'error')
        return
    end

    local correct = 0
    for i = 1, #Config.Theory do
        if tonumber(answers[i]) == Config.Theory[i].answer then
            correct = correct + 1
        end
    end

    if correct < Config.TheoryPassCount then
        TriggerClientEvent('bu-drivingschool:client:notify', src, string.format('Теория не сдана: %d из %d. Попробуй ещё раз.', correct, #Config.Theory), 'error')
        return
    end

    MySQL.insert('INSERT INTO bu_driving_theory (citizenid, passed) VALUES (?, 1) ON DUPLICATE KEY UPDATE passed = VALUES(passed)', { cid })
    TriggerClientEvent('bu-drivingschool:client:notify', src, 'Теория сдана! Теперь можно идти на практический экзамен.', 'success')
    TriggerClientEvent('bu-drivingschool:client:theoryPassed', src)
end)

RegisterNetEvent('bu-drivingschool:server:startExam', function(category, payment)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local cat = Config.Categories[category]
    if not cat then return end

    if activeExams[cid] then
        TriggerClientEvent('bu-drivingschool:client:notify', src, 'Экзамен уже идёт. Заверши его или отмени.', 'error')
        return
    end

    if getOwnedCategories(Player)[category] then
        TriggerClientEvent('bu-drivingschool:client:notify', src, 'Эта категория у тебя уже открыта.', 'error')
        return
    end

    if cat.theory and not theoryPassed(cid) then
        TriggerClientEvent('bu-drivingschool:client:notify', src, 'Сначала сдай теоретический экзамен в автошколе.', 'error')
        return
    end

    local moneyType = payment == 'cash' and 'cash' or 'bank'
    local balance = Player.PlayerData.money[moneyType]
    if not balance or balance < cat.price then
        TriggerClientEvent('bu-drivingschool:client:notify', src, 'Недостаточно средств.', 'error')
        return
    end

    Player.Functions.RemoveMoney(moneyType, cat.price, 'drivingschool-' .. category)

    local school = Config.Schools[cat.school]
    local spawn = school.spawn
    local spawnPos = vec3(spawn.x, spawn.y, spawn.z)

    -- Личный мир: игрок сдаёт практику без других игроков
    local bucket = Config.ExamBucketBase + src
    SetPlayerRoutingBucket(src, bucket)

    local entity = CreateVehicle(joaat(cat.vehicle), spawnPos.x, spawnPos.y, spawnPos.z, spawn.w, true, false)
    while not DoesEntityExist(entity) do Wait(0) end

    SetVehicleNumberPlateText(entity, 'EXAM' .. math.random(100, 999))
    SetVehicleDirtLevel(entity, 0.0)
    SetEntityRoutingBucket(entity, bucket)

    activeExams[cid] = {
        category = category,
        entity = entity,
        model = cat.vehicle,
        school = cat.school,
        bucket = bucket
    }

    exports['qb-vehiclekeys']:GiveKeys(GetVehicleNumberPlateText(entity), cid)

    local ped = GetPlayerPed(src)
    SetEntityCoords(ped, spawnPos.x, spawnPos.y, spawnPos.z)
    SetEntityHeading(ped, spawn.w)
    TaskWarpPedIntoVehicle(ped, entity, -1)

    local netId = NetworkGetNetworkIdFromEntity(entity)

    TriggerClientEvent('bu-drivingschool:client:notify', src, 'Экзамен начался. Ты в отдельном мире — по завершении вернёшься в город.', 'inform')
    TriggerClientEvent('bu-drivingschool:client:examStarted', src, category, cat.school, bucket, netId)
end)

RegisterNetEvent('bu-drivingschool:server:finishExam', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local exam = activeExams[cid]
    if not exam then return end

    local cat = Config.Categories[exam.category]
    local ped = GetPlayerPed(src)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle ~= exam.entity then
        TriggerClientEvent('bu-drivingschool:client:notify', src, 'Экзамен не засчитан: ты не в экзаменационной машине.', 'error')
        return
    end

    local route = Config.Routes[exam.school]
    local last = route[#route]
    local position = GetEntityCoords(vehicle)
    local distance

    if exam.school == 'ground' then
        local dx = position.x - last.x
        local dy = position.y - last.y
        distance = math.sqrt(dx * dx + dy * dy)
    else
        distance = #(position - vec3(last.x, last.y, last.z))
    end

    if distance > Config.CheckpointRadius[exam.school] then
        TriggerClientEvent('bu-drivingschool:client:notify', src, 'Ты не у финишного чекпоинта.', 'error')
        return
    end

    local categories = getOwnedCategories(Player)
    categories[exam.category] = true

    local order = { 'A', 'B', 'C', 'LV', 'LS' }
    local list = {}
    for i = 1, #order do
        if categories[order[i]] then list[#list + 1] = order[i] end
    end
    local newType = table.concat(list, ',')

    local license = Player.Functions.GetItemByName('driver_license')
    if license then
        Player.Functions.RemoveItem('driver_license', 1, false, license.slot)
    end
    Player.Functions.AddItem('driver_license', 1, false, { type = newType })

    cleanExam(cid)
    sendBack(src, exam.school)
    TriggerClientEvent('bu-drivingschool:client:notify', src, 'Экзамен сдан! Категория ' .. exam.category .. ' открыта.', 'success')
    TriggerClientEvent('bu-drivingschool:client:examFinished', src)
end)

RegisterNetEvent('bu-drivingschool:server:cancelExam', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local exam = activeExams[Player.PlayerData.citizenid]
    if not exam then return end

    cleanExam(Player.PlayerData.citizenid)
    sendBack(src, exam.school)
    TriggerClientEvent('bu-drivingschool:client:notify', src, 'Экзамен отменён.', 'error')
    TriggerClientEvent('bu-drivingschool:client:examFinished', src)
end)

