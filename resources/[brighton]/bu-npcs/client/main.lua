local QBCore = exports['qb-core']:GetCoreObject()

local done = false

local function spawnClerk(model, coords, label, heading)
    exports['bu-interact']:spawnPed(model, { x = coords.x, y = coords.y, z = coords.z, w = heading or 0.0 }, {
        label = label,
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        action = function()
            QBCore.Functions.Notify(label, 'primary', 4000)
        end
    })
end

local function setupNpcs()
    for i = 1, #Config.BankLocations do
        local bank = Config.BankLocations[i]
        spawnClerk(Config.ClerkModel, bank, 'Банк', 180.0)
    end

    spawnClerk(Config.DealerModel, Config.Casino.coords, 'Казино', 180.0)
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if done then return end
    done = true
    setupNpcs()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if not done then
        done = true
        setupNpcs()
    end
end)
