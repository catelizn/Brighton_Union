local QBCore = exports['qb-core']:GetCoreObject()

-- Создание и управление семьёй — из планшета, здесь только команды

RegisterNetEvent('bu-families:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

RegisterNetEvent('bu-families:client:contractWaypoint', function(point)
    SetNewWaypoint(point.x, point.y)
    QBCore.Functions.Notify('Точка контракта отмечена на карте.', 'inform', 5000)
end)

RegisterCommand('family', function()
    QBCore.Functions.TriggerCallback('bu-families:server:getInfo', function(info)
        if not info then return end
        if not info.name then
            QBCore.Functions.Notify('Ты не состоишь в семье. Создай её в планшете (приложение «Семья»).', 'error', 6000)
            return
        end
        local message = string.format('Семья «%s» | Ранг: %d | Участников: %d | Казна: $%d', info.name, info.rank, info.memberCount, info.money)
        QBCore.Functions.Notify(message, 'inform', 8000)
    end)
end, false)

RegisterCommand('finvite', function(_, args)
    local targetId = tonumber(args[1])
    if not targetId then
        QBCore.Functions.Notify('Использование: /finvite [ID игрока]', 'error')
        return
    end
    TriggerServerEvent('bu-families:server:invite', targetId)
end, false)

RegisterCommand('faccept', function()
    TriggerServerEvent('bu-families:server:accept')
end, false)

RegisterCommand('fdeposit', function(_, args)
    local amount = tonumber(args[1])
    if not amount then
        QBCore.Functions.Notify('Использование: /fdeposit [сумма]', 'error')
        return
    end
    TriggerServerEvent('bu-families:server:deposit', amount)
end, false)

RegisterCommand('fwithdraw', function(_, args)
    local amount = tonumber(args[1])
    if not amount then
        QBCore.Functions.Notify('Использование: /fwithdraw [сумма]', 'error')
        return
    end
    TriggerServerEvent('bu-families:server:withdraw', amount)
end, false)
