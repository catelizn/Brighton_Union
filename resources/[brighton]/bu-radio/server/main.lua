local QBCore = exports['qb-core']:GetCoreObject()

local channels = {} -- src -> channel

RegisterNetEvent('bu-radio:server:set', function(channel)
    local src = source
    channel = tonumber(channel) or 0

    local old = channels[src]
    if old and old > 0 then
        pcall(function() exports['pma-voice']:removePlayerFromRadio(src, old) end)
    end

    channels[src] = nil
    if channel > 0 and channel <= 100 then
        local ok = pcall(function() exports['pma-voice']:addPlayerToRadio(src, channel) end)
        if ok then
            channels[src] = channel
            TriggerClientEvent('QBCore:Notify', src, 'Рация: канал ' .. channel .. '.', 'primary')
        else
            TriggerClientEvent('QBCore:Notify', src, 'Рация недоступна на сервере.', 'error')
        end
    else
        TriggerClientEvent('QBCore:Notify', src, 'Рация выключена.', 'primary')
    end
end)
