local QBCore = exports['qb-core']:GetCoreObject()

local open = false

local function openRadial()
    if open then return end
    -- Z занят панелью быстрых слотов (qb-inventory Hotbar), поэтому радиальное
    -- меню висит на F3. В машине и при открытых меню (NUI, пауза,
    -- админка MenuV) не открываемся.
    if IsPauseMenuActive() or IsNuiFocused() then return end
    if LocalPlayer.state.menuvOpen == true then return end
    if IsPedInAnyVehicle(PlayerPedId(), false) then return end
    open = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', items = Config.Items })
end

local function doAction(id)
    local a = Config.Actions[id]
    local ped = PlayerPedId()
    ClearPedTasks(ped)

    if a and a.scenario then
        TaskStartScenarioInPlace(ped, a.scenario, -1, true)
    elseif a and a.anim then
        RequestAnimDict(a.anim.dict)
        while not HasAnimDictLoaded(a.anim.dict) do Wait(0) end
        TaskPlayAnim(ped, a.anim.dict, a.anim.name, 8.0, -8.0, -1, a.anim.flag or 1, 0, false, false, false)
    end
end

RegisterCommand('bu_radial_menu', openRadial)
RegisterKeyMapping('bu_radial_menu', 'Радиальное меню', 'keyboard', 'F3')

RegisterNUICallback('action', function(data, cb)
    open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    doAction(data.id)
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    open = false
    SetNuiFocus(false, false)
    cb('ok')
end)

CreateThread(function()
    while true do
        if open and IsControlJustPressed(0, 202) then
            open = false
            SetNuiFocus(false, false)
            SendNUIMessage({ action = 'close' })
        end
        Wait(0)
    end
end)
