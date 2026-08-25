local QBCore = exports['qb-core']:GetCoreObject()

local shown = false

CreateThread(function()
    while true do
        Wait(250)
        if LocalPlayer.state.buAuthed then
            if shown then
                shown = false
                SendNUIMessage({ type = 'bu:auth:hide' })
                SetNuiFocus(false, false)
                DoScreenFadeOut(400)
                Wait(600)
                DoScreenFadeIn(600)
            end
        else
            if not shown then
                shown = true
                DoScreenFadeIn(400)
                SendNUIMessage({ type = 'bu:auth:open' })
                SetNuiFocus(true, true)
            end
        end
    end
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
