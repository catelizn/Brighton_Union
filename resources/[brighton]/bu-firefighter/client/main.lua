local QBCore = exports['qb-core']:GetCoreObject()

local firePointId = nil
local particles = {}

local function removeFire()
    if firePointId then
        exports['bu-interact']:removePoint(firePointId)
        firePointId = nil
    end
    for _, particle in pairs(particles) do
        StopParticleFxLooped(particle, 0)
    end
    particles = {}
end

RegisterNetEvent('bu-firefighter:client:fireStarted', function(coords)
    removeFire()

    RequestNamedPtfxAsset('core')
    while not HasNamedPtfxAssetLoaded('core') do Wait(0) end
    UseParticleFxAsset('core')

    for i = 1, 4 do
        local x = coords.x + (i % 2 == 0 and 1.5 or -1.5)
        local y = coords.y + (i > 2 and 1.5 or -1.5)
        local particle = StartParticleFxLoopedAtCoord('ent_ray_fire', x, y, coords.z + 1.0, 0.0, 0.0, 0.0, 2.5, false, false, false, false)
        particles[#particles + 1] = particle
    end

    firePointId = exports['bu-interact']:addPoint(coords, 2.0, {
        label = 'Потушить пожар',
        size = 1.5,
        color = { 214, 69, 69, 170 },
        action = function()
            local PlayerData = QBCore.Functions.GetPlayerData()
            if PlayerData.job.name ~= 'firefighter' or not PlayerData.job.onduty then
                QBCore.Functions.Notify('Только дежурный пожарный может тушить.', 'error')
                return
            end
            QBCore.Functions.Progressbar('bu-fire-extinguish', 'Тушение пожара', 6000, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true
            }, {}, {}, {}, function()
                TriggerServerEvent('bu-firefighter:server:extinguish')
                TriggerServerEvent('bu-jobs:server:externalAction', 'firefighter')
            end, function()
                QBCore.Functions.Notify('Тушение прервано.', 'error')
            end)
        end
    })
end)

RegisterNetEvent('bu-firefighter:client:fireStopped', function()
    removeFire()
end)

RegisterNetEvent('bu-firefighter:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)
