local QBCore = exports['qb-core']:GetCoreObject()

-- Коммунальные платежи: раз в час списываются с банка владельцев
-- бизнесов, квартир и домов. Не хватает средств — платёж пропускается.

Config = Config or {}
Config.IntervalMinutes = 60
Config.BusinessUtility = 250
Config.ApartmentUtility = 120
Config.HouseUtility = 150

local function chargeOwner(cid, amount, label)
    if not cid or cid == '' then return end

    local result = MySQL.query.await('SELECT money FROM players WHERE citizenid = ? LIMIT 1', { cid })
    if not result or not result[1] or not result[1].money then return end

    local money = json.decode(result[1].money)
    if not money or type(money) ~= 'table' then return end

    local bank = tonumber(money.bank) or 0
    local target = QBCore.Functions.GetPlayerByCitizenId(cid)

    if bank < amount then
        if target then
            TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Коммунальные услуги (' .. label .. '): на счёте не хватает средств.', 'error')
        end
        return
    end

    money.bank = bank - amount
    MySQL.update('UPDATE players SET money = ? WHERE citizenid = ?', { json.encode(money), cid })

    if target then
        TriggerClientEvent('QBCore:Notify', target.PlayerData.source, 'Коммунальные услуги (' .. label .. '): -$' .. amount, 'primary')
    end
end

local function collectBills()
    MySQL.ready(function()
        local businesses = MySQL.query.await("SELECT owner FROM bu_properties WHERE owner <> ''")
        if businesses then
            for i = 1, #businesses do
                chargeOwner(businesses[i].owner, Config.BusinessUtility, 'бизнес')
            end
        end

        local apartments = MySQL.query.await("SELECT owner FROM bu_apartments WHERE owner <> ''")
        if apartments then
            for i = 1, #apartments do
                chargeOwner(apartments[i].owner, Config.ApartmentUtility, 'квартира')
            end
        end

        local houses = MySQL.query.await('SELECT citizenid FROM player_houses')
        if houses then
            for i = 1, #houses do
                chargeOwner(houses[i].citizenid, Config.HouseUtility, 'дом')
            end
        end
    end)
end

CreateThread(function()
    Wait(60 * 1000)
    while true do
        collectBills()
        Wait(Config.IntervalMinutes * 60 * 1000)
    end
end)
