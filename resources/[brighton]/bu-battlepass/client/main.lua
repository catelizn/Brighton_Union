local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openPass()
    if open then return end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end

RegisterCommand('battlepass', openPass)

RegisterNUICallback('getState', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-battlepass:server:getState', function(res)
        SendNUIMessage({ action = 'state', data = res })
        cb('ok')
    end)
end)

RegisterNUICallback('claim', function(data, cb)
    TriggerServerEvent('bu-battlepass:server:claim', tonumber(data.tier))
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
