local QBCore = exports['qb-core']:GetCoreObject()

local zonePoints = {}
local zoneBlips = {}

local function clearZones()
    for _, id in pairs(zonePoints) do
        exports['bu-interact']:removePoint(id)
    end
    zonePoints = {}
    for _, blip in pairs(zoneBlips) do
        RemoveBlip(blip)
    end
    zoneBlips = {}
end

-- NPC банд на районах: вступление через [E]
local joinNpcSetupDone = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if joinNpcSetupDone then return end
    joinNpcSetupDone = true

    for gangKey, gang in pairs(Config.Gangs) do
        exports['bu-interact']:spawnPed(gang.model, gang.coords, {
            label = gang.joinLabel,
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
            action = function()
                TriggerServerEvent('bu-gangs:server:join', gangKey)
            end
        })
    end
end)

-- Квадраты гетто видит только участник банд: сервер присылает пустой список остальным
RegisterNetEvent('bu-gangs:client:zones', function(list)
    clearZones()

    local PlayerData = QBCore.Functions.GetPlayerData()
    local myGang = PlayerData.job and PlayerData.job.name

    for i = 1, #list do
        local zone = list[i]
        local isMine = zone.owner == myGang
        local color = zone.owner and Config.Gangs[zone.owner].color or 0

        zonePoints[#zonePoints + 1] = exports['bu-interact']:addPoint(zone.coords, 1.2, {
            label = zone.label .. (zone.owner and (' — ' .. zone.ownerLabel) or ' — ничья'),
            size = 2.0,
            color = isMine and { 62, 142, 90, 150 } or zone.owner and { 214, 69, 69, 150 } or { 154, 167, 180, 150 },
            action = function()
                TriggerServerEvent('bu-gangs:server:capture', zone.key)
            end
        })

        zoneBlips[#zoneBlips + 1] = exports['bu-interact']:addBlip(zone.coords, {
            sprite = 543,
            color = color,
            scale = 0.55,
            name = 'Гетто: ' .. zone.label
        })
    end
end)

