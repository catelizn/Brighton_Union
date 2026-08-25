local QBCore = exports['qb-core']:GetCoreObject()

local businessPoints = {}
local businessBlips = {}

local function clearBusinesses()
    for _, id in pairs(businessPoints) do
        exports['bu-interact']:removePoint(id)
    end
    businessPoints = {}
    for _, blip in pairs(businessBlips) do
        RemoveBlip(blip)
    end
    businessBlips = {}
end

-- NPC мафий: вступление через [E]
local joinNpcSetupDone = false

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if joinNpcSetupDone then return end
    joinNpcSetupDone = true

    for mafiaKey, mafia in pairs(Config.Mafias) do
        exports['bu-interact']:spawnPed(mafia.model, mafia.coords, {
            label = mafia.joinLabel,
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
            action = function()
                TriggerServerEvent('bu-mafias:server:join', mafiaKey)
            end
        })
    end
end)

-- Бизнесы и контроль видит только участник мафий
RegisterNetEvent('bu-mafias:client:businesses', function(list)
    clearBusinesses()

    local PlayerData = QBCore.Functions.GetPlayerData()
    local myMafia = PlayerData.job and PlayerData.job.name

    for i = 1, #list do
        local business = list[i]
        local isMine = business.owner == myMafia

        businessPoints[#businessPoints + 1] = exports['bu-interact']:addPoint(business.coords, 1.0, {
            label = business.label .. ' — $' .. business.value .. '/час' .. (business.owner and (' (' .. business.ownerLabel .. ')') or ' (ничья)'),
            size = 1.5,
            color = isMine and { 62, 142, 90, 150 } or business.owner and { 214, 69, 69, 150 } or { 154, 167, 180, 150 },
            action = function()
                TriggerServerEvent('bu-mafias:server:war', business.key)
            end
        })

        businessBlips[#businessBlips + 1] = exports['bu-interact']:addBlip(business.coords, {
            sprite = 108,
            color = business.owner and Config.Mafias[business.owner].color or 0,
            scale = 0.55,
            name = 'Мафия: ' .. business.label
        })
    end
end)
