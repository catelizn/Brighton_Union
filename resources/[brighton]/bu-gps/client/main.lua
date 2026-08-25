-- Навигатор: подсказки по пути к метке на карте.
-- Текстовая версия «Алисы»: повороты и дистанция. Голосовые файлы
-- подключаются отдельно (см. README).

local lastHint = ''
local hintTimer = 0

local function waypoint()
    local blip = GetFirstBlipInfoId(8)
    if blip == 0 then return nil end
    return GetBlipInfoIdCoord(blip)
end

local function bearing(from, to)
    local dx, dy = to.x - from.x, to.y - from.y
    return (90 - math.deg(math.atan(dy, dx))) % 360
end

local function turnHint(angleDiff, distance)
    if distance < 40 then return 'Вы прибыли к месту назначения' end
    if angleDiff > 25 then return 'Поверните направо' end
    if angleDiff < -25 then return 'Поверните налево' end
    return 'Продолжайте движение прямо'
end

local function drawHint(text)
    SetTextFont(4)
    SetTextScale(0.42, 0.42)
    SetTextColour(226, 232, 240, 235)
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    EndTextCommandDisplayText(0.5, 0.64)
end

CreateThread(function()
    while true do
        Wait(300)

        local target = waypoint()
        if not target then
            if lastHint ~= '' then lastHint = '' end
            Wait(500)
        else
            local playerPed = PlayerPedId()
            local pos = GetEntityCoords(playerPed)
            local distance = #(pos - target)

            if distance > 40 then
                local targetBearing = bearing(pos, target)
                local diff = (targetBearing - GetEntityHeading(playerPed) + 540) % 360 - 180
                local hint = turnHint(diff, distance)
                if hint ~= lastHint then
                    lastHint = hint
                    hintTimer = 6
                end
                if hintTimer > 0 then
                    hintTimer = hintTimer - 1
                    drawHint(hint .. ' · ' .. math.floor(distance) .. ' м')
                end
            else
                drawHint('Вы прибыли к месту назначения')
            end
        end
    end
end)
