local QBCore = exports['qb-core']:GetCoreObject()

local spawnedSchools = {}
local examActive = false
local examSchool = 'ground'
local checkpoints = {}
local currentCheckpoint = 1
local examBlip = nil

local function snapZ(x, y, z)
    local found, groundZ = GetGroundZFor_3dCoord(x, y, 300.0, false)
    return found and groundZ or z
end

local function openMenu()
    QBCore.Functions.TriggerCallback('bu-drivingschool:server:getCategories', function(data)
        if not data then return end
        SendNUIMessage({ type = 'bu:exam:open', data = data })
        SetNuiFocus(true, true)
    end)
end

local function spawnSchools()
    for schoolName, school in pairs(Config.Schools) do
        if spawnedSchools[schoolName] then return end

        local model = school.model
        local coords = school.coords
        local z = snapZ(coords.x, coords.y, coords.z)

        RequestModel(model)
        while not HasModelLoaded(model) do Wait(0) end

        local ped = CreatePed(0, model, coords.x, coords.y, z, coords.w, false, false)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        TaskStartScenarioInPlace(ped, school.scenario, 0, true)

        local blip = AddBlipForCoord(coords.x, coords.y, z)
        SetBlipSprite(blip, school.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, school.blip.scale)
        SetBlipColour(blip, school.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(school.blip.name)
        EndTextCommandSetBlipName(blip)

        exports['qb-target']:AddTargetEntity(ped, {
            options = {
                {
                    icon = 'fas fa-graduation-cap',
                    label = school.label,
                    action = function()
                        openMenu()
                    end
                }
            },
            distance = 2.5
        })

        spawnedSchools[schoolName] = true
    end
end

-- Белые учебные машины на парковке автошколы
local function spawnSchoolCars()
    local school = Config.Schools.ground
    local base = school.coords
    local baseZ = snapZ(base.x, base.y, base.z)

    for i = 1, #Config.SchoolCars.models do
        local offset = Config.SchoolCars.offsets[i] or vec3(0.0, 0.0, 0.0)
        local x = base.x + offset.x
        local y = base.y + offset.y
        local z = snapZ(x, y, baseZ)

        RequestModel(Config.SchoolCars.models[i])
        while not HasModelLoaded(Config.SchoolCars.models[i]) do Wait(0) end

        local vehicle = CreateVehicle(joaat(Config.SchoolCars.models[i]), x, y, z, base.w, false, false)
        SetVehicleColours(vehicle, 111, 111)
        SetVehicleEngineOn(vehicle, false, false, true)
        FreezeEntityPosition(vehicle, true)
        SetVehicleDoorsLocked(vehicle, 2)
    end
end

local function clearExamBlip()
    if examBlip then
        RemoveBlip(examBlip)
        examBlip = nil
    end
end

local function computeRoute(school)
    local route = Config.Routes[school]
    local points = {}
    for i = 1, #route do
        local point = route[i]
        if school == 'ground' then
            points[i] = vector3(point.x, point.y, snapZ(point.x, point.y, point.z) + 1.0)
        else
            points[i] = vector3(point.x, point.y, point.z)
        end
    end
    return points
end

local function pointBlip(point)
    examBlip = AddBlipForCoord(point.x, point.y, point.z)
    SetBlipRoute(examBlip, true)
    SetBlipRouteColour(examBlip, 2)
end

local function examLoop()
    local startTime = GetGameTimer()
    while examActive do
        Wait(0)

        if GetGameTimer() - startTime > Config.ExamTimeLimit * 1000 then
            examActive = false
            clearExamBlip()
            TriggerServerEvent('bu-drivingschool:server:cancelExam')
            break
        end

        local playerPed = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle == 0 then
            examActive = false
            clearExamBlip()
            TriggerServerEvent('bu-drivingschool:server:cancelExam')
            break
        end

        local position = GetEntityCoords(vehicle)
        local target = checkpoints[currentCheckpoint]
        if #(position - target) < Config.CheckpointRadius[examSchool] then
            currentCheckpoint = currentCheckpoint + 1
            if currentCheckpoint > #checkpoints then
                examActive = false
                clearExamBlip()
                TriggerServerEvent('bu-drivingschool:server:finishExam')
                break
            end
            clearExamBlip()
            pointBlip(checkpoints[currentCheckpoint])
            SendNUIMessage({
                type = 'bu:exam:progress',
                data = { current = currentCheckpoint - 1, total = #checkpoints }
            })
        end
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnSchools()
    spawnSchoolCars()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    spawnSchools()
    spawnSchoolCars()
end)

RegisterNetEvent('bu-drivingschool:client:examStarted', function(category, school, bucket, netId)
    examSchool = school
    checkpoints = computeRoute(school)
    currentCheckpoint = 1
    examActive = true

    if netId then
        local entity = NetworkGetEntityFromNetworkId(netId)
        if DoesEntityExist(entity) then
            SetEntityRoutingBucket(entity, bucket)
        end
    end

    pointBlip(checkpoints[1])
    SendNUIMessage({
        type = 'bu:exam:started',
        data = { category = category, total = #checkpoints }
    })
    CreateThread(examLoop)
end)

RegisterNetEvent('bu-drivingschool:client:examFinished', function()
    examActive = false
    clearExamBlip()
    SendNUIMessage({ type = 'bu:exam:finished' })
    SetNuiFocus(false, false)
end)

RegisterNetEvent('bu-drivingschool:client:theoryPassed', function()
    SendNUIMessage({ type = 'bu:exam:theoryPassed' })
end)

RegisterNetEvent('bu-drivingschool:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

RegisterNUICallback('start', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('bu-drivingschool:server:startExam', data.category, data.payment)
    cb('ok')
end)

RegisterNUICallback('theory', function(data, cb)
    TriggerServerEvent('bu-drivingschool:server:submitTheory', data.answers or {})
    cb('ok')
end)

RegisterNUICallback('cancel', function(_, cb)
    TriggerServerEvent('bu-drivingschool:server:cancelExam')
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

