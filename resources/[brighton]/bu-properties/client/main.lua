local QBCore = exports['qb-core']:GetCoreObject()

local states = {}
local pointIds = {}
local blips = {}

local function formatMoney(value)
    local text = tostring(math.floor(value))
    local formatted = ''
    local counter = 0
    for i = #text, 1, -1 do
        counter = counter + 1
        formatted = text:sub(i, i) .. formatted
        if counter % 3 == 0 and i > 1 then
            formatted = ' ' .. formatted
        end
    end
    return '$' .. formatted
end

local function clearMarkers()
    for _, id in pairs(pointIds) do
        exports['bu-interact']:removePoint(id)
    end
    pointIds = {}
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
end

local function refreshStates()
    QBCore.Functions.TriggerCallback('bu-properties:server:getStates', function(data)
        states = data or {}
        clearMarkers()
        setupMarkers()
    end)
end

local function setupMarkers()
    for key, config in pairs(Config.Properties) do
        local state = states[key]
        local owner = state and state.owner or ''
        local owned = state and state.owned or false

        local label
        local action
        if owned then
            label = config.label .. ' — управление'
            action = function()
                openManageMenu(key)
            end
        else
            label = Config.BuyLabel .. ': ' .. config.label .. ' — ' .. formatMoney(config.price)
            action = function()
                TriggerServerEvent('bu-properties:server:buy', key)
                SetTimeout(800, refreshStates)
            end
        end

        pointIds[key] = exports['bu-interact']:addPoint(config.coords, 1.2, {
            label = label,
            size = 1.2,
            color = owned and { 214, 69, 69, 150 } or { 62, 142, 90, 150 },
            action = action
        })

        blips[key] = exports['bu-interact']:addBlip(config.coords, {
            sprite = 108,
            color = owned and 1 or 2,
            scale = 0.7,
            name = config.label,
            shortRange = false
        })
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    refreshStates()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    refreshStates()
end)

RegisterNetEvent('bu-properties:client:refreshStates', refreshStates)

RegisterNetEvent('bu-properties:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

local function openManageMenu(key)
    local config = Config.Properties[key]
    exports['qb-menu']:openMenu({
        { header = 'Управление: ' .. config.label, isMenuHeader = true },
        {
            header = 'Заказать товары',
            txt = formatMoney(Config.Supply.orderPricePerUnit) .. ' за единицу',
            params = { event = 'bu-properties:client:orderSupplies', args = { key = key } }
        },
        {
            header = 'Продать товары',
            txt = formatMoney(Config.Supply.sellPricePerUnit) .. ' за единицу',
            params = { event = 'bu-properties:client:sellSupplies', args = { key = key } }
        },
        {
            header = 'Продать государству',
            txt = 'Вернёт ' .. math.floor(Config.StateRefundPercent * 100) .. '% стоимости',
            params = { event = 'bu-properties:client:sellToState', args = { key = key } }
        }
    })
end

RegisterNetEvent('bu-properties:client:orderSupplies', function(data)
    local key = data.key
    local dialog = exports['qb-input']:ShowInput({
        header = 'Поставка для бизнеса',
        submitText = 'Заказать',
        inputs = {
            {
                type = 'number',
                isRequired = true,
                name = 'units',
                text = 'Количество (1-' .. Config.Supply.maxUnitsPerOrder .. '). Цена: ' .. formatMoney(Config.Supply.orderPricePerUnit) .. ' за единицу'
            }
        }
    })
    if dialog and dialog.units then
        TriggerServerEvent('bu-properties:server:orderSupplies', key, tonumber(dialog.units))
    end
end)

RegisterNetEvent('bu-properties:client:sellSupplies', function(data)
    local key = data.key
    QBCore.Functions.TriggerCallback('bu-properties:server:getSupplies', function(supplies)
        if supplies <= 0 then
            QBCore.Functions.Notify('Товаров нет. Закажи поставку.', 'error')
        else
            TriggerServerEvent('bu-properties:server:sellSupplies', key)
        end
    end, key)
end)

RegisterNetEvent('bu-properties:client:sellToState', function(data)
    TriggerServerEvent('bu-properties:server:sellToState', data.key)
    SetTimeout(800, refreshStates)
end)
