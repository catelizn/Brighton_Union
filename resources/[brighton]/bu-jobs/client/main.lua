local QBCore = exports['qb-core']:GetCoreObject()

local spawnedPeds = {}

local function spawnTargetPed(model, coords, label, action)
    local ped = exports['bu-interact']:spawnPed(model, coords, {
        label = label,
        scenario = 'WORLD_HUMAN_STAND_MOBILE',
        action = action
    })
    spawnedPeds[#spawnedPeds + 1] = ped
    return ped
end

local function setupHireNpcs()
    for jobKey, job in pairs(Config.Jobs) do
        if job.hire then
            spawnTargetPed(job.hire.model, job.hire.coords, 'Устроиться: ' .. job.label, function()
                TriggerServerEvent('bu-jobs:server:hire', jobKey)
            end)

            -- Блип найма: у каждой работы своя метка на карте
            exports['bu-interact']:addBlip(vec3(job.hire.coords.x, job.hire.coords.y, job.hire.coords.z), {
                sprite = 498,
                color = 2,
                scale = 0.7,
                name = 'Работа: ' .. job.label
            })
        end
    end
end

local function setupMarket()
    exports['bu-interact']:addBlip(Config.Market.coords, {
        sprite = 52,
        color = 2,
        scale = 0.8,
        name = Config.Market.name
    })

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
        end)
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
                exports['bu-interact']:addPoint(zone.coords, zone.radius or Config.DefaultZoneRadius, {
                    label = zone.label,
                    size = 1.2,
                    color = { 214, 153, 6, 150 },
                    action = function()
                        doProgress(jobKey, 'bu-jobs:server:gather', zoneIndex)
                    end
                })
            end
        end

        if job.route then
            for pointIndex = 1, #job.route do
                local point = job.route[pointIndex]
                exports['bu-interact']:addPoint(point, 3.0, {
                    label = job.routeLabel or 'Доставить письмо',
                    size = 0.7,
                    color = { 46, 90, 68, 150 },
                    action = function()
                        doProgress(jobKey, 'bu-jobs:server:deliver', pointIndex)
                    end
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

