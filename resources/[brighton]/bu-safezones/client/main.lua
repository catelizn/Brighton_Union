local QBCore = exports['qb-core']:GetCoreObject()

local currentZone = nil

local function findZone(position)
    for i = 1, #Config.Zones do
        local zone = Config.Zones[i]
        if #(position - zone.coords) <= zone.radius then
            return zone
        end
    end
    return nil
end

local function setBadge(zoneName)
    SendNUIMessage({ type = 'zone', show = zoneName ~= nil, name = zoneName or '' })
end

-- Один лёгкий цикл: проверка зон раз в полсекунды, блокировка оружия только внутри зоны.
-- Индикатор зелёной зоны показывается у миникарты, без уведомлений.
CreateThread(function()
    while true do
        Wait(500)

        local playerPed = PlayerPedId()
        local position = GetEntityCoords(playerPed)
        local zone = findZone(position)

        if zone then
            local weapon = GetSelectedPedWeapon(playerPed)
            if weapon ~= GetHashKey('WEAPON_UNARMED') then
                SetCurrentPedWeapon(playerPed, GetHashKey('WEAPON_UNARMED'), true)
            end
            for i = 1, #Config.BlockedControls do
                DisableControlAction(0, Config.BlockedControls[i], true)
            end
            if currentZone ~= zone.name then
                currentZone = zone.name
                setBadge(zone.name)
            end
        else
            if currentZone then
                currentZone = nil
                setBadge(nil)
            end
        end
    end
end)
