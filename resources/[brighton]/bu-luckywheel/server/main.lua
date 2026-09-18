local QBCore = exports['qb-core']:GetCoreObject()

local lastSpin = {}

QBCore.Functions.CreateCallback('bu-luckywheel:server:spin', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end

    local cid = Player.PlayerData.citizenid
    local now = os.time()

    if lastSpin[cid] and (now - lastSpin[cid]) < Config.Cooldown then
        return cb({ error = 'wait' })
    end

    if Player.Functions.GetMoney('cash') < Config.Cost then
        return cb({ error = 'money' })
    end

    Player.Functions.RemoveMoney('cash', Config.Cost, 'luckywheel-spin')

    local idx = math.random(1, #Config.Rewards)
    local reward = Config.Rewards[idx]

    if reward.type == 'cash' then
        Player.Functions.AddMoney(reward.kind or 'cash', reward.amount, 'luckywheel-' .. idx)
    end

    lastSpin[cid] = now
    cb({ ok = true, index = idx, reward = reward })
end)
