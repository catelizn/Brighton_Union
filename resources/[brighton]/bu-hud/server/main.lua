-- Отключаем штатный qb-hud, чтобы вместо него работал HUD Brighton Union
CreateThread(function()
    while true do
        local state = GetResourceState('qb-hud')
        if state == 'started' or state == 'starting' then
            StopResource('qb-hud')
        end
        Wait(30000)
    end
end)
