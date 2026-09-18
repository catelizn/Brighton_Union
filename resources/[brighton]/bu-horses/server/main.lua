local QBCore = exports['qb-core']:GetCoreObject()

local race = { active = false, stage = nil, stageUntil = 0, bets = {}, pool = 0, winner = nil, lastWinner = nil }

local function pickWinner()
    local total = 0
    for _, w in ipairs(Config.Weights) do total = total + w end
    local r = math.random(1, total)
    local acc = 0
    for i = 1, #Config.Weights do
        acc = acc + Config.Weights[i]
        if r <= acc then return i end
    end
    return #Config.Weights
end

QBCore.Functions.CreateCallback('bu-horses:server:getState', function(source, cb)
    cb({
        active = race.active,
        stage = race.stage,
        pool = race.pool,
        horses = Config.Horses,
        lastWinner = race.lastWinner
    })
end)

RegisterNetEvent('bu-horses:server:placeBet', function(horseIdx, amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if not race.active or race.stage ~= 'betting' then
        TriggerClientEvent('QBCore:Notify', src, 'Ставки сейчас закрыты.', 'error')
        return
    end

    horseIdx = tonumber(horseIdx)
    amount = tonumber(amount)
    if not Config.Horses[horseIdx] then return end
    if not amount or amount < Config.BetMin or amount > Config.BetMax or amount % 100 ~= 0 then
        TriggerClientEvent('QBCore:Notify', src, string.format('Ставка от $%d до $%d, кратна 100.', Config.BetMin, Config.BetMax), 'error')
        return
    end

    local cid = Player.PlayerData.citizenid
    if race.bets[cid] then
        TriggerClientEvent('QBCore:Notify', src, 'Ты уже сделал ставку в этом заезде.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < amount then
        TriggerClientEvent('QBCore:Notify', src, 'Недостаточно наличных.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', amount, 'horses-bet')
    race.bets[cid] = { horse = horseIdx, amount = amount }
    race.pool = race.pool + amount
    TriggerClientEvent('QBCore:Notify', src, string.format('Ставка на «%s» принята.', Config.Horses[horseIdx].name), 'primary')
end)

CreateThread(function()
    while true do
        Wait(1000)

        if not race.active then
            race.active = true
            race.stage = 'betting'
            race.stageUntil = os.time() + Config.BetWindow
            race.bets = {}
            race.pool = 0
            race.winner = nil
        end

        if race.active and race.stage == 'betting' and os.time() >= race.stageUntil then
            race.stage = 'racing'
            race.stageUntil = os.time() + Config.RaceLength
            TriggerClientEvent('bu-horses:client:startRace', -1)
        end

        if race.active and race.stage == 'racing' and os.time() >= race.stageUntil then
            local winner = pickWinner()
            race.winner = winner
            race.lastWinner = Config.Horses[winner].name

            local winPool = 0
            for _, b in pairs(race.bets) do
                if b.horse == winner then winPool = winPool + b.amount end
            end
            if winPool > 0 then
                local ratio = race.pool / winPool
                for cid, b in pairs(race.bets) do
                    if b.horse == winner then
                        local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
                        if Player then
                            local pay = math.floor(b.amount * ratio)
                            Player.Functions.AddMoney('bank', pay, 'horses-win')
                            TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, string.format('Победила «%s». Выигрыш: $%d на счёт.', Config.Horses[winner].name, pay), 'success')
                        end
                    end
                end
            else
                for cid in pairs(race.bets) do
                    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
                    if Player then
                        TriggerClientEvent('QBCore:Notify', Player.PlayerData.source, string.format('Заезд завершён: победила «%s». Ставок на неё не было.', Config.Horses[winner].name), 'primary')
                    end
                end
            end

            race.active = false
            race.stage = nil
            TriggerClientEvent('bu-horses:client:reset', -1)
        end
    end
end)
