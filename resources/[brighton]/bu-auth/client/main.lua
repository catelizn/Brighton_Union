local QBCore = exports['qb-core']:GetCoreObject()

local shown = false
local started = false
local pageReady = false

RegisterNUICallback('ready', function(_, cb)
    pageReady = true
    cb('ok')
end)

CreateThread(function()
    -- Прячем системный чат сразу и держим экран чёрным до формы авторизации:
    -- между загрузкой и формой не должно мелькать ни города, ни чата
    ExecuteCommand('toggleChat hidden')

    while true do
        Wait(0)
        DoScreenFadeOut(0)

        if LocalPlayer.state.buAuthed then
            break
        end

        -- Переход с загрузочного экрана на форму делаем одним шагом: сначала
        -- страница отрисовывается (чёрная подложка уже на месте), и только
        -- потом закрываем лоадер и открываем форму — так между экранами
        -- не мелькает город.
        if not shown and pageReady and NetworkIsSessionStarted() then
            if not started then
                started = true
                Wait(150)
                ShutdownLoadingScreen()
                ShutdownLoadingScreenNui()
                Wait(150)
            end

            shown = true
            SendNUIMessage({ type = 'bu:auth:open' })
            SetNuiFocus(true, true)
            SetAudioFlag('DisableAmbientZoneMusic', true)
            SetAudioFlag('DisableFlightMusic', true)
        end

        -- Пед убран глубоко под картой в пустыне: не видно ни города, ни
        -- падения, и нет посторонних звуков (вода/ветер/скрежет)
        SetEntityVisible(PlayerPedId(), false)
        SetEntityCoordsNoOffset(PlayerPedId(), 1900.0, 3700.0, -150.0, false, false, false)
        FreezeEntityPosition(PlayerPedId(), true)
    end

    -- Авторизация пройдена: форму прячем, экран оставляем чёрным до выбора персонажа
    SendNUIMessage({ type = 'bu:auth:hide' })
    SetNuiFocus(false, false)
    SetAudioFlag('DisableAmbientZoneMusic', false)
    SetAudioFlag('DisableFlightMusic', false)
    DoScreenFadeOut(400)
end)

RegisterNUICallback('submit', function(data, cb)
    local mode = data.mode == 'register' and 'register' or 'login'
    QBCore.Functions.TriggerCallback('bu-auth:server:auth', function(result)
        if not result then return cb('ok') end
        if not result.ok then
            SendNUIMessage({ type = 'bu:auth:error', message = result.message })
        end
        cb('ok')
    end, mode, data.username, data.password)
end)

RegisterNUICallback('exit', function(_, cb)
    -- Выход из формы невозможен: без авторизации игра не начнётся
    cb('ok')
end)
