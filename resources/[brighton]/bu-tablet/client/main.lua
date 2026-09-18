local QBCore = exports['qb-core']:GetCoreObject()

local tabletOpen = false

local function fetchData()
    QBCore.Functions.TriggerCallback('bu-tablet:server:getData', function(data)
        if not data then return end
        -- Для этапа «Разобраться с техникой» в квестах новичка
        TriggerServerEvent('bu-tutorial:server:action', 'tablet')
        SendNUIMessage({ type = 'bu:tablet:open', data = data })
        SetNuiFocus(true, true)
        tabletOpen = true
    end)
end

local function closeTablet()
    tabletOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'bu:tablet:close' })
end

-- Занят ли экран: пауза, любой NUI или открытая панель администратора.
-- MenuV — чужой ресурс, его глобалы другому ресурсу не видны, поэтому
-- menuv сам выставляет LocalPlayer.state.menuvOpen (см. патч менuv в txData).
local function uiBlocked()
    if IsPauseMenuActive() or IsNuiFocused() then return true end
    if LocalPlayer.state.menuvOpen == true then return true end
    return false
end

RegisterKeyMapping('bu_tablet_open', 'Планшет', 'keyboard', Config.OpenKey)

RegisterCommand('bu_tablet_open', function()
    if tabletOpen then
        closeTablet()
    elseif not uiBlocked() then
        fetchData()
    end
end, false)

RegisterNUICallback('close', function(_, cb)
    closeTablet()
    cb('ok')
end)

RegisterNUICallback('refresh', function(_, cb)
    fetchData()
    cb('ok')
end)

-- Маркетплейс: мост NUI <-> сервер
RegisterNetEvent('bu-marketplace:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

RegisterNUICallback('mpList', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-marketplace:server:getListings', function(list)
        SendNUIMessage({ type = 'bu:mp:list', data = list })
        cb('ok')
    end)
end)

RegisterNUICallback('mpMy', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-marketplace:server:getMyItems', function(data)
        SendNUIMessage({ type = 'bu:mp:my', data = data })
        cb('ok')
    end)
end)

RegisterNUICallback('mpCreate', function(data, cb)
    TriggerServerEvent('bu-marketplace:server:create', data.item, data.amount, data.price)
    cb('ok')
end)

RegisterNUICallback('mpBuy', function(data, cb)
    TriggerServerEvent('bu-marketplace:server:buy', data.id)
    cb('ok')
end)

RegisterNUICallback('mpCancel', function(data, cb)
    TriggerServerEvent('bu-marketplace:server:cancel', data.id)
    cb('ok')
end)

RegisterNUICallback('mpFav', function(data, cb)
    TriggerServerEvent('bu-marketplace:server:toggleFavourite', data.id)
    cb('ok')
end)

RegisterNUICallback('mpView', function(data, cb)
    TriggerServerEvent('bu-marketplace:server:view', data.id)
    cb('ok')
end)

RegisterNUICallback('mpCreateProperty', function(data, cb)
    TriggerServerEvent('bu-marketplace:server:createProperty', data.key, data.price)
    cb('ok')
end)

RegisterNUICallback('mpCreateRental', function(data, cb)
    TriggerServerEvent('bu-marketplace:server:createRental', data.plate, data.price, data.hours)
    cb('ok')
end)

RegisterNUICallback('mpRent', function(data, cb)
    TriggerServerEvent('bu-marketplace:server:rentVehicle', data.id)
    cb('ok')
end)

-- Weazel News
RegisterNUICallback('newsList', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-news:server:getList', function(data)
        SendNUIMessage({ type = 'bu:news:list', data = data })
        cb('ok')
    end)
end)

RegisterNUICallback('newsSubmit', function(data, cb)
    TriggerServerEvent('bu-news:server:submit', data.text)
    cb('ok')
end)

-- Даркнет
RegisterNUICallback('darknetList', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-darknet:server:getCatalog', function(data)
        SendNUIMessage({ type = 'bu:darknet:list', data = data })
        cb('ok')
    end)
end)

RegisterNUICallback('darknetBuy', function(data, cb)
    TriggerServerEvent('bu-darknet:server:buy', data.item)
    SetTimeout(600, function()
        QBCore.Functions.TriggerCallback('bu-darknet:server:getCatalog', function(catalog)
            SendNUIMessage({ type = 'bu:darknet:list', data = catalog })
        end)
    end)
    cb('ok')
end)

-- Семья и фракция: данные и действия из планшета
RegisterNUICallback('familyData', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-families:server:getInfo', function(info)
        SendNUIMessage({ type = 'bu:family:data', data = info })
        cb('ok')
    end)
end)

RegisterNUICallback('familyAction', function(data, cb)
    local action = data.action

    if action == 'create' then
        TriggerServerEvent('bu-families:server:create', data.name, data.familyType)
    elseif action == 'deposit' then
        TriggerServerEvent('bu-families:server:deposit', data.amount)
    elseif action == 'withdraw' then
        TriggerServerEvent('bu-families:server:withdraw', data.amount)
    elseif action == 'invite' then
        TriggerServerEvent('bu-families:server:invite', data.targetId)
    elseif action == 'setRank' then
        TriggerServerEvent('bu-families:server:setRank', data.targetCid, data.rank)
    elseif action == 'kick' then
        TriggerServerEvent('bu-families:server:kick', data.targetCid)
    elseif action == 'takeContract' then
        TriggerServerEvent('bu-families:server:takeContract', data.index)
    elseif action == 'contractPickup' then
        TriggerServerEvent('bu-families:server:contractPickup')
    elseif action == 'contractDeliver' then
        TriggerServerEvent('bu-families:server:contractDeliver')
    elseif action == 'buyVehicle' then
        TriggerServerEvent('bu-families:server:buyVehicle', data.index)
    end
    cb('ok')
end)

-- Brighton Taxi и Дальнобой: данные и действия
RegisterNUICallback('taxiList', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-jobs:server:getTaxiOrders', function(data)
        SendNUIMessage({ type = 'bu:taxi:data', data = data })
        cb('ok')
    end)
end)

RegisterNUICallback('taxiTake', function(data, cb)
    TriggerServerEvent('bu-jobs:server:takeTaxiOrder', data.id)
    cb('ok')
end)

RegisterNUICallback('taxiFinish', function(data, cb)
    TriggerServerEvent('bu-jobs:server:finishTaxiOrder', data.id)
    cb('ok')
end)

RegisterNUICallback('truckerList', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-jobs:server:getTruckerOrders', function(data)
        SendNUIMessage({ type = 'bu:trucker:data', data = data })
        cb('ok')
    end)
end)

RegisterNUICallback('truckerAction', function(data, cb)
    if data.action == 'take' then
        TriggerServerEvent('bu-jobs:server:takeTruckerOrder', data.key)
    elseif data.action == 'pickup' then
        TriggerServerEvent('bu-jobs:server:truckerPickup', data.key)
    elseif data.action == 'finish' then
        TriggerServerEvent('bu-jobs:server:finishTruckerOrder', data.key)
    end
    cb('ok')
end)

-- Точка выдачи даркнета
local darknetPoint = nil
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    if darknetPoint then return end
    darknetPoint = exports['bu-interact']:addPoint(Config.Darknet.pickup, 1.5, {
        label = 'Даркнет: забрать заказ',
        color = { 214, 69, 69, 150 },
        action = function()
            TriggerServerEvent('bu-darknet:server:pickup')
        end
    })
end)
