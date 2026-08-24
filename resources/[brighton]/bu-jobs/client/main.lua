local QBCore = exports['qb-core']:GetCoreObject()

local spawnedPeds = {}

local function snapToGround(x, y, z)
    local found, groundZ = GetGroundZFor_3dCoord(x, y, z, true)
    return found and groundZ or z
end

local function spawnTargetPed(model, coords, label, action, icon)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local z = snapToGround(coords.x, coords.y, coords.z)
    local ped = CreatePed(0, model, coords.x, coords.y, z, coords.w, false, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, 'WORLD_HUMAN_STAND_MOBILE', 0, true)

    exports['qb-target']:AddTargetEntity(ped, {
        options = {
            {
                icon = icon or 'fas fa-user',
                label = label,
                action = action
            }
        },
        distance = 2.5
    })

    spawnedPeds[#spawnedPeds + 1] = ped
end

local function setupHireNpcs()
    for jobKey, job in pairs(Config.Jobs) do
        if job.hire then
            spawnTargetPed(job.hire.model, job.hire.coords, 'Устроиться: ' .. job.label, function()
                TriggerServerEvent('bu-jobs:server:hire', jobKey)
            end, 'fas fa-briefcase')
        end
    end
end

local function setupMarket()
    for i = 1, #Config.Market.stands do
        local stand = Config.Market.stands[i]
        local coords = vector4(
            Config.Market.coords.x + stand.offset.x,
            Config.Market.coords.y + stand.offset.y,
            Config.Market.coords.z + stand.offset.z,
            180.0
        )
        spawnTargetPed(stand.model, coords, stand.label, function()
            TriggerServerEvent('bu-jobs:server:marketSell', stand.job)
        end, 'fas fa-hand-holding-usd')
    end
end

local function doProgress(jobKey, event, payload)
    local job = Config.Jobs[jobKey]
    QBCore.Functions.Progressbar('bu-job-action', job.label, 2500, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true
    }, {}, {}, {}, function()
        TriggerServerEvent(event, jobKey, payload)
    end, function()
        QBCore.Functions.Notify('Действие прервано.', 'error')
    end)
end

local function setupJobZones()
    for jobKey, job in pairs(Config.Jobs) do
        if job.zones then
            for zoneIndex = 1, #job.zones do
                local zone = job.zones[zoneIndex]
                exports['qb-target']:AddCircleZone('bu_job_' .. jobKey .. '_' .. zoneIndex, zone.coords, zone.radius or Config.DefaultZoneRadius, {
                    name = 'bu_job_' .. jobKey .. '_' .. zoneIndex,
                    useZ = true,
                    debugPoly = false
                }, {
                    options = {
                        {
                            icon = 'fas fa-briefcase',
                            label = zone.label,
                            action = function()
                                doProgress(jobKey, 'bu-jobs:server:gather', zoneIndex)
                            end
                        }
                    },
                    distance = 2.5
                })
            end
        end

        if job.route then
            for pointIndex = 1, #job.route do
                local point = job.route[pointIndex]
                exports['qb-target']:AddCircleZone('bu_job_postman_' .. pointIndex, point, 3.0, {
                    name = 'bu_job_postman_' .. pointIndex,
                    useZ = true,
                    debugPoly = false
                }, {
                    options = {
                        {
                            icon = 'fas fa-envelope',
                            label = 'Доставить письмо',
                            action = function()
                                doProgress(jobKey, 'bu-jobs:server:deliver', pointIndex)
                            end
                        }
                    },
                    distance = 2.5
                })
            end
        end
    end
end

local function setupAll()
    setupHireNpcs()
    setupMarket()
    setupJobZones()
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', setupAll)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    setupAll()
end)

RegisterNetEvent('bu-jobs:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

RegisterNetEvent('bu-jobs:client:taxiWaypoint', function(point)
    SetNewWaypoint(point.x, point.y)
end)

RegisterNetEvent('bu-jobs:client:truckerWaypoint', function(point)
    SetNewWaypoint(point.x, point.y)
end)

