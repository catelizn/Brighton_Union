local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openCasino()
    QBCore.Functions.TriggerCallback('bu-casino:server:getInfo', function(info)
        if not info then return end
        SendNUIMessage({ type = 'bu:casino:open', data = info })
        SetNuiFocus(true, true)
        open = true
    end)
end

local function closeCasino()
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'bu:casino:close' })
end

CreateThread(function()
    local coords = Config.Casino.coords
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, Config.Casino.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Casino.blip.scale)
    SetBlipColour(blip, Config.Casino.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Casino.blip.name)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddCircleZone('bu_casino_entrance', coords, Config.Casino.zoneRadius, {
        name = 'bu_casino_entrance',
        useZ = true,
        debugPoly = false
    }, {
        options = {
            {
                icon = 'fas fa-dice',
                label = 'Войти в казино',
                action = function()
                    openCasino()
                end
            }
        },
        distance = 2.5
    })
end)

RegisterNetEvent('bu-casino:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

RegisterNetEvent('bu-casino:client:rouletteResult', function(result)
    SendNUIMessage({ type = 'bu:casino:rouletteResult', data = result })
end)

RegisterNetEvent('bu-casino:client:slotsResult', function(result)
    SendNUIMessage({ type = 'bu:casino:slotsResult', data = result })
end)

RegisterNetEvent('bu-casino:client:blackjackState', function(state)
    SendNUIMessage({ type = 'bu:casino:blackjackState', data = state })
end)

RegisterNetEvent('bu-casino:client:pokerState', function(state)
    SendNUIMessage({ type = 'bu:casino:pokerState', data = state })
end)

RegisterNetEvent('bu-casino:client:mafiaState', function(state)
    SendNUIMessage({ type = 'bu:casino:mafiaState', data = state })
end)

RegisterNUICallback('roulette', function(data, cb)
    TriggerServerEvent('bu-casino:server:roulette', data.bet)
    cb('ok')
end)

RegisterNUICallback('slots', function(data, cb)
    TriggerServerEvent('bu-casino:server:slots', data.amount)
    cb('ok')
end)

RegisterNUICallback('blackjackStart', function(data, cb)
    TriggerServerEvent('bu-casino:server:blackjackStart', data.amount)
    cb('ok')
end)

RegisterNUICallback('blackjackHit', function(_, cb)
    TriggerServerEvent('bu-casino:server:blackjackHit')
    cb('ok')
end)

RegisterNUICallback('blackjackStand', function(_, cb)
    TriggerServerEvent('bu-casino:server:blackjackStand')
    cb('ok')
end)

RegisterNUICallback('getPokerTables', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-casino:server:getPokerTables', function(tables)
        SendNUIMessage({ type = 'bu:casino:pokerTables', data = tables })
        cb('ok')
    end)
end)

RegisterNUICallback('getMafiaRooms', function(_, cb)
    QBCore.Functions.TriggerCallback('bu-casino:server:getMafiaRooms', function(rooms)
        SendNUIMessage({ type = 'bu:casino:mafiaRooms', data = rooms })
        cb('ok')
    end)
end)

RegisterNUICallback('pokerCreate', function(data, cb)
    TriggerServerEvent('bu-casino:server:pokerCreate', data.buyIn)
    cb('ok')
end)

RegisterNUICallback('pokerJoin', function(data, cb)
    TriggerServerEvent('bu-casino:server:pokerJoin', data.id)
    cb('ok')
end)

RegisterNUICallback('pokerStart', function(data, cb)
    TriggerServerEvent('bu-casino:server:pokerStart', data.id)
    cb('ok')
end)

RegisterNUICallback('pokerAction', function(data, cb)
    TriggerServerEvent('bu-casino:server:pokerAction', data.id, data.action)
    cb('ok')
end)

RegisterNUICallback('mafiaCreate', function(_, cb)
    TriggerServerEvent('bu-casino:server:mafiaCreate')
    cb('ok')
end)

RegisterNUICallback('mafiaJoin', function(data, cb)
    TriggerServerEvent('bu-casino:server:mafiaJoin', data.id)
    cb('ok')
end)

RegisterNUICallback('mafiaStart', function(data, cb)
    TriggerServerEvent('bu-casino:server:mafiaStart', data.id)
    cb('ok')
end)

RegisterNUICallback('mafiaAction', function(data, cb)
    TriggerServerEvent('bu-casino:server:mafiaAction', data.id, data.action, data.target)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    closeCasino()
    cb('ok')
end)
