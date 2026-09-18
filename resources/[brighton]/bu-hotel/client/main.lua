local QBCore = exports['qb-core']:GetCoreObject()

local rentedKey = nil
local pointIds = {}

local function refresh()
    for _, id in ipairs(pointIds) do
        exports['bu-interact']:removePoint(id)
    end
    pointIds = {}

    for _, hotel in ipairs(Config.Hotels) do
        if rentedKey == hotel.key then
            pointIds[#pointIds + 1] = exports['bu-interact']:addPoint(hotel.reception, 1.5, {
                label = 'Отель: зайти в номер',
                size = 1.0,
                color = { 47, 143, 131, 150 },
                action = function()
                    local ped = PlayerPedId()
                    SetEntityCoords(ped, hotel.bed.x, hotel.bed.y, hotel.bed.z)
                    DoScreenFadeOut(250)
                    Wait(600)
                    DoScreenFadeIn(250)
                end
            })
        else
            pointIds[#pointIds + 1] = exports['bu-interact']:addPoint(hotel.reception, 1.5, {
                label = 'Снять номер ($' .. Config.Price .. ')',
                size = 1.0,
                color = { 214, 153, 6, 150 },
                action = function()
                    TriggerServerEvent('bu-hotel:server:rent', hotel.key)
                    fetch()
                end
            })
        end
    end
end

local function fetch()
    QBCore.Functions.TriggerCallback('bu-hotel:server:get', function(key)
        rentedKey = key
        refresh()
    end)
end

RegisterCommand('unhotel', function()
    TriggerServerEvent('bu-hotel:server:unrent')
    fetch()
end)

RegisterCommand('sleep', function()
    if not rentedKey then return QBCore.Functions.Notify('У тебя нет номера.', 'error') end
    DoScreenFadeOut(500)
    Wait(1500)
    DoScreenFadeIn(1000)
    QBCore.Functions.Notify('Ты выспался.', 'primary')
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', fetch)
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    fetch()
end)
