local QBCore = exports['qb-core']:GetCoreObject()

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_tickets` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `citizenid` varchar(50) NOT NULL,
            `text` varchar(255) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

RegisterNetEvent('bu-tickets:server:send', function(text)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    text = tostring(text or ''):sub(1, 255)
    if text == '' then return end

    MySQL.insert('INSERT INTO bu_tickets (citizenid, text) VALUES (?, ?)', { Player.PlayerData.citizenid, text })

    for _, sid in ipairs(GetPlayers()) do
        if QBCore.Functions.HasPermission(sid, 'admin') then
            TriggerClientEvent('bu-tickets:client:notify', sid, string.format('Тикет от %s: %s', Player.PlayerData.name, text))
        end
    end

    TriggerClientEvent('QBCore:Notify', src, 'Тикет отправлен. Администрация уведомлена.', 'success')
end)
