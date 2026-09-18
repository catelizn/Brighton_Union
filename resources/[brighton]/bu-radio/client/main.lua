local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('radio', function(_, args)
    local ch = tonumber(args[1]) or 0
    TriggerServerEvent('bu-radio:server:set', ch)
end)

RegisterNetEvent('bu-radio:client:notify', function(message)
    QBCore.Functions.Notify(message, 'primary')
end)
