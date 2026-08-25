local QBCore = exports['qb-core']:GetCoreObject()

local activeFire = nil -- { spotId, coords }

local function startFire()
    if activeFire then return end

    local spot = Config.Spots[math.random(#Config.Spots)]
    activeFire = { coords = spot }

    TriggerClientEvent('bu-firefighter:client:fireStarted', -1, spot)

    SetTimeout(Config.BurnMinutes * 60 * 1000, function()
        if activeFire then
            TriggerClientEvent('bu-firefighter:client:fireStopped', -1)
            activeFire = nil
        end
    end)
end

RegisterNetEvent('bu-firefighter:server:extinguish', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if Player.PlayerData.job.name ~= 'firefighter' or not Player.PlayerData.job.onduty then return end
    if not activeFire then return end

    local position = GetEntityCoords(GetPlayerPed(src))
    if #(position - activeFire.coords) > Config.ExtinguishRadius then return end

    Player.Functions.AddMoney('cash', Config.ExtinguishPay, 'firefighter-extinguish')
    TriggerClientEvent('bu-firefighter:client:fireStopped', -1)
    TriggerClientEvent('bu-firefighter:client:notify', src, 'Пожар потушен: +$' .. Config.ExtinguishPay, 'success')
    activeFire = nil
end)

CreateThread(function()
    Wait(60 * 1000)
    while true do
        Wait(Config.SpawnEveryMinutes * 60 * 1000)
        startFire()
    end
end)
