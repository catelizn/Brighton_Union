local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openRealtor()
    if open then return end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end

RegisterCommand('realtor', openRealtor)

RegisterNUICallback('getListings', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-realtor:server:getListings', function(list)
        SendNUIMessage({ action = 'listings', list = list })
        cb('ok')
    end)
end)

RegisterNUICallback('getMine', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-realtor:server:getMine', function(list)
        SendNUIMessage({ action = 'mine', list = list })
        cb('ok')
    end)
end)

RegisterNUICallback('list', function(data, cb)
    TriggerServerEvent('bu-realtor:server:list', data.key, data.price)
    cb('ok')
end)

RegisterNUICallback('unlist', function(data, cb)
    TriggerServerEvent('bu-realtor:server:unlist', data.key)
    cb('ok')
end)

RegisterNUICallback('buy', function(data, cb)
    TriggerServerEvent('bu-realtor:server:buy', tonumber(data.id))
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    open = false
    SetNuiFocus(false, false)
    cb('ok')
end)

CreateThread(function()
    while true do
        if open and IsControlJustPressed(0, 202) then
            open = false
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'close' })
        end
        Wait(0)
    end
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    exports['bu-interact']:addPoint(Config.Realtor.coords, 1.5, {
        label = Config.Realtor.label,
        size = 1.0,
        color = { 47, 143, 131, 150 },
        action = openRealtor
    })
    exports['bu-interact']:addBlip(Config.Realtor.coords, {
        sprite = 374, color = 2, scale = 0.7, name = Config.Realtor.label, shortRange = false
    })
end)
