local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    for i = 1, #Config.Blips do
        local blip = Config.Blips[i]
        exports['bu-interact']:addBlip(vec3(blip.coords.x, blip.coords.y, blip.coords.z), {
            sprite = blip.sprite,
            color = blip.color,
            scale = blip.scale,
            name = blip.name,
            shortRange = false
        })
    end
end)
