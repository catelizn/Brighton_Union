local QBCore = exports['qb-core']:GetCoreObject()

local questName = Config.Quest.name
local stages = Config.Quest.stages

-- Кэш прогресса в памяти: citizenid -> { stage = number, completed = boolean }
-- Пишем в БД только при переходе на новый шаг, читаем один раз при входе игрока.
local progressCache = {}

-- Заработано на работах с момента входа: citizenid -> сумма (для этапа «заработай $1000»)
local earningsCache = {}

local function cacheEntry(cid)
    local entry = progressCache[cid]
    if not entry then
        entry = { stage = 0, completed = false, isNew = true }
        progressCache[cid] = entry
    end
    return entry
end

local function saveProgress(cid, entry)
    MySQL.insert('INSERT INTO bu_quest_progress (citizenid, quest, stage, completed) VALUES (?, ?, ?, ?) ON DUPLICATE KEY UPDATE stage = VALUES(stage), completed = VALUES(completed)', {
        cid, questName, entry.stage, entry.completed and 1 or 0
    })
end

local function loadProgress(cid)
    MySQL.query('SELECT stage, completed FROM bu_quest_progress WHERE citizenid = ? AND quest = ? LIMIT 1', { cid, questName }, function(result)
        local entry = cacheEntry(cid)
        if result and result[1] then
            entry.stage = result[1].stage
            entry.completed = result[1].completed == 1
            entry.isNew = false
        end
    end)
end

-- Проверка условия шага. Вся валидация на сервере.
local function checkRequirement(Player, requirement)
    if not requirement or requirement == 'none' then return true end

    local name, arg = requirement:match('^(.-):(.*)$')
    if not name then name = requirement end

    if name == 'item' then
        return Player.Functions.GetItemByName(arg) ~= nil
    end

    if name == 'job' then
        return Player.PlayerData.job.name ~= 'unemployed'
    end

    if name == 'bank' then
        local result = MySQL.query.await('SELECT 1 FROM bu_bank_accounts WHERE citizenid = ? LIMIT 1', { Player.PlayerData.citizenid })
        return result and result[1] ~= nil
    end

    if name == 'earn' then
        local target = tonumber(arg) or 0
        return (earningsCache[Player.PlayerData.citizenid] or 0) >= target
    end

    if name == 'vehicle' then
        local result = MySQL.query.await('SELECT 1 FROM player_vehicles WHERE citizenid = ? AND state = 1 LIMIT 1', { Player.PlayerData.citizenid })
        return result and result[1] ~= nil
    end

    if name == 'rental' then
        local result = MySQL.query.await('SELECT 1 FROM bu_rental_log WHERE citizenid = ? LIMIT 1', { Player.PlayerData.citizenid })
        return result and result[1] ~= nil
    end

    return false
end

-- Создание таблицы при старте ресурса, если её ещё нет
CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_quest_progress` (
            `citizenid` varchar(50) NOT NULL,
            `quest` varchar(32) NOT NULL,
            `stage` int(11) NOT NULL DEFAULT 0,
            `completed` tinyint(1) NOT NULL DEFAULT 0,
            `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
            PRIMARY KEY (`citizenid`, `quest`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

RegisterNetEvent('QBCore:Server:OnPlayerLoaded', function(Player)
    earningsCache[Player.PlayerData.citizenid] = 0
    loadProgress(Player.PlayerData.citizenid)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(Player)
    progressCache[Player.PlayerData.citizenid] = nil
    earningsCache[Player.PlayerData.citizenid] = nil
end)

-- Заработок на работах (бу-jobs): считаем для этапа «заработай $1000»
RegisterNetEvent('bu-tutorial:server:jobEarned', function(cid, amount)
    if not cid or not amount then return end
    earningsCache[cid] = (earningsCache[cid] or 0) + amount
end)

QBCore.Functions.CreateCallback('bu-tutorial:server:getState', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local entry = cacheEntry(Player.PlayerData.citizenid)
    cb({ stage = entry.stage, completed = entry.completed, isNew = entry.isNew, earned = earningsCache[Player.PlayerData.citizenid] or 0 })
end)

RegisterNetEvent('bu-tutorial:server:advance', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local cid = Player.PlayerData.citizenid
    local entry = cacheEntry(cid)

    if entry.completed then return end

    local nextStage = entry.stage + 1
    local stageData = stages[nextStage]
    if not stageData then return end

    if not checkRequirement(Player, stageData.requirement) then
        TriggerClientEvent('bu-tutorial:client:notify', src, stageData.hint or 'Условие ещё не выполнено. Загляни в описание шага.')
        return
    end

    entry.stage = nextStage
    entry.completed = nextStage == #stages
    saveProgress(cid, entry)

    if stageData.reward and stageData.reward > 0 then
        Player.Functions.AddMoney('bank', stageData.reward, 'tutorial-stage-' .. nextStage)
    end

    TriggerClientEvent('bu-tutorial:client:update', src, entry.stage, entry.completed)
end)
