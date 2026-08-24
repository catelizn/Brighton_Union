local QBCore = exports['qb-core']:GetCoreObject()

local states = {}
local markersSetup = false

local function refreshStates()
    QBCore.Functions.TriggerCallback('bu-properties:server:getStates', function(data)
        states = data or {}
        if markersSetup then setupMarkers() end
    end)
end

local function setupMarkers()
    markersSetup = true

    for key, config in pairs(Config.Properties) do
        local state = states[key]
        local owner = state and state.owner or ''
        local owned = state and state.owned or false

        exports['qb-target']:AddCircleZone('bu_prop_' .. key, config.coords, 1.2, {
            name = 'bu_prop_' .. key,
            useZ = true,
            debugPoly = false
        }, {
            options = {
                {
                    icon = 'fas fa-store',
                    label = Config.BuyLabel,
                    action = function()
                        TriggerServerEvent('bu-properties:server:buy', key)
                        SetTimeout(800, refreshStates)
                    end,
                    canInteract = function()
                        return owner == ''
                    end
                },
                {
                    icon = 'fas fa-hand-holding-usd',
                    label = Config.SellLabel,
                    action = function()
                        TriggerServerEvent('bu-properties:server:sellToState', key)
                        SetTimeout(800, refreshStates)
                    end,
                    canInteract = function()
                        return owned
                    end
                },
                {
                    icon = 'fas fa-boxes',
                    label = 'Заказать товары',
                    action = function()
                        local dialog = exports['qb-input']:ShowInput({
                            header = 'Поставка для бизнеса',
                            submitText = 'Заказать',
                            inputs = {
                                {
                                    type = 'number',
                                    isRequired = true,
                                    name = 'units',
                                    text = 'Количество (1–20). Цена: $400 за единицу'
                                }
                            }
                        })
                        if dialog and dialog.units then
                            TriggerServerEvent('bu-properties:server:orderSupplies', key, tonumber(dialog.units))
                        end
                    end,
                    canInteract = function()
                        return owned
                    end
                },
                {
                    icon = 'fas fa-money-bill-wave',
                    label = 'Продать товары',
                    action = function()
                        QBCore.Functions.TriggerCallback('bu-properties:server:getSupplies', function(supplies)
                            if supplies <= 0 then
                                QBCore.Functions.Notify('Товаров нет. Закажи поставку.', 'error')
                            else
                                TriggerServerEvent('bu-properties:server:sellSupplies', key)
                            end
                        end, key)
                    end,
                    canInteract = function()
                        return owned
                    end
                }
            },
            distance = 2.5
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
