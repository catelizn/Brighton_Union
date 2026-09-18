local QBCore = exports['qb-core']:GetCoreObject()

local acquaintances = {}
local families = {}

local function pairKey(a, b)
    if a > b then a, b = b, a end
    return a .. '|' .. b
end

MySQL.query.await([[
    CREATE TABLE IF NOT EXISTS `bu_acquaintances` (
        `citizenid_a` VARCHAR(64) NOT NULL,
        `citizenid_b` VARCHAR(64) NOT NULL,
        PRIMARY KEY (`citizenid_a`, `citizenid_b`)
    )
]])

local function loadAcquaintances()
    acquaintances = {}
    local rows = MySQL.query.await('SELECT citizenid_a, citizenid_b FROM bu_acquaintances')
    if rows then
        for _, row in ipairs(rows) do
            acquaintances[pairKey(row.citizenid_a, row.citizenid_b)] = true
        end
    end
end

local function loadFamilies()
    families = {}
    local rows = MySQL.query.await('SELECT citizenid, family_id FROM bu_family_members')
    if rows then
        for _, row in ipairs(rows) do
            families[row.citizenid] = row.family_id
        end
    end
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    loadAcquaintances()
    loadFamilies()
end)

local function isKnown(a, b)
    local pa, pb = a.PlayerData, b.PlayerData
    if acquaintances[pairKey(pa.citizenid, pb.citizenid)] then return true end
    local jobName = pa.job.name
    if jobName and jobName ~= 'unemployed' and jobName == pb.job.name then return true end
    local fa, fb = families[pa.citizenid], families[pb.citizenid]
    if fa and fb and fa == fb then return true end
    return false
end

RegisterCommand('handshake', function(source)
    local player = QBCore.Functions.GetPlayer(source)
    if not player then return end
    local myPed = GetPlayerPed(source)
    if not myPed or myPed == 0 then return end
    local myPos = GetEntityCoords(myPed)

    local closest, closestDist = nil, Config.HandshakeDistance
    for _, other in pairs(QBCore.Functions.GetQBPlayers()) do
        local otherSrc = other.PlayerData.source
        if otherSrc ~= source then
            local otherPed = GetPlayerPed(otherSrc)
            if otherPed and otherPed ~= 0 then
                local dist = #(myPos - GetEntityCoords(otherPed))
                if dist < closestDist then
                    closest, closestDist = other, dist
                end
            end
        end
    end

    if not closest then
        TriggerClientEvent('QBCore:Notify', source, 'Рядом никого нет', 'error')
        return
    end

    local key = pairKey(player.PlayerData.citizenid, closest.PlayerData.citizenid)
    if acquaintances[key] then
        TriggerClientEvent('QBCore:Notify', source, 'Вы уже знакомы', 'primary')
        return
    end

    acquaintances[key] = true
    local a, b = player.PlayerData.citizenid, closest.PlayerData.citizenid
    if a > b then a, b = b, a end
    MySQL.insert('INSERT IGNORE INTO bu_acquaintances (citizenid_a, citizenid_b) VALUES (?, ?)', { a, b })

    local myName = player.PlayerData.charinfo.firstname .. ' ' .. player.PlayerData.charinfo.lastname
    local otherName = closest.PlayerData.charinfo.firstname .. ' ' .. closest.PlayerData.charinfo.lastname
    TriggerClientEvent('QBCore:Notify', source, 'Вы познакомились: ' .. otherName, 'success')
    TriggerClientEvent('QBCore:Notify', closest.PlayerData.source, 'Вы познакомились: ' .. myName, 'success')
end, false)

CreateThread(function()
    while true do
        Wait(Config.SyncInterval)
        local players = QBCore.Functions.GetQBPlayers()
        local online = {}
        for src, player in pairs(players) do
            local ped = GetPlayerPed(src)
            if ped and ped ~= 0 then
                online[src] = { player = player, coords = GetEntityCoords(ped) }
            end
        end

        for src, me in pairs(online) do
            local out = {}
            for otherSrc, other in pairs(online) do
                if otherSrc ~= src and #(me.coords - other.coords) < Config.GiveDistance then
                    local name = nil
                    if isKnown(me.player, other.player) then
                        local charinfo = other.player.PlayerData.charinfo
                        name = charinfo.firstname .. ' ' .. charinfo.lastname
                    end
                    out[#out + 1] = {
                        id = otherSrc,
                        name = name,
                        gender = other.player.PlayerData.charinfo.gender
                    }
                end
            end
            TriggerClientEvent('bu-nametags:client:update', src, out)
        end
    end
end)
