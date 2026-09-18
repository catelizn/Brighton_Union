local QBCore = exports['qb-core']:GetCoreObject()

local busy = false

local function openWheel()
    if busy then return end
    busy = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', rewards = Config.Rewards, cost = Config.Cost })
end

local function closeWheel(result)
    busy = false
    SetNuiFocus(false, false)
    if result then
        QBCore.Functions.Notify(result.label == 'Мимо' and 'Мимо! Попробуй ещё.' or ('Выигрыш: ' .. result.label .. '!'), 'success')
    end
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('spin', function(_, cb)
    if not busy then return cb('closed') end
    QBCore.Functions.TriggerCallback('bu-luckywheel:server:spin', function(res)
        if res and res.ok then
            SendNUIMessage({ action = 'spin', index = res.index, reward = res.reward })
        else
            closeWheel(nil)
            QBCore.Functions.Notify(res and res.error == 'wait' and 'Подожди перед следующим вращением.' or 'Недостаточно наличных.', 'error')
        end
    end)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    closeWheel(nil)
    cb('ok')
end)

-- Закрытие по Esc
CreateThread(function()
    while true do
        if busy and IsControlJustPressed(0, 202) then
            closeWheel(nil)
        end
        Wait(0)
    end
end)

-- Открытие: команда + точка в казино
RegisterCommand('luckywheel', function() openWheel() end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    if Config.Spot then
        exports['bu-interact']:addPoint(Config.Spot.coords, 1.5, {
            label = Config.Spot.label,
            size = 1.0,
            color = { 214, 153, 6, 150 },
            action = openWheel
        })
        exports['bu-interact']:addBlip(Config.Spot.coords, {
            sprite = 1, color = 5, scale = 0.7, name = Config.Spot.label, shortRange = false
        })
    end
end)
