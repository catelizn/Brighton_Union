local QBCore = exports['qb-core']:GetCoreObject({ 'Functions' })
local zones = {}

local isPlayerInsideBankZone = false

-- Functions

local function OpenBank()
    QBCore.Functions.TriggerCallback('qb-banking:server:isBankOpen', function(open)
        if not open then
            QBCore.Functions.Notify('Банк закрыт. Режим работы: 09:00–21:00. Банкоматы работают круглосуточно.', 'error', 5000)
            return
        end
        QBCore.Functions.TriggerCallback('qb-banking:server:openBank', function(accounts, statements, playerData, accountNumber)
            playerData.accountNumber = accountNumber
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openBank',
                accounts = accounts,
                statements = statements,
                playerData = playerData
            })
        end)
    end)
end

local function OpenATM()
    QBCore.Functions.Progressbar('accessing_atm', Lang:t('progress.atm'), 1500, false, true, {
        disableMovement = false,
        disableCarMovement = false,
        disableMouse = false,
        disableCombat = false,
    }, {
        animDict = 'amb@prop_human_atm@male@enter',
        anim = 'enter',
    }, {
        model = 'prop_cs_credit_card',
        bone = 28422,
        coords = vector3(0.1, 0.03, -0.05),
        rotation = vector3(0.0, 0.0, 180.0),
    }, {}, function()
        QBCore.Functions.TriggerCallback('qb-banking:server:openATM', function(accounts, playerData, acceptablePins)
            -- Счёт ещё не открыт: банкомат денег не покажет, отправляем в отделение
            if not accounts then return end
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'openATM',
                accounts = accounts,
                pinNumbers = acceptablePins,
                playerData = playerData
            })
        end)
    end)
end

local function NearATM()
    local playerCoords = GetEntityCoords(PlayerPedId())
    for _, v in pairs(Config.atmModels) do
        local hash = joaat(v)
        local atm = IsObjectNearPoint(hash, playerCoords.x, playerCoords.y, playerCoords.z, 1.5)
        if atm then
            return true
        end
    end
end

-- NUI Callback

RegisterNUICallback('closeApp', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('withdraw', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:withdraw', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('deposit', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:deposit', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('internalTransfer', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:internalTransfer', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('externalTransfer', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:externalTransfer', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('orderCard', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:orderCard', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('openAccount', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:openAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('renameAccount', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:renameAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('deleteAccount', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:deleteAccount', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('addUser', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:addUser', function(status)
        cb(status)
    end, data)
end)

RegisterNUICallback('removeUser', function(data, cb)
    QBCore.Functions.TriggerCallback('qb-banking:server:removeUser', function(status)
        cb(status)
    end, data)
end)

-- Events

RegisterNetEvent('qb-banking:client:useCard', function()
    if NearATM() then OpenATM() end
end)

-- Threads

CreateThread(function()
    for i = 1, #Config.locations do
        local blip = AddBlipForCoord(Config.locations[i])
        SetBlipSprite(blip, Config.blipInfo.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.blipInfo.scale)
        SetBlipColour(blip, Config.blipInfo.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName(tostring(Config.blipInfo.name))
        EndTextCommandSetBlipName(blip)
    end
end)

if Config.useTarget then
    CreateThread(function()
        for i = 1, #Config.locations do
            exports['qb-target']:AddCircleZone('bank_' .. i, Config.locations[i], 1.0, {
                name = 'bank_' .. i,
                useZ = true,
                debugPoly = false,
            }, {
                options = {
                    {
                        icon = 'fas fa-university',
                        label = 'Банк',
                        action = function()
                            OpenBank()
                        end,
                    }
                },
                distance = 1.5
            })
        end
    end)

    CreateThread(function()
        for i = 1, #Config.atmModels do
            local atmModel = Config.atmModels[i]
            exports['qb-target']:AddTargetModel(atmModel, {
                options = {
                    {
                        icon = 'fas fa-university',
                        label = 'Банкомат',
                        item = 'bank_card',
                        action = function()
                            OpenATM()
                        end,
                    }
                },
                distance = 1.5
            })
        end
    end)
end

if not Config.useTarget then
    CreateThread(function()
        for i = 1, #Config.locations do
            local zone = CircleZone:Create(Config.locations[i], 3.0, {
                name = 'bank_' .. i,
                debugPoly = false,
            })
            zones[#zones + 1] = zone
        end

        local combo = ComboZone:Create(zones, {
            name = 'bank_combo',
            debugPoly = false,
        })

        combo:onPlayerInOut(function(isPointInside)
            isPlayerInsideBankZone = isPointInside
            if isPlayerInsideBankZone then
                exports['qb-core']:DrawText('Банк')
                CreateThread(function()
                    while isPlayerInsideBankZone do
                        Wait(0)
                        if IsControlJustPressed(0, 38) then
                            OpenBank()
                        end
                    end
                end)
            else
                exports['qb-core']:HideText()
            end
        end)
    end)
end

-- Brighton Union: видимые точки [E] у банков и банкоматов.
-- В qb-target зонах подсказок нет, и игрок не понимает, где взаимодействовать.
CreateThread(function()
    while GetResourceState('bu-interact') ~= 'started' do
        Wait(500)
    end

    for i = 1, #Config.locations do
        local coords = Config.locations[i]
        exports['bu-interact']:spawnPed('a_m_m_business_01', vector4(coords.x, coords.y, coords.z, 0.0), {
            label = 'Сотрудник банка',
            hint = 'Банковские услуги',
            scenario = 'WORLD_HUMAN_STAND_MOBILE',
            action = OpenBank,
            face = true
        })
    end

    -- Банкомат: одна точка, которая следует за ближайшим аппаратом
    local pointId, pointPos
    while true do
        Wait(700)
        local playerPos = GetEntityCoords(PlayerPedId())
        local atmPos

        for i = 1, #Config.atmModels do
            local obj = GetClosestObjectOfType(playerPos.x, playerPos.y, playerPos.z, 8.0, joaat(Config.atmModels[i]), false, false, false)
            if obj ~= 0 then
                atmPos = GetEntityCoords(obj)
                break
            end
        end

        if atmPos then
            if not pointId or #(atmPos - pointPos) > 2.0 then
                if pointId then
                    exports['bu-interact']:removePoint(pointId)
                end
                pointId = exports['bu-interact']:addPoint(atmPos, 1.6, {
                    label = 'Банкомат',
                    hint = 'Снять или внести деньги',
                    size = 0.8,
                    action = OpenATM
                })
                pointPos = atmPos
            end
        elseif pointId then
            exports['bu-interact']:removePoint(pointId)
            pointId = nil
            pointPos = nil
        end
    end
end)