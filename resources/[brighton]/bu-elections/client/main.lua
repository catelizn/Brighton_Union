local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openElections()
    if open then return end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open' })
end

RegisterCommand('elections', openElections)
RegisterCommand('run', function()
    TriggerServerEvent('bu-elections:server:run')
end)
RegisterCommand('vote', function(_, args)
    TriggerServerEvent('bu-elections:server:vote', args[1])
end)

RegisterNUICallback('getState', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-elections:server:getState', function(res)
        SendNUIMessage({ action = 'state', data = res })
        cb('ok')
    end)
end)

RegisterNUICallback('run', function(_, cb)
    TriggerServerEvent('bu-elections:server:run')
    cb('ok')
end)

RegisterNUICallback('vote', function(data, cb)
    TriggerServerEvent('bu-elections:server:vote', data.citizenid)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    open = false
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('bu-elections:client:refresh', function()
    SendNUIMessage({ action = 'refresh' })
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
