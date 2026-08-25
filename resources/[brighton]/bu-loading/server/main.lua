-- Заменяем штатный экран QBCore нашим
CreateThread(function()
    for i = 1, 30 do
        Wait(1000)
        if GetResourceState('qb-loading') == 'started' then
            StopResource('qb-loading')
            break
        end
    end
end)
