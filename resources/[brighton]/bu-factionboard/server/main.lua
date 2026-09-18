local QBCore = exports['qb-core']:GetCoreObject()

local function joinPlayers(sql)
    return MySQL.query.await(sql)
end

QBCore.Functions.CreateCallback('bu-factionboard:server:get', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local cid = Player.PlayerData.citizenid
    local job = Player.PlayerData.job.name

    -- Семья
    local fam = MySQL.query.await('SELECT m.rank, f.id, f.name, f.money FROM bu_family_members m JOIN bu_families f ON f.id = m.family_id WHERE m.citizenid = ? LIMIT 1', { cid })
    if fam and fam[1] then
        local members = joinPlayers([[SELECT m.citizenid, m.rank, p.firstname, p.lastname
            FROM bu_family_members m LEFT JOIN players p ON p.citizenid = m.citizenid
            WHERE m.family_id = ? ORDER BY m.rank DESC LIMIT 50]])
        return cb({
            type = 'family',
            name = fam[1].name,
            money = fam[1].money,
            rank = fam[1].rank,
            members = members or {}
        })
    end

    -- Банда
    local gang = MySQL.query.await('SELECT gang, money FROM bu_gang_treasury WHERE gang = ? LIMIT 1', { job })
    if gang and gang[1] then
        local zones = MySQL.query.await('SELECT COUNT(*) AS c FROM bu_gang_zones WHERE gang = ? AND zone_key <> \'\'', { job })
        return cb({
            type = 'gang',
            name = job,
            money = gang[1].money,
            zones = zones and zones[1] and zones[1].c or 0
        })
    end

    -- Мафия
    local mafia = MySQL.query.await('SELECT mafia, money FROM bu_mafia_treasury WHERE mafia = ? LIMIT 1', { job })
    if mafia and mafia[1] then
        local control = MySQL.query.await('SELECT COUNT(*) AS c FROM bu_mafia_control WHERE mafia = ? AND prop_key <> \'\'', { job })
        return cb({
            type = 'mafia',
            name = job,
            money = mafia[1].money,
            control = control and control[1] and control[1].c or 0
        })
    end

    cb({ type = 'none' })
end)

RegisterNetEvent('bu-factionboard:server:deposit', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    amount = tonumber(amount)
    if not amount or amount < 1 or amount % 100 ~= 0 then
        return TriggerClientEvent('QBCore:Notify', src, 'Сумма кратна 100.', 'error')
    end
    if Player.Functions.GetMoney('cash') < amount then
        return TriggerClientEvent('QBCore:Notify', src, 'Недостаточно наличных.', 'error')
    end
    local cid = Player.PlayerData.citizenid
    local job = Player.PlayerData.job.name

    local fam = MySQL.query.await('SELECT f.id FROM bu_family_members m JOIN bu_families f ON f.id = m.family_id WHERE m.citizenid = ? LIMIT 1', { cid })
    if fam and fam[1] then
        Player.Functions.RemoveMoney('cash', amount, 'f7-deposit')
        MySQL.update('UPDATE bu_families SET money = money + ? WHERE id = ?', { amount, fam[1].id })
        TriggerClientEvent('QBCore:Notify', src, 'Пополнено в казну.', 'success')
        return
    end

    local gang = MySQL.query.await('SELECT gang FROM bu_gang_treasury WHERE gang = ? LIMIT 1', { job })
    if gang and gang[1] then
        Player.Functions.RemoveMoney('cash', amount, 'f7-deposit')
        MySQL.update('UPDATE bu_gang_treasury SET money = money + ? WHERE gang = ?', { amount, job })
        TriggerClientEvent('QBCore:Notify', src, 'Пополнено в казну банды.', 'success')
        return
    end

    local mafia = MySQL.query.await('SELECT mafia FROM bu_mafia_treasury WHERE mafia = ? LIMIT 1', { job })
    if mafia and mafia[1] then
        Player.Functions.RemoveMoney('cash', amount, 'f7-deposit')
        MySQL.update('UPDATE bu_mafia_treasury SET money = money + ? WHERE mafia = ?', { amount, job })
        TriggerClientEvent('QBCore:Notify', src, 'Пополнено в казну мафии.', 'success')
    end
end)
