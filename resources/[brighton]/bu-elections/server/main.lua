local QBCore = exports['qb-core']:GetCoreObject()

local election = { active = false, endsAt = 0 }

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_candidates` (
            `citizenid` varchar(50) NOT NULL,
            `name` varchar(64) NOT NULL,
            `votes` int(11) NOT NULL DEFAULT 0,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_voter` (
            `citizenid` varchar(50) NOT NULL,
            PRIMARY KEY (`citizenid`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]])
    end)
end)

local function getCandidates()
    return MySQL.query.await('SELECT citizenid, name, votes FROM bu_candidates ORDER BY votes DESC') or {}
end

QBCore.Functions.CreateCallback('bu-elections:server:getState', function(source, cb)
    cb({ active = election.active, endsAt = election.endsAt, candidates = getCandidates() })
end)

RegisterNetEvent('bu-elections:server:run', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not election.active then
        return TriggerClientEvent('QBCore:Notify', src, 'Выборы сейчас не идут.', 'error')
    end

    local cid = Player.PlayerData.citizenid
    local exists = MySQL.query.await('SELECT citizenid FROM bu_candidates WHERE citizenid = ? LIMIT 1', { cid })
    if exists and exists[1] then
        return TriggerClientEvent('QBCore:Notify', src, 'Ты уже выдвинут.', 'error')
    end

    if Player.Functions.GetMoney('cash') < Config.CostToRun then
        return TriggerClientEvent('QBCore:Notify', src, 'Недостаточно наличных для выдвижения.', 'error')
    end

    Player.Functions.RemoveMoney('cash', Config.CostToRun, 'election-run')
    MySQL.insert('INSERT INTO bu_candidates (citizenid, name, votes) VALUES (?, ?, 0)', { cid, Player.PlayerData.name })
    TriggerClientEvent('QBCore:Notify', src, 'Ты выдвинул свою кандидатуру!', 'success')
end)

RegisterNetEvent('bu-elections:server:vote', function(cid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not election.active then
        return TriggerClientEvent('QBCore:Notify', src, 'Выборы сейчас не идут.', 'error')
    end

    cid = tostring(cid or '')
    local cand = MySQL.query.await('SELECT citizenid FROM bu_candidates WHERE citizenid = ? LIMIT 1', { cid })
    if not cand or not cand[1] then
        return TriggerClientEvent('QBCore:Notify', src, 'Такого кандидата нет.', 'error')
    end

    local me = Player.PlayerData.citizenid
    if cid == me then
        return TriggerClientEvent('QBCore:Notify', src, 'Нельзя голосовать за себя.', 'error')
    end

    local voted = MySQL.query.await('SELECT citizenid FROM bu_voter WHERE citizenid = ? LIMIT 1', { me })
    if voted and voted[1] then
        return TriggerClientEvent('QBCore:Notify', src, 'Ты уже проголосовал.', 'error')
    end

    MySQL.insert('INSERT INTO bu_voter (citizenid) VALUES (?)', { me })
    MySQL.update('UPDATE bu_candidates SET votes = votes + 1 WHERE citizenid = ?', { cid })
    TriggerClientEvent('QBCore:Notify', src, 'Голос учтён.', 'success')
end)

RegisterNetEvent('bu-elections:server:start', function()
    local src = source
    if not QBCore.Functions.HasPermission(src, 'admin') then return end

    election.active = true
    election.endsAt = os.time() + Config.ElectionTime
    MySQL.update('DELETE FROM bu_candidates')
    MySQL.update('DELETE FROM bu_voter')
    TriggerClientEvent('QBCore:Notify', -1, 'Выборы мэра начались! /run — выдвинуться, /vote — проголосовать.', 'primary')
end)

-- Завершение выборов
CreateThread(function()
    while true do
        Wait(1000)
        if election.active and os.time() >= election.endsAt then
            election.active = false
            local candidates = getCandidates()
            if candidates and candidates[1] then
                local winner = candidates[1]
                local Winner = QBCore.Functions.GetPlayerByCitizenId(winner.citizenid)
                if Winner then
                    Winner.Functions.SetJob(Config.MayorJob, 0)
                    TriggerClientEvent('QBCore:Notify', Winner.PlayerData.source, 'Поздравляем! Ты избран мэром.', 'success')
                end
                TriggerClientEvent('QBCore:Notify', -1, string.format('Выборы завершены. Мэром стал %s (%d голосов).', winner.name, winner.votes), 'primary')
            end
            election.endsAt = 0
        end
    end
end)
