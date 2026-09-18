local QBCore = exports['qb-core']:GetCoreObject()

RegisterCommand('ticket', function(_, args)
    local text = table.concat(args, ' ')
    if text == '' then
        return QBCore.Functions.Notify('Используй: /ticket <текст>', 'error')
    end
    TriggerServerEvent('bu-tickets:server:send', text)
end)

RegisterNetEvent('bu-tickets:client:notify', function(message)
    QBCore.Functions.Notify(message, 'inform', 8000)
end)
