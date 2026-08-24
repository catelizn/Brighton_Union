local QBCore = exports['qb-core']:GetCoreObject()

local studioObjects = {}
local inStudio = false
local studioPed = nil

local function studioSpawn()
    local door = Config.Studio.door
    return vec3(door.x, door.y, door.z - Config.Studio.interiorOffsetZ)
end

local function takePhoto()
    DoScreenFadeOut(300)
    Wait(300)
    TriggerServerEvent('bu-documents:server:takePhoto')
end

local function spawnStudioPed()
    if studioPed and DoesEntityExist(studioPed) then return end

    local model = Config.Studio.npcModel
    local spawn = studioSpawn()

    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    studioPed = CreatePed(0, model, spawn.x, spawn.y, spawn.z + 1.0, 0.0, false, false)
    FreezeEntityPosition(studioPed, true)
    SetEntityInvincible(studioPed, true)
    SetBlockingOfNonTemporaryEvents(studioPed, true)
    TaskStartScenarioInPlace(studioPed, 'WORLD_HUMAN_STAND_MOBILE', 0, true)

    exports['qb-target']:AddTargetEntity(studioPed, {
        options = {
            {
                icon = 'fas fa-camera',
                label = Config.PhotoLabel,
                action = function()
                    takePhoto()
                end
            }
        },
        distance = 2.5
    })
end

local function enterStudio()
    if inStudio then return end

    local spawn = studioSpawn()
    local result = exports['qb-interior']:CreateStore2(spawn)
    if result and result[1] then
        studioObjects = result[1]
    end

    inStudio = true
    Wait(300)
    spawnStudioPed()

    local exitPoint = spawn + Config.Studio.exitOffset
    exports['qb-target']:AddCircleZone('bu_studio_exit', vec3(exitPoint.x, exitPoint.y, exitPoint.z), 1.2, {
        name = 'bu_studio_exit',
        useZ = true,
        debugPoly = false
    }, {
        options = {
            {
                icon = 'fas fa-door-open',
                label = Config.ExitLabel,
                action = function()
                    leaveStudio()
                end
            }
        },
        distance = 2.0
    })
end

local function leaveStudio()
    if not inStudio then return end

    exports['qb-target']:RemoveZone('bu_studio_exit')
    DoScreenFadeOut(400)
    Wait(500)

    exports['qb-interior']:DespawnInterior(studioObjects, function()
        studioObjects = {}
    end)

    local door = Config.Studio.door
    SetEntityCoords(PlayerPedId(), door.x, door.y, door.z)
    SetEntityHeading(PlayerPedId(), door.w)

    inStudio = false
    DoScreenFadeIn(600)
end

local function setupDoor()
    local door = Config.Studio.door

    local blip = AddBlipForCoord(door.x, door.y, door.z)
    SetBlipSprite(blip, Config.Studio.blip.sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Studio.blip.scale)
    SetBlipColour(blip, Config.Studio.blip.color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(Config.Studio.blip.name)
    EndTextCommandSetBlipName(blip)

    exports['qb-target']:AddCircleZone('bu_studio_door', vec3(door.x, door.y, door.z), 1.0, {
        name = 'bu_studio_door',
        useZ = true,
        debugPoly = false
    }, {
        options = {
            {
                icon = 'fas fa-camera-retro',
                label = Config.TargetLabel,
                action = function()
                    enterStudio()
                end
            }
        },
        distance = 2.0
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', setupDoor)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    setupDoor()
end)

-- ============================================================
-- Документы: клавиша P (паспорт / лицензии / права)
-- ============================================================

local documentsOpen = false

local function openDocuments()
    if documentsOpen then return end
    QBCore.Functions.TriggerCallback('bu-tablet:server:getData', function(data)
        if not data then return end
        SendNUIMessage({ type = 'bu:documents:open', data = data })
        SetNuiFocus(true, true)
        documentsOpen = true
    end)
end

local function closeDocuments()
    documentsOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ type = 'bu:documents:close' })
end

RegisterKeyMapping('bu_documents', 'Документы', 'keyboard', Config.DocumentsKey)

RegisterCommand('bu_documents', function()
    if documentsOpen then
        closeDocuments()
    else
        openDocuments()
    end
end, false)

RegisterNetEvent('bu-documents:client:open', openDocuments)

RegisterNUICallback('closeDocuments', function(_, cb)
    closeDocuments()
    cb('ok')
end)

RegisterNetEvent('bu-documents:client:photoTaken', function()
    Wait(400)
    DoScreenFadeIn(500)
    QBCore.Functions.Notify('Фото готово. Дата съёмки записана в документы.', 'success')
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    if inStudio then
        exports['qb-interior']:DespawnInterior(studioObjects, function() end)
        inStudio = false
    end
end)

