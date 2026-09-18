local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openBoard()
    if open then return end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end

RegisterCommand('f7', openBoard)
RegisterKeyMapping('f7', 'Доска', 'keyboard', 'F7')

RegisterNUICallback('get', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-factionboard:server:get', function(res)
        SendNUIMessage({ action = 'data', data = res })
        cb('ok')
    end)
end)

RegisterNUICallback('deposit', function(data, cb)
    TriggerServerEvent('bu-factionboard:server:deposit', tonumber(data.amount))
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
