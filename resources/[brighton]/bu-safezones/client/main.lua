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
        -- Пока игрок в меню выбора/создания/кат-сцене — плашку не показываем.
        -- Внимание: здесь нельзя писать `flag and nil or zone` — вернёт zone.
        local zone = nil
        if LocalPlayer.state.isLoggedIn and not LocalPlayer.state.buSelecting then
            zone = findZone(position)
        end

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
