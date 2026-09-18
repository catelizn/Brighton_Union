local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openMdt()
    QBCore.Functions.TriggerCallback('bu-policemd:server:isPolice', function(isPolice)
        if not isPolice then return QBCore.Functions.Notify('Доступ только у полиции.', 'error') end
        if open then return end
        open = true
        SetNuiFocus(true, true)
        SendNUIMessage({ action = 'open' })
    end)
end

local function closeMdt()
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterCommand('mdt', openMdt)
RegisterKeyMapping('mdt', 'Полицейский компьютер', 'keyboard', 'F9')

RegisterNUICallback('searchPlayer', function(data, cb)
    QBCore.Functions.TriggerCallback('bu-policemd:server:searchPlayer', function(res)
        SendNUIMessage({ action = 'players', data = res })
        cb('ok')
    end, data.query)
end)

RegisterNUICallback('getProfile', function(data, cb)
    QBCore.Functions.TriggerCallback('bu-policemd:server:getProfile', function(res)
        SendNUIMessage({ action = 'profile', data = res })
        cb('ok')
    end, data.citizenid)
end)

RegisterNUICallback('searchVehicle', function(data, cb)
    QBCore.Functions.TriggerCallback('bu-policemd:server:searchVehicle', function(res)
        SendNUIMessage({ action = 'vehicle', data = res })
        cb('ok')
    end, data.plate)
end)

RegisterNUICallback('addWarrant', function(data, cb)
    TriggerServerEvent('bu-policemd:server:addWarrant', data.citizenid, data.reason, data.level)
    cb('ok')
end)

RegisterNUICallback('removeWarrant', function(data, cb)
    TriggerServerEvent('bu-policemd:server:removeWarrant', data.id)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    closeMdt()
    cb('ok')
end)

RegisterNetEvent('bu-policemd:client:refresh', function(citizenid)
    if citizenid then SendNUIMessage({ action = 'refresh', citizenid = citizenid }) end
end)

CreateThread(function()
    while true do
        if open and IsControlJustPressed(0, 202) then
            closeMdt()
        end
        Wait(0)
    end
end)
