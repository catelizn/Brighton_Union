local QBCore = exports['qb-core']:GetCoreObject()

local npc = nil
local pendingArrival = false
local dialogOpen = false
local advanced = false      -- игрок только что сдал шаг: откроем следующий
local totalStages = #Config.Quest.stages

-- Задание, которое игрок выполняет сейчас (nil — всё пройдено)
local function currentTask(state)
    if not state or state.completed then return nil end
    return Config.Quest.stages[state.stage + 1]
end

-- Отдаём HUD текущее задание (окошко над подсказками).
-- Пока квест не взят, табличка не показывается вообще.
local function broadcastQuest(state)
    if not state or state.completed or state.stage < 1 then
        TriggerEvent('bu-quest:client:update', { stage = 0, completed = true, total = totalStages })
        return
    end

    local task = currentTask(state)
    TriggerEvent('bu-quest:client:update', {
        stage = state.stage,
        completed = false,
        total = totalStages,
        hint = task and task.hint or nil,
        done = state.canTurnIn and true or false
    })
end

local function refreshQuest()
    QBCore.Functions.TriggerCallback('bu-tutorial:server:getState', function(state)
        if state then broadcastQuest(state) end
    end)
end

RegisterNetEvent('bu-quest:client:request', refreshQuest)

-- Диалог хронологичный: только текущий шаг, без списка всех заданий
local function openTutorial()
    QBCore.Functions.TriggerCallback('bu-tutorial:server:getState', function(state)
        if not state then return end
        local task = currentTask(state)
        SendNUIMessage({
            type = 'bu:tutorial:open',
            data = {
                npcName = Config.Quest.npcName,
                label = Config.Quest.label,
                stage = state.stage,
                completed = state.completed,
                total = totalStages,
                canTurnIn = state.canTurnIn and true or false,
                task = task and {
                    text = task.text,
                    reward = task.reward
                } or nil
            }
        })
        SetNuiFocus(true, true)
        dialogOpen = true
    end)
end

local function spawnNpc()
    if npc then return end
    npc = exports['bu-interact']:spawnPed(Config.NPC.model, Config.NPC.coords, {
        label = Config.TargetLabel,
        hint = Config.HintLabel,
        scenario = Config.NPC.scenario,
        anim = Config.NPC.anim,
        blip = Config.NPC.blip,
        plate = { text = Config.TargetLabel, range = 22.0 },
        action = openTutorial
    })
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    spawnNpc()
    -- Несколько попыток, чтобы не поймать момент, когда сервер ещё не знает игрока
    local attempts = 0
    local function checkState()
        QBCore.Functions.TriggerCallback('bu-tutorial:server:getState', function(state)
            if state then
                broadcastQuest(state)
                if state.stage == 0 and not state.completed then
                    pendingArrival = true
                end
            elseif attempts < 10 then
                attempts = attempts + 1
                SetTimeout(500, checkState)
            end
        end)
    end
    checkState()
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    spawnNpc()
end)

-- Персонаж создаётся заново: кат-сцена прилёта нужна всегда
RegisterNetEvent('qb-clothes:client:CreateFirstCharacter', function()
    pendingArrival = true
end)

-- Персонаж создан и подтверждён: прилёт в аэропорт
RegisterNetEvent('qb-clothing:client:onMenuClose', function()
    if pendingArrival then
        pendingArrival = false
        TriggerEvent('bu-tutorial:client:arrival')
        return
    end
    -- Если прилёт не поставился при входе (гонка) — проверяем ещё раз
    QBCore.Functions.TriggerCallback('bu-tutorial:server:getState', function(state)
        if state and state.stage == 0 and not state.completed then
            TriggerEvent('bu-tutorial:client:arrival')
        end
    end)
end)

RegisterNetEvent('bu-tutorial:client:update', function(stage, completed)
    -- Закрываем окно, чтобы можно было сразу идти выполнять шаг
    if dialogOpen then
        dialogOpen = false
        SendNUIMessage({ type = 'bu:tutorial:close' })
        SetNuiFocus(false, false)
    end

    -- Игрок сдал шаг: звенит начисление на карту и сразу открывается следующий
    -- шаг. Отдельное «похвальное» окно только дробило диалог на два сообщения.
    if advanced then
        advanced = false
        PlaySoundFrontend(-1, 'LOCAL_PLYR_CASH_COUNT', 'PLAYER_CASH_SOUNDSET', true)
        SetTimeout(900, openTutorial)
    end

    refreshQuest()
end)

RegisterNetEvent('bu-tutorial:client:notify', function(message, notifyType)
    QBCore.Functions.Notify(message, notifyType or 'primary', 6000)
end)

-- Кат-сцена прилёта: официальное вступление GTA Online (MP_INTRO_CONCAT).
-- Как на Majestic: самолёт с пассажирами, посадка в ЛС, поверх — наш титул.
RegisterNetEvent('bu-tutorial:client:arrival', function()
    LocalPlayer.state:set('buSelecting', true, true)
    DoScreenFadeOut(300)
    Wait(400)

    PrepareMusicEvent('FM_INTRO_START')
    TriggerMusicEvent('FM_INTRO_START')

    local playerPed = PlayerPedId()

    -- Пол берём из данных персонажа: к моменту кат-сцены модель педа могла ещё
    -- не примениться, а от пола зависит и модель в сцене (иначе на мужчине
    -- окажется женское тело)
    local isMale = IsPedMale(playerPed)
    local playerData = QBCore.Functions.GetPlayerData()
    if playerData and playerData.charinfo then
        local gender = tonumber(playerData.charinfo.gender)
        if gender == 0 or gender == 1 then
            isMale = gender == 0
        end
    end

    local playerModel = isMale and 'MP_Male_Character' or 'MP_Female_Character'

    RequestCutsceneWithPlaybackList('MP_INTRO_CONCAT', isMale and 31 or 103, 8)
    while not HasCutsceneLoaded() do
        Wait(10)
    end

    -- Главная роль: сам игрок
    RegisterEntityForCutscene(0, playerModel, 3, GetEntityModel(playerPed), 0)
    RegisterEntityForCutscene(playerPed, playerModel, 0, 0, 0)
    SetCutsceneEntityStreamingFlags(playerModel, 0, 1)

    -- Пассажиры рейса: разные люди, без масок и без лысин
    local pedsList = {
        'MP_Plane_Passenger_1', 'MP_Plane_Passenger_2', 'MP_Plane_Passenger_3',
        'MP_Plane_Passenger_4', 'MP_Plane_Passenger_5', 'MP_Plane_Passenger_6',
        'MP_Plane_Passenger_7'
    }
    local cutscenePeds = {}
    for i = 0, 6 do
        local isFemale = (i == 1 or i == 2 or i == 4 or i == 6)
        local model = isFemale and 'mp_f_freemode_01' or 'mp_m_freemode_01'
        RequestModel(model)
        while not HasModelLoaded(model) do Wait(10) end
        local p = CreatePed(26, model, -1117.77783203125, -1557.6248779296875, 3.3819, 0.0, false, false)
        SetBlockingOfNonTemporaryEvents(p, true)

        -- Внешность пассажира: сначала случайная одежда, затем чистим маску
        -- и ставим нормальную причёску — случайный вариант часто оставляет лысину
        SetPedRandomComponentVariation(p, 0)
        for prop = 0, 7 do ClearPedProp(p, prop) end
        SetPedComponentVariation(p, 1, 0, 0, 0)
        local hairCount = GetNumberOfPedDrawableVariations(p, 2)
        SetPedComponentVariation(p, 2, math.random(0, math.max(0, hairCount - 1)), 0, 0)
        SetPedHairColor(p, math.random(0, 45), math.random(0, 45))
        -- Лицо собираем как в редакторе: мать (женский диапазон) + отец (мужской)
        SetPedHeadBlendData(p, math.random(0, 20), math.random(21, 45), 0, math.random(0, 20), math.random(21, 45), 0, 1.0, 1.0, 0.0, false)
        FinalizeHeadBlend(p)

        RegisterEntityForCutscene(p, pedsList[i + 1], 0, 0, 64)
        cutscenePeds[#cutscenePeds + 1] = p
    end

    NewLoadSceneStartSphere(-1212.79, -1673.52, 7, 1000, 0)
    SetWeatherTypeNow('EXTRASUNNY')

    FreezeEntityPosition(playerPed, true)
    StartCutscene(4)

    Wait(Config.Arrival.cutsceneMs)

    -- Обрываем кат-сцену сразу после приземления и тут же уходим в затемнение:
    -- между сценой и появлением игрока не должно мелькать ни Vinewood, ни города
    if not HasCutsceneFinished() then
        StopCutsceneImmediately()
    end
    RemoveCutscene()
    DoScreenFadeOut(0)

    for _, p in ipairs(cutscenePeds) do
        if DoesEntityExist(p) then DeleteEntity(p) end
    end
    PrepareMusicEvent('AC_STOP')
    TriggerMusicEvent('AC_STOP')

    Wait(500)

    -- Игрок появляется в терминале лицом к Mike
    local pos = Config.Arrival.playerPos
    SetEntityCoords(playerPed, pos.x, pos.y, pos.z)
    SetEntityHeading(playerPed, pos.w)
    SetEntityVisible(playerPed, true)
    FreezeEntityPosition(playerPed, false)
    ClearPedTasksImmediately(playerPed)
    SetWeatherTypeNow('EXTRASUNNY')
    DisplayRadar(true)
    DoScreenFadeIn(700)
    Wait(700)

    -- Быстрый наезд камерой на наставника — и сразу назад
    local mikeCoords
    if npc and DoesEntityExist(npc) then
        mikeCoords = GetEntityCoords(npc)
    else
        mikeCoords = vector3(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
    end

    local cam = CreateCamWithParams('DEFAULT_SCRIPTED_CAMERA', pos.x + 0.4, pos.y + 0.4, pos.z + 1.6, 0.0, 0.0, 0.0, 50.0, false, 0)
    PointCamAtCoord(cam, mikeCoords.x, mikeCoords.y, mikeCoords.z + 1.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 300, true, true)

    for fov = 50, 38, -1 do
        SetCamFov(cam, fov + 0.0)
        Wait(45)
    end
    Wait(900)
    RenderScriptCams(false, true, 700, true, true)
    Wait(700)
    DestroyCam(cam, true)

    -- Игрок свободен: HUD и чат включаются
    TriggerEvent('qb-weathersync:client:EnableSync')
    LocalPlayer.state:set('buSelecting', false, true)
    refreshQuest()
end)

RegisterNUICallback('advance', function(_, cb)
    advanced = true
    TriggerServerEvent('bu-tutorial:server:advance')
    cb('ok')
end)

RegisterNUICallback('close', function(_, cb)
    dialogOpen = false
    SetNuiFocus(false, false)
    cb('ok')
end)
