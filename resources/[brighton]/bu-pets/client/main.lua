local QBCore = exports['qb-core']:GetCoreObject()

local petPed = nil
local petData = nil

local function spawnPet(data)
    if petPed and DoesEntityExist(petPed) then
        DeleteEntity(petPed)
        petPed = nil
    end
    if not data then return end

    RequestModel(data.model)
    while not HasModelLoaded(data.model) do Wait(0) end

    local pos = GetEntityCoords(PlayerPedId())
    petPed = CreatePed(4, joaat(data.model), pos.x, pos.y - 1.5, pos.z, 0.0, false, false)
    SetEntityInvincible(petPed, true)
    SetBlockingOfNonTemporaryEvents(petPed, true)
end

local function fetchPet()
    QBCore.Functions.TriggerCallback('bu-pets:server:get', function(data)
        petData = data
        spawnPet(data)
    end)
end

RegisterNetEvent('bu-pets:client:adopted', function(data)
    petData = data
    spawnPet(data)
end)

RegisterNetEvent('bu-pets:client:renamed', function(name)
    if petData then petData.name = name end
end)

-- Питомец держится рядом
CreateThread(function()
    while true do
        Wait(500)
        if petPed and DoesEntityExist(petPed) then
            local ped = PlayerPedId()
            local pPos = GetEntityCoords(ped)
            local dist = #(GetEntityCoords(petPed) - pPos)
            if dist > 6.0 then
                SetEntityCoords(petPed, pPos.x + 1.2, pPos.y + 1.2, pPos.z)
            end
        end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', fetchPet)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if petPed and DoesEntityExist(petPed) then
        DeleteEntity(petPed)
    end
    petPed = nil
end)

RegisterCommand('petfeed', function()
    if not petData then return QBCore.Functions.Notify('У тебя нет питомца.', 'error') end
    QBCore.Functions.Notify('Ты покормил ' .. petData.name .. '.', 'primary')
end)

RegisterCommand('petname', function(source, args)
    if not petData then return QBCore.Functions.Notify('У тебя нет питомца.', 'error') end
    local name = table.concat(args, ' ')
    if name == '' then return QBCore.Functions.Notify('Используй: /petname <имя>', 'error') end
    TriggerServerEvent('bu-pets:server:rename', name)
end)

-- Точка усыновления
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    exports['bu-interact']:addPoint(Config.PetDropoff, 1.5, {
        label = 'Зоомагазин',
        size = 1.0,
        color = { 47, 143, 131, 150 },
        action = function()
            QBCore.Functions.Notify('Питомец: набери /adoptpet, чтобы взять.', 'primary')
        end
    })
    exports['bu-interact']:addBlip(Config.PetDropoff, {
        sprite = 1, color = 2, scale = 0.7, name = 'Зоомагазин', shortRange = false
    })
end)
