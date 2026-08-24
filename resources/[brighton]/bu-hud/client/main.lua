local QBCore = exports['qb-core']:GetCoreObject()

local shown = false
local lastSnapshot = ''
local questState = { stage = 0, completed = false, total = 8 }

local function fetchQuest()
    QBCore.Functions.TriggerCallback('bu-tutorial:server:getState', function(state)
        if not state then return end
        questState.stage = state.stage
        questState.completed = state.completed
    end)
end

local function getLocation()
    local position = GetEntityCoords(PlayerPedId())
    local streetHash, crossingHash = GetStreetNameAtCoord(position.x, position.y, position.z)
    local street = streetHash ~= 0 and GetStreetNameFromHashKey(streetHash) or ''
    local crossing = crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or ''
    if street == '' then return 'Лос-Сантос' end
    return crossing ~= '' and (street .. ' / ' .. crossing) or street
end

local function colorFor(percent)
    if percent > 60 then return ''
    elseif percent > 30 then return 'warning'
    end
    return 'critical'
end

local function tick()
    local playerPed = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local metadata = playerData.metadata or {}

    local health = math.max(0, GetEntityHealth(playerPed) - 100)
    local armor = GetPedArmour(playerPed)
    local hunger = metadata.hunger or 100
    local thirst = metadata.thirst or 100
    local stress = metadata.stress or 0

    local snapshot = {
        health = health,
        armor = armor,
        hunger = hunger,
        thirst = thirst,
        stress = stress,
        cash = playerData.money.cash or 0,
        bank = playerData.money.bank or 0,
        location = getLocation(),
        online = GetNumPlayerIndices(),
        quest = questState.completed and '' or ('Путь новичка: ' .. questState.stage .. '/' .. questState.total)
    }

    SendNUIMessage({ type = 'bu:hud:update', data = snapshot })
end

CreateThread(function()
    while true do
        Wait(1500)
        if not LocalPlayer.state.isLoggedIn then
            if shown then
                SendNUIMessage({ type = 'bu:hud:hide' })
                shown = false
            end
        else
            if not shown then
                SendNUIMessage({ type = 'bu:hud:show' })
                shown = true
                fetchQuest()
            end
            tick()
        end
    end
end)

-- Периодически обновляем прогресс «Пути новичка»
CreateThread(function()
    while true do
        Wait(15000)
        if LocalPlayer.state.isLoggedIn and not questState.completed then
            fetchQuest()
        end
    end
end)
