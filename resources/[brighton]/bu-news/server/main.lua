local QBCore = exports['qb-core']:GetCoreObject()

Config = Config or {}
Config.AdPrice = 500
Config.AdCooldown = 60
Config.AdMinLength = 3
Config.AdMaxLength = 100
Config.MaxStoredAds = 50

local adsCache = {} -- { author, text, createdAt }
local lastAd = {} -- src -> os.clock()

CreateThread(function()
    while not MySQL do Wait(100) end
    MySQL.ready(function()
        MySQL.query([[CREATE TABLE IF NOT EXISTS `bu_ads` (
            `id` int(11) NOT NULL AUTO_INCREMENT,
            `author` varchar(64) NOT NULL DEFAULT '',
            `text` varchar(200) NOT NULL,
            `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
            PRIMARY KEY (`id`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci]], {}, function()
            MySQL.query('SELECT author, text, created_at FROM bu_ads ORDER BY id DESC LIMIT ?', { Config.MaxStoredAds }, function(result)
                if not result then return end
                for i = #result, 1, -1 do
                    adsCache[#adsCache + 1] = {
                        author = result[i].author,
                        text = result[i].text,
                        createdAt = result[i].created_at
                    }
                end
            end)
        end)
    end)
end)

QBCore.Functions.CreateCallback('bu-news:server:getList', function(source, cb)
    local list = {}
    for i = #adsCache, math.max(1, #adsCache - 29), -1 do
        local ad = adsCache[i]
        list[#list + 1] = ad
    end
    cb({ ads = list, price = Config.AdPrice })
end)

RegisterNetEvent('bu-news:server:submit', function(text)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    text = text and tostring(text):gsub('%s+', ' '):trim() or ''
    if #text < Config.AdMinLength or #text > Config.AdMaxLength then
        TriggerClientEvent('QBCore:Notify', src, string.format('Текст объявления: от %d до %d символов.', Config.AdMinLength, Config.AdMaxLength), 'error')
        return
    end

    local now = os.clock()
    if lastAd[src] and now - lastAd[src] < Config.AdCooldown then
        TriggerClientEvent('QBCore:Notify', src, 'Подожди перед следующим объявлением.', 'error')
        return
    end
    lastAd[src] = now

    local bank = Player.PlayerData.money.bank
    if not bank or bank < Config.AdPrice then
        TriggerClientEvent('QBCore:Notify', src, string.format('Нужно $%d на банковском счёте.', Config.AdPrice), 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', Config.AdPrice, 'weazel-news-ad')

    local author = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or '')
    local createdAt = os.date('%d.%m.%Y %H:%M')

    MySQL.insert('INSERT INTO bu_ads (author, text) VALUES (?, ?)', { author, text })

    adsCache[#adsCache + 1] = { author = author, text = text, createdAt = createdAt }
    if #adsCache > Config.MaxStoredAds then
        table.remove(adsCache, 1)
    end

    TriggerClientEvent('chat:addMessage', -1, {
        color = { 217, 119, 6 },
        multiline = false,
        args = { 'Weazel News', text .. ' — ' .. author }
    })

    TriggerClientEvent('QBCore:Notify', src, 'Объявление опубликовано.', 'success')
end)
