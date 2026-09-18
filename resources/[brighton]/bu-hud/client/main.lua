local QBCore = exports['qb-core']:GetCoreObject()

local shown = false
local lastChatHidden = nil
local lastQuestMsg = ''
local quest = { hint = '', stage = 0, total = 7, completed = false, done = false }

-- Выносливость: штатный GetPlayerSprintStaminaRemaining в FiveM отдаёт мусор
-- (скачет 0/100), поэтому ведём метр сами и синхронизируем с игровым баром
-- через RestorePlayerStamina — персонаж устаёт и сбавляет темп по-настоящему.
local stamina = 1.0
local STAMINA_DRAIN_PER_SEC = 0.09
local STAMINA_REGEN_PER_SEC = 0.05
local lastStaminaTick = 0

-- Системный чат FiveM: 'hidden' / 'whenactive'. Прячем, пока игрок не в мире:
-- авторизация, выбор персонажа, настройка внешности, кат-сцена прилёта.
local function setChatHidden(hidden)
    if lastChatHidden == hidden then return end
    lastChatHidden = hidden
    ExecuteCommand(hidden and 'toggleChat hidden' or 'toggleChat whenactive')
end

local function sendQuest()
    local payload
    if quest.completed or quest.hint == '' then
        payload = { type = 'bu:hud:quest', hide = true }
    else
        payload = {
            type = 'bu:hud:quest',
            data = {
                hint = quest.hint,
                stage = quest.stage,
                total = quest.total,
                done = quest.done
            }
        }
    end

    local encoded = json.encode(payload)
    if encoded == lastQuestMsg then return end
    lastQuestMsg = encoded
    SendNUIMessage(payload)
end

RegisterNetEvent('bu-quest:client:update', function(data)
    if not data then return end
    quest.hint = data.hint or ''
    quest.stage = data.stage or 0
    quest.total = data.total or 7
    quest.completed = data.completed and true or false
    quest.done = data.done and true or false
    if shown then sendQuest() end
end)

-- Подсказки скрываются по F6 (состояние запоминает NUI)
RegisterCommand('bu_hints', function()
    SendNUIMessage({ type = 'bu:hud:toggleHints' })
end, false)
RegisterKeyMapping('bu_hints', 'Подсказки HUD', 'keyboard', 'F6')

local function getLocation()
    local position = GetEntityCoords(PlayerPedId())
    local streetHash, crossingHash = GetStreetNameAtCoord(position.x, position.y, position.z)
    local street = streetHash ~= 0 and GetStreetNameFromHashKey(streetHash) or ''
    local crossing = crossingHash ~= 0 and GetStreetNameFromHashKey(crossingHash) or ''
    if street == '' then return 'Лос-Сантос' end
    return crossing ~= '' and (street .. ' / ' .. crossing) or street
end

local function colorFor(percent)
    if percent > 60 then return ''
    elseif percent > 30 then return 'warning'
    end
    return 'critical'
end

local function tick()
    local playerPed = PlayerPedId()
    local playerData = QBCore.Functions.GetPlayerData()
    local metadata = playerData.metadata or {}

    local health = math.max(0, GetEntityHealth(playerPed) - 100)
    local armor = GetPedArmour(playerPed)

    -- Метр выносливости: бег тратит, отдых восстанавливает
    local now = GetGameTimer()
    local dt = math.min(5.0, math.max(0.0, (now - lastStaminaTick) / 1000.0))
    lastStaminaTick = now
    if IsPedSprinting(playerPed) then
        stamina = math.max(0.0, stamina - STAMINA_DRAIN_PER_SEC * dt)
    else
        stamina = math.min(1.0, stamina + STAMINA_REGEN_PER_SEC * dt)
    end
    RestorePlayerStamina(PlayerId(), stamina)

    local hunger = metadata.hunger or 100
    local thirst = metadata.thirst or 100

    local snapshot = {
        health = health,
        armor = armor,
        stamina = math.floor(stamina * 100 + 0.5),
        hunger = hunger,
        thirst = thirst,
        cash = playerData.money.cash or 0,
        bank = playerData.money.bank or 0,
        location = getLocation(),
        online = NetworkGetNumConnectedPlayers(),
        time = { hour = GetClockHours(), minute = GetClockMinutes() }
    }

    SendNUIMessage({ type = 'bu:hud:update', data = snapshot })
end

CreateThread(function()
    while true do
        Wait(750)
        local selecting = LocalPlayer.state.buSelecting == true
        setChatHidden((not LocalPlayer.state.isLoggedIn) or selecting)

        if not LocalPlayer.state.isLoggedIn or IsNuiFocused() or selecting then
            if shown then
                SendNUIMessage({ type = 'bu:hud:hide' })
                shown = false
            end
        else
            if not shown then
                SendNUIMessage({ type = 'bu:hud:show' })
                shown = true
                TriggerEvent('bu-quest:client:request')
            end
            sendQuest()
            tick()
        end
        Wait(750)
    end
end)

-- На нуле выносливости спринт блокируем: без запрета персонаж бежал дальше,
-- и шкала выносливости ни на что не влияла
CreateThread(function()
    while true do
        if stamina <= 0.02 then
            DisableControlAction(0, 21, true)
            Wait(0)
        else
            Wait(400)
        end
    end
end)

-- Миникарта: видимая зона — чуть уже плашки зелёной зоны, чтобы карта
-- гарантированно помещалась под ней и не заходила на колонку статусов.
CreateThread(function()
    while true do
        Wait(250)
        SetBigmapActive(false, false)
        SetMinimapClipType(0)
        SetMinimapComponentPosition('minimap', 'L', 'B', -0.0050, 0.0058, 0.1660, 0.1810)
        SetMinimapComponentPosition('minimap_mask', 'L', 'B', 0.020, 0.032, 0.122, 0.148)
        SetMinimapComponentPosition('minimap_blur', 'L', 'B', -0.0335, 0.0230, 0.2980, 0.2280)
    end
end)

-- Прячем родные полоски HP/брони под миникартой (scaleform minimap)
CreateThread(function()
    local minimap = RequestScaleformMovie('minimap')
    while not HasScaleformMovieLoaded(minimap) do Wait(50) end
    while true do
        Wait(0)
        BeginScaleformMovieMethod(minimap, 'SETUP_HEALTH_ARMOUR')
        ScaleformMovieMethodAddParamInt(3)
        EndScaleformMovieMethod()
    end
end)
