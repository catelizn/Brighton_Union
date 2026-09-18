local QBCore = exports['qb-core']:GetCoreObject()

local lastAction = {}

local RED_NUMBERS = {
    [1] = true, [3] = true, [5] = true, [7] = true, [9] = true,
    [12] = true, [14] = true, [16] = true, [18] = true, [19] = true,
    [21] = true, [23] = true, [25] = true, [27] = true, [30] = true,
    [32] = true, [34] = true, [36] = true
}

local function isCooldown(src)
    local now = os.clock()
    if lastAction[src] and now - lastAction[src] < Config.Cooldown then
        return true
    end
    lastAction[src] = now
    return false
end

local function settleBet(Player, total, winnings, reason)
    local net = winnings - total
    if net > 0 then
        Player.Functions.AddMoney('cash', net, reason .. '-win')
    elseif net < 0 then
        Player.Functions.RemoveMoney('cash', -net, reason)
    end
end

local function roulettePayout(bet, number)
    local amount = bet.amount
    local betType = bet.type
    local value = bet.value

    if betType == 'number' then
        return tonumber(value) == number and amount * 35 or 0
    end

    if betType == 'color' then
        if number == 0 then return 0 end
        local isRed = RED_NUMBERS[number]
        if value == 'red' and isRed then return amount * 2 end
        if value == 'black' and not isRed then return amount * 2 end
        return 0
    end

    if betType == 'evenodd' then
        if number == 0 then return 0 end
        local isEven = number % 2 == 0
        if value == 'even' and isEven then return amount * 2 end
        if value == 'odd' and not isEven then return amount * 2 end
        return 0
    end

    if betType == 'half' then
        if number == 0 then return 0 end
        if value == 'low' and number >= 1 and number <= 18 then return amount * 2 end
        if value == 'high' and number >= 19 and number <= 36 then return amount * 2 end
        return 0
    end

    if betType == 'dozen' then
        if number == 0 then return 0 end
        local dozen = math.ceil(number / 12)
        return tonumber(value) == dozen and amount * 3 or 0
    end

    if betType == 'column' then
        if number == 0 then return 0 end
        local column = ((number - 1) % 3) + 1
        return tonumber(value) == column and amount * 3 or 0
    end

    return 0
end

QBCore.Functions.CreateCallback('bu-casino:server:getInfo', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return cb(nil) end
    cb({ cash = Player.PlayerData.money.cash or 0, minBet = Config.MinBet, maxBet = Config.MaxBet })
end)

RegisterNetEvent('bu-casino:server:roulette', function(bet)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if isCooldown(src) then return end

    if type(bet) ~= 'table' then return end
    local amount = tonumber(bet.amount)
    if not amount or amount < Config.MinBet or amount > Config.MaxBet then
        TriggerClientEvent('bu-casino:client:notify', src, 'Некорректная ставка.', 'error')
        return
    end
    if not bet.type or not bet.value then
        TriggerClientEvent('bu-casino:client:notify', src, 'Выбери, на что ставишь.', 'error')
        return
    end

    if (Player.PlayerData.money.cash or 0) < amount then
        TriggerClientEvent('bu-casino:client:notify', src, 'Недостаточно наличных.', 'error')
        return
    end

    local number = math.random(0, 36)
    local winnings = roulettePayout({ type = bet.type, value = bet.value, amount = amount }, number)

    settleBet(Player, amount, winnings, 'casino-roulette')

    TriggerClientEvent('bu-casino:client:rouletteResult', src, {
        number = number,
        color = number == 0 and 'green' or (RED_NUMBERS[number] and 'red' or 'black'),
        winnings = winnings,
        cash = Player.PlayerData.money.cash
    })
end)

RegisterNetEvent('bu-casino:server:slots', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if isCooldown(src) then return end

    amount = tonumber(amount)
    if not amount or amount < Config.MinBet or amount > Config.MaxBet then
        TriggerClientEvent('bu-casino:client:notify', src, 'Некорректная ставка.', 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < amount then
        TriggerClientEvent('bu-casino:client:notify', src, 'Недостаточно наличных.', 'error')
        return
    end

    local reel1 = math.random(1, 6)
    local reel2 = math.random(1, 6)
    local reel3 = math.random(1, 6)

    local winnings = 0
    if reel1 == reel2 and reel2 == reel3 then
        winnings = amount * Config.SlotPayouts[reel1]
    end

    settleBet(Player, amount, winnings, 'casino-slots')

    TriggerClientEvent('bu-casino:client:slotsResult', src, {
        reels = { reel1, reel2, reel3 },
        winnings = winnings,
        cash = Player.PlayerData.money.cash
    })
end)

-- ============================================================
-- Блэкджек
-- ============================================================

local blackjackStates = {}
local SUITS = { '♠', '♥', '♦', '♣' }
local CARD_FACES = { 'A', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K' }

local function newDeck()
    local deck = {}
    for _ = 1, 4 do
        for face = 1, 13 do
            for suite = 1, 4 do
                deck[#deck + 1] = { face = face, suite = suite, value = math.min(face, 10) }
            end
        end
    end
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    return deck
end

local function drawCard(state, who)
    local card = table.remove(state.deck)
    if not card then
        state.deck = newDeck()
        card = table.remove(state.deck)
    end
    local hand = who == 'player' and state.playerCards or state.dealerCards
    hand[#hand + 1] = card
    return card
end

local function handValue(cards)
    local total, aces = 0, 0
    for i = 1, #cards do
        local card = cards[i]
        if card.face == 1 then
            aces = aces + 1
            total = total + 11
        else
            total = total + card.value
        end
    end
    while total > 21 and aces > 0 do
        total = total - 10
        aces = aces - 1
    end
    return total
end

local function cardsToString(cards, hideSecond)
    local list = {}
    for i = 1, #cards do
        if hideSecond and i == 2 then
            list[#list + 1] = '?'
        else
            local card = cards[i]
            list[#list + 1] = CARD_FACES[card.face] .. SUITS[card.suite]
        end
    end
    return list
end

local function sendBlackjackState(src, status)
    local state = blackjackStates[src]
    if not state then return end
    local Player = QBCore.Functions.GetPlayer(src)

    TriggerClientEvent('bu-casino:client:blackjackState', src, {
        playerCards = cardsToString(state.playerCards),
        dealerCards = cardsToString(state.dealerCards, status == 'playing'),
        playerValue = handValue(state.playerCards),
        dealerValue = status == 'playing' and 0 or handValue(state.dealerCards),
        status = status,
        cash = Player.PlayerData.money.cash,
        bet = state.bet
    })
end

local function finishBlackjack(src, Player)
    local state = blackjackStates[src]
    if not state then return end

    local playerValue = handValue(state.playerCards)
    local dealerValue = handValue(state.dealerCards)

    local status = 'lose'
    local winnings = 0

    if playerValue > 21 then
        status = 'bust'
    elseif dealerValue > 21 or playerValue > dealerValue then
        status = 'win'
        if playerValue == 21 and #state.playerCards == 2 then
            winnings = math.floor(state.bet * 2.5)
        else
            winnings = state.bet * 2
        end
    elseif playerValue == dealerValue then
        status = 'push'
        winnings = state.bet
    else
        status = 'lose'
    end

    settleBet(Player, state.bet, winnings, 'casino-blackjack')
    blackjackStates[src] = nil

    TriggerClientEvent('bu-casino:client:blackjackState', src, {
        playerCards = cardsToString(state.playerCards),
        dealerCards = cardsToString(state.dealerCards),
        playerValue = playerValue,
        dealerValue = dealerValue,
        status = status,
        cash = Player.PlayerData.money.cash,
        bet = state.bet
    })
end

RegisterNetEvent('bu-casino:server:blackjackStart', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    if isCooldown(src) then return end

    amount = tonumber(amount)
    if not amount or amount < Config.MinBet or amount > Config.MaxBet then
        TriggerClientEvent('bu-casino:client:notify', src, 'Некорректная ставка.', 'error')
        return
    end
    if blackjackStates[src] then
        TriggerClientEvent('bu-casino:client:notify', src, 'Раунд уже идёт.', 'error')
        return
    end
    if (Player.PlayerData.money.cash or 0) < amount then
        TriggerClientEvent('bu-casino:client:notify', src, 'Недостаточно наличных.', 'error')
        return
    end

    local state = {
        deck = newDeck(),
        playerCards = {},
        dealerCards = {},
        bet = amount
    }
    drawCard(state, 'player')
    drawCard(state, 'dealer')
    drawCard(state, 'player')
    drawCard(state, 'dealer')

    blackjackStates[src] = state

    if handValue(state.playerCards) == 21 then
        finishBlackjack(src, Player)
    else
        sendBlackjackState(src, 'playing')
    end
end)

RegisterNetEvent('bu-casino:server:blackjackHit', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local state = blackjackStates[src]
    if not state then return end

    drawCard(state, 'player')
    if handValue(state.playerCards) > 21 then
        finishBlackjack(src, Player)
    else
        sendBlackjackState(src, 'playing')
    end
end)

RegisterNetEvent('bu-casino:server:blackjackStand', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local state = blackjackStates[src]
    if not state then return end

    while handValue(state.dealerCards) < 17 do
        drawCard(state, 'dealer')
    end

    finishBlackjack(src, Player)
end)

-- ============================================================
-- Покер (Техасский холдем, только игроки)
-- ============================================================

local pokerTables = {}
local pokerNextId = 1
local pokerTurnTimers = {}

local CARD_FACES = { '2', '3', '4', '5', '6', '7', '8', '9', '10', 'J', 'Q', 'K', 'A' }
local SUITS = { '♠', '♥', '♦', '♣' }

local function newDeck()
    local deck = {}
    for i = 1, 13 do
        for s = 1, 4 do
            deck[#deck + 1] = { rank = i, suit = s }
        end
    end
    for i = #deck, 2, -1 do
        local j = math.random(i)
        deck[i], deck[j] = deck[j], deck[i]
    end
    return deck
end

local function pokerCardText(card)
    if not card then return '' end
    return CARD_FACES[card.rank] .. SUITS[card.suit]
end

local function pokerEvaluate(cards)
    -- Возвращает { strength = 0..8, kickers = {...} }: старшая карта ... стрит-флеш
    local ranks = {}
    local suits = {}
    for i = 1, #cards do
        ranks[#ranks + 1] = cards[i].rank
        suits[#suits + 1] = cards[i].suit
    end
    table.sort(ranks, function(a, b) return a > b end)

    local count = {}
    for i = 1, #ranks do
        count[ranks[i]] = (count[ranks[i]] or 0) + 1
    end

    local flush = true
    for i = 2, #suits do
        if suits[i] ~= suits[1] then flush = false end
    end

    local unique = {}
    for i = 1, #ranks do
        if unique[#unique] ~= ranks[i] then unique[#unique + 1] = ranks[i] end
    end

    local straight = false
    local straightHigh = 0
    if #unique >= 5 then
        for i = 1, #unique - 4 do
            if unique[i] - unique[i + 4] == 4 then
                straight = true
                straightHigh = unique[i]
            end
        end
        if not straight and unique[1] == 14 and unique[2] == 5 and unique[3] == 4 and unique[4] == 3 and unique[5] == 2 then
            straight = true
            straightHigh = 5
        end
    end

    local quads = 0
    local trips = 0
    local pairs = {}
    for rank, c in pairs(count) do
        if c == 4 then quads = rank end
        if c == 3 then trips = rank end
        if c == 2 then pairs[#pairs + 1] = rank end
    end
    table.sort(pairs, function(a, b) return a > b end)

    local kickers = {}
    for i = 1, #unique do
        if unique[i] ~= quads and unique[i] ~= trips and not (pairs[1] == unique[i] or pairs[2] == unique[i]) then
            kickers[#kickers + 1] = unique[i]
        end
    end

    if flush and straight then
        return { strength = 8, high = straightHigh }
    end
    if quads > 0 then
        return { strength = 7, rank = quads, kicker = kickers[1] or 0 }
    end
    if trips > 0 and #pairs >= 1 then
        return { strength = 6, rank = trips, pair = pairs[1] }
    end
    if flush then
        return { strength = 5, kickers = { unique[1], unique[2], unique[3], unique[4], unique[5] } }
    end
    if straight then
        return { strength = 4, high = straightHigh }
    end
    if trips > 0 then
        return { strength = 3, rank = trips, kickers = { kickers[1] or 0, kickers[2] or 0 } }
    end
    if #pairs >= 2 then
        return { strength = 2, high = pairs[1], low = pairs[2], kicker = kickers[1] or 0 }
    end
    if #pairs == 1 then
        return { strength = 1, rank = pairs[1], kickers = { kickers[1] or 0, kickers[2] or 0, kickers[3] or 0 } }
    end
    return { strength = 0, kickers = { unique[1], unique[2], unique[3], unique[4], unique[5] } }
end

local function pokerCompare(a, b)
    if a.strength ~= b.strength then return a.strength > b.strength end
    if a.strength == 8 or a.strength == 4 then
        if a.high ~= b.high then return a.high > b.high end
        return true
    end
    if a.strength == 7 then
        if a.rank ~= b.rank then return a.rank > b.rank end
        return a.kicker >= b.kicker
    end
    if a.strength == 6 then
        if a.rank ~= b.rank then return a.rank > b.rank end
        return a.pair >= b.pair
    end
    if a.strength == 3 then
        if a.rank ~= b.rank then return a.rank > b.rank end
        for i = 1, 2 do
            if a.kickers[i] ~= b.kickers[i] then return a.kickers[i] > b.kickers[i] end
        end
        return true
    end
    if a.strength == 2 then
        if a.high ~= b.high then return a.high > b.high end
        if a.low ~= b.low then return a.low > b.low end
        return a.kicker >= b.kicker
    end
    if a.strength == 1 then
        if a.rank ~= b.rank then return a.rank > b.rank end
        for i = 1, 3 do
            if a.kickers[i] ~= b.kickers[i] then return a.kickers[i] > b.kickers[i] end
        end
        return true
    end
    for i = 1, 5 do
        if a.kickers[i] ~= b.kickers[i] then return a.kickers[i] > b.kickers[i] end
    end
    return true
end

local function sendPokerState(tableId)
    local tableData = pokerTables[tableId]
    if not tableData then return end

    for seat, player in pairs(tableData.seats) do
        local Player = QBCore.Functions.GetPlayerByCitizenId(player.cid)
        if Player then
            local src = Player.PlayerData.source
            local seats = {}
            for s, p in pairs(tableData.seats) do
                seats[s] = {
                    name = p.name,
                    chips = p.chips,
                    folded = p.folded,
                    current = s == tableData.turn
                }
            end
            local community = {}
            for i = 1, #tableData.community do
                community[#community + 1] = pokerCardText(tableData.community[i])
            end
            local hand = {}
            for i = 1, #player.cards do
                hand[#hand + 1] = pokerCardText(player.cards[i])
            end

            TriggerClientEvent('bu-casino:client:pokerState', src, {
                tableId = tableId,
                state = tableData.state,
                seats = seats,
                community = community,
                hand = hand,
                pot = tableData.pot,
                currentBet = tableData.currentBet,
                yourBet = player.bet,
                yourSeat = seat,
                canAct = tableData.state == 'playing' and tableData.turn == seat and not player.folded and player.cards and #player.cards > 0
            })
        end
    end
end

QBCore.Functions.CreateCallback('bu-casino:server:getPokerTables', function(source, cb)
    local list = {}
    for id, tableData in pairs(pokerTables) do
        local players = 0
        for _ in pairs(tableData.seats) do players = players + 1 end
        if players > 0 then
            list[#list + 1] = { id = id, buyIn = tableData.buyIn, players = players, state = tableData.state }
        end
    end
    cb(list)
end)

RegisterNetEvent('bu-casino:server:pokerCreate', function(buyIn)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    buyIn = tonumber(buyIn)
    if not buyIn or buyIn < Config.MinBet or buyIn > Config.MaxBet then
        TriggerClientEvent('bu-casino:client:notify', src, string.format('Бай-ин — от $%d до $%d.', Config.MinBet, Config.MaxBet), 'error')
        return
    end

    if Player.PlayerData.money.bank < buyIn then
        TriggerClientEvent('bu-casino:client:notify', src, 'Недостаточно средств на банковском счёте.', 'error')
        return
    end

    Player.Functions.RemoveMoney('bank', buyIn, 'casino-poker-buyin')

    local id = pokerNextId
    pokerNextId = pokerNextId + 1
    pokerTables[id] = {
        id = id,
        buyIn = buyIn,
        state = 'waiting',
        seats = {},
        deck = {},
        community = {},
        pot = 0,
        currentBet = 0,
        dealer = 0,
        turn = 0,
        players = {}
    }

    TriggerClientEvent('bu-casino:client:notify', src, 'Стол покера создан. Дождись второго игрока и нажми «Старт».', 'success')
end)

RegisterNetEvent('bu-casino:server:pokerJoin', function(tableId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local tableData = pokerTables[tonumber(tableId)]
    if not tableData then
        TriggerClientEvent('bu-casino:client:notify', src, 'Стол не найден.', 'error')
        return
    end
    if tableData.state ~= 'waiting' then
        TriggerClientEvent('bu-casino:client:notify', src, 'Игра уже идёт.', 'error')
        return
    end

    local cid = Player.PlayerData.citizenid
    for seat, player in pairs(tableData.seats) do
        if player.cid == cid then
            TriggerClientEvent('bu-casino:client:notify', src, 'Ты уже за столом.', 'error')
            return
        end
    end
    local seatCount = 0
    for _ in pairs(tableData.seats) do seatCount = seatCount + 1 end
    if seatCount >= 6 then
        TriggerClientEvent('bu-casino:client:notify', src, 'Стол полный.', 'error')
        return
    end

    if Player.PlayerData.money.bank < tableData.buyIn then
        TriggerClientEvent('bu-casino:client:notify', src, 'Недостаточно средств на банковском счёте.', 'error')
        return
    end
    Player.Functions.RemoveMoney('bank', tableData.buyIn, 'casino-poker-buyin')

    local seat = 1
    while tableData.seats[seat] do seat = seat + 1 end

    tableData.seats[seat] = {
        cid = cid,
        name = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or ''),
        chips = tableData.buyIn,
        folded = false,
        bet = 0,
        cards = {}
    }
    tableData.players[#tableData.players + 1] = seat

    sendPokerState(tableId)
    TriggerClientEvent('bu-casino:client:notify', src, 'Ты за столом покера.', 'success')
end)

RegisterNetEvent('bu-casino:server:pokerStart', function(tableId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local tableData = pokerTables[tonumber(tableId)]
    if not tableData then return end
    if tableData.state ~= 'waiting' then return end

    local seatCount = 0
    for _ in pairs(tableData.seats) do seatCount = seatCount + 1 end
    if seatCount < 2 then
        TriggerClientEvent('bu-casino:client:notify', src, 'Нужно минимум два игрока.', 'error')
        return
    end

    tableData.deck = newDeck()
    tableData.community = {}
    tableData.pot = 0
    tableData.currentBet = 0

    local order = {}
    for seat in pairs(tableData.seats) do order[#order + 1] = seat end
    table.sort(order)
    tableData.players = order
    tableData.dealer = order[1]
    tableData.turn = order[2] or order[1]

    for _, seat in ipairs(order) do
        local player = tableData.seats[seat]
        player.folded = false
        player.bet = 0
        player.cards = { table.remove(tableData.deck), table.remove(tableData.deck) }
    end

    tableData.state = 'playing'
    tableData.round = 'preflop'

    sendPokerState(tableId)
end)

local function pokerEndRound(tableId)
    local tableData = pokerTables[tableId]
    if not tableData then return end

    local active = {}
    for _, seat in ipairs(tableData.players) do
        local player = tableData.seats[seat]
        if not player.folded then active[#active + 1] = seat end
    end

    if #active == 1 then
        local winner = tableData.seats[active[1]]
        winner.chips = winner.chips + tableData.pot
        tableData.pot = 0
        tableData.state = 'waiting'
        for _, seat in ipairs(tableData.players) do
            tableData.seats[seat].cards = {}
        end
        tableData.community = {}
        sendPokerState(tableId)
        return
    end

    if #tableData.community >= 5 then
        local best = nil
        local winners = {}
        for _, seat in ipairs(active) do
            local player = tableData.seats[seat]
            local all = {}
            for i = 1, #player.cards do all[#all + 1] = player.cards[i] end
            for i = 1, #tableData.community do all[#all + 1] = tableData.community[i] end
            local value = pokerEvaluate(all)
            if not best or pokerCompare(value, best) then
                best = value
                winners = { seat }
            end
        end
        local share = math.floor(tableData.pot / #winners)
        for _, seat in ipairs(winners) do
            tableData.seats[seat].chips = tableData.seats[seat].chips + share
        end
        tableData.pot = 0
        tableData.state = 'waiting'
        for _, seat in ipairs(tableData.players) do
            tableData.seats[seat].cards = {}
        end
        tableData.community = {}
        sendPokerState(tableId)
        return
    end

    if tableData.round == 'preflop' then
        tableData.community[#tableData.community + 1] = table.remove(tableData.deck)
        tableData.community[#tableData.community + 1] = table.remove(tableData.deck)
        tableData.community[#tableData.community + 1] = table.remove(tableData.deck)
        tableData.round = 'flop'
    elseif tableData.round == 'flop' then
        tableData.community[#tableData.community + 1] = table.remove(tableData.deck)
        tableData.round = 'turn'
    elseif tableData.round == 'turn' then
        tableData.community[#tableData.community + 1] = table.remove(tableData.deck)
        tableData.round = 'river'
    else
        return
    end

    tableData.currentBet = 0
    for _, seat in ipairs(tableData.players) do
        local player = tableData.seats[seat]
        player.bet = 0
    end
    tableData.turn = tableData.players[((tableData.dealer + 1) % #tableData.players) + 1]
    sendPokerState(tableId)
end

local function pokerNextTurn(tableId)
    local tableData = pokerTables[tableId]
    if not tableData or tableData.state ~= 'playing' then return end

    if pokerTurnTimers[tableId] then return end

    local order = tableData.players
    for i = 1, #order do
        local seat = order[((tableData.turn - 1 + i) % #order) + 1]
        local player = tableData.seats[seat]
        if not player.folded and #player.cards > 0 then
            tableData.turn = seat
            sendPokerState(tableId)

            local timerTable = tableId
            pokerTurnTimers[tableId] = true
            SetTimeout(90000, function()
                pokerTurnTimers[timerTable] = nil
                local current = pokerTables[timerTable]
                if current and current.state == 'playing' and current.turn == seat and not current.seats[seat].folded then
                    current.seats[seat].folded = true
                    pokerNextTurn(timerTable)
                end
            end)
            return
        end
    end

    pokerEndRound(tableId)
end

RegisterNetEvent('bu-casino:server:pokerAction', function(tableId, action)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local tableData = pokerTables[tonumber(tableId)]
    if not tableData or tableData.state ~= 'playing' then return end

    local player = tableData.seats[tableData.turn]
    if not player or player.cid ~= Player.PlayerData.citizenid then return end

    local minRaise = 50

    if action == 'fold' then
        player.folded = true
    elseif action == 'check' or action == 'call' then
        local needed = tableData.currentBet - player.bet
        if needed > 0 and player.chips < needed then
            needed = player.chips
        end
        player.chips = player.chips - needed
        player.bet = player.bet + needed
        tableData.pot = tableData.pot + needed
    elseif action == 'raise' then
        local raiseBy = math.max(minRaise, tableData.currentBet - player.bet + minRaise)
        if player.chips < raiseBy then raiseBy = player.chips end
        player.chips = player.chips - raiseBy
        player.bet = player.bet + raiseBy
        tableData.pot = tableData.pot + raiseBy
        tableData.currentBet = player.bet
    end

    pokerNextTurn(tableId)
end)

RegisterNetEvent('QBCore:Server:OnPlayerUnload', function(src)
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    local cid = Player.PlayerData.citizenid
    for _, tableData in pairs(pokerTables) do
        for seat, player in pairs(tableData.seats) do
            if player.cid == cid then
                tableData.seats[seat] = nil
                for i = #tableData.players, 1, -1 do
                    if tableData.players[i] == seat then table.remove(tableData.players, i) end
                end
                if tableData.state == 'playing' then
                    local active = 0
                    for _, s in ipairs(tableData.players) do
                        if not tableData.seats[s].folded then active = active + 1 end
                    end
                    if active <= 1 then pokerEndRound(tableData.id) end
                end
            end
        end
    end
end)

-- ============================================================
-- Мафия (игра для игроков)
-- ============================================================

local mafiaRooms = {}
local mafiaNextId = 1

local function mafiaNotify(cid, message, notifyType)
    local Player = QBCore.Functions.GetPlayerByCitizenId(cid)
    if Player then
        TriggerClientEvent('bu-casino:client:notify', Player.PlayerData.source, message, notifyType or 'primary')
    end
end

local function sendMafiaState(room)
    for _, member in ipairs(room.players) do
        local Player = QBCore.Functions.GetPlayerByCitizenId(member.cid)
        if Player then
            local players = {}
            for _, p in ipairs(room.players) do
                players[#players + 1] = { cid = p.cid, name = p.name, alive = p.alive, role = (room.state == 'ended' or p.cid == member.cid) and p.role or nil }
            end
            TriggerClientEvent('bu-casino:client:mafiaState', Player.PlayerData.source, {
                roomId = room.id,
                state = room.state,
                phase = room.phase,
                role = member.role,
                alive = member.alive,
                players = players,
                phaseEnds = room.phaseEnds,
                log = room.log,
                winner = room.winner
            })
        end
    end
end

local function mafiaPhaseEnd(roomId)
    local room = mafiaRooms[roomId]
    if not room then return end
    if room.state ~= 'night' and room.state ~= 'day' then return end

    if room.state == 'night' then
        local killed = nil
        local saved = room.nightSave
        for cid in pairs(room.nightKills) do
            if cid ~= saved then killed = cid end
        end
        if killed then
            for _, p in ipairs(room.players) do
                if p.cid == killed then p.alive = false end
            end
            room.log[#room.log + 1] = ('Ночью был убит %s.'):format(room.names[killed] or killed)
        else
            room.log[#room.log + 1] = 'Ночь прошла спокойно. Никто не погиб.'
        end

        local mafiaAlive = 0
        local townAlive = 0
        for _, p in ipairs(room.players) do
            if p.alive then
                if p.role == 'mafia' then mafiaAlive = mafiaAlive + 1 else townAlive = townAlive + 1 end
            end
        end
        if mafiaAlive == 0 then
            room.state = 'ended'
            room.winner = 'Мирные жители'
        elseif mafiaAlive >= townAlive then
            room.state = 'ended'
            room.winner = 'Мафия'
        else
            room.state = 'day'
            room.phase = 'day'
            room.phaseEnds = os.time() + 60
            room.dayVotes = {}
        end
        room.nightKills = {}
        room.nightSave = nil
        sendMafiaState(room)
        return
    end

    -- день: голосование
    local votes = {}
    for _, vote in pairs(room.dayVotes) do
        votes[vote] = (votes[vote] or 0) + 1
    end
    local best = nil
    local bestCount = 0
    for cid, count in pairs(votes) do
        if count > bestCount then
            best = cid
            bestCount = count
        elseif count == bestCount then
            best = nil
        end
    end
    if best then
        for _, p in ipairs(room.players) do
            if p.cid == best then p.alive = false end
        end
        room.log[#room.log + 1] = ('Город выгнал %s.'):format(room.names[best] or best)
    else
        room.log[#room.log + 1] = 'Город не смог выбрать, кого выгнать.'
    end

    local mafiaAlive = 0
    local townAlive = 0
    for _, p in ipairs(room.players) do
        if p.alive then
            if p.role == 'mafia' then mafiaAlive = mafiaAlive + 1 else townAlive = townAlive + 1 end
        end
    end
    if mafiaAlive == 0 then
        room.state = 'ended'
        room.winner = 'Мирные жители'
    elseif mafiaAlive >= townAlive then
        room.state = 'ended'
        room.winner = 'Мафия'
    else
        room.state = 'night'
        room.phase = 'night'
        room.phaseEnds = os.time() + 45
        room.nightKills = {}
        room.nightSave = nil
        room.nightChecks = {}
    end
    sendMafiaState(room)
end

CreateThread(function()
    while true do
        Wait(1000)
        local now = os.time()
        for roomId, room in pairs(mafiaRooms) do
            if (room.state == 'night' or room.state == 'day') and now >= room.phaseEnds then
                mafiaPhaseEnd(roomId)
            end
        end
    end
end)

QBCore.Functions.CreateCallback('bu-casino:server:getMafiaRooms', function(_, cb)
    local list = {}
    for id, room in pairs(mafiaRooms) do
        if room.state == 'lobby' then
            list[#list + 1] = { id = id, players = #room.players }
        end
    end
    cb(list)
end)

RegisterNetEvent('bu-casino:server:mafiaCreate', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local id = mafiaNextId
    mafiaNextId = mafiaNextId + 1

    mafiaRooms[id] = {
        id = id,
        state = 'lobby',
        phase = 'lobby',
        players = { {
            cid = Player.PlayerData.citizenid,
            name = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or ''),
            role = 'town',
            alive = true
        } },
        names = {},
        log = {},
        nightKills = {},
        nightSave = nil,
        dayVotes = {}
    }

    TriggerClientEvent('bu-casino:client:notify', src, 'Комната мафии создана. Жди игроков.', 'success')
    sendMafiaState(mafiaRooms[id])
end)

RegisterNetEvent('bu-casino:server:mafiaJoin', function(roomId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local room = mafiaRooms[tonumber(roomId)]
    if not room or room.state ~= 'lobby' then
        TriggerClientEvent('bu-casino:client:notify', src, 'Комната не найдена или игра уже идёт.', 'error')
        return
    end

    local cid = Player.PlayerData.citizenid
    for _, p in ipairs(room.players) do
        if p.cid == cid then
            TriggerClientEvent('bu-casino:client:notify', src, 'Ты уже в комнате.', 'error')
            return
        end
    end
    if #room.players >= 10 then
        TriggerClientEvent('bu-casino:client:notify', src, 'Комната полная.', 'error')
        return
    end

    room.players[#room.players + 1] = {
        cid = cid,
        name = ((Player.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((Player.PlayerData.charinfo or {}).lastname or ''),
        role = 'town',
        alive = true
    }
    TriggerClientEvent('bu-casino:client:notify', src, 'Ты в комнате мафии.', 'success')
    sendMafiaState(room)
end)

RegisterNetEvent('bu-casino:server:mafiaStart', function(roomId)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local room = mafiaRooms[tonumber(roomId)]
    if not room or room.state ~= 'lobby' then return end
    if room.players[1].cid ~= Player.PlayerData.citizenid then
        TriggerClientEvent('bu-casino:client:notify', src, 'Стартовать может только создатель комнаты.', 'error')
        return
    end
    if #room.players < 4 then
        TriggerClientEvent('bu-casino:client:notify', src, 'Нужно минимум 4 игрока.', 'error')
        return
    end

    local count = #room.players
    local mafiaCount = math.max(1, math.floor(count / 4))
    local shuffled = {}
    for i = 1, count do shuffled[i] = i end
    for i = count, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end

    for i = 1, count do
        local player = room.players[shuffled[i]]
        if i <= mafiaCount then
            player.role = 'mafia'
        elseif i == mafiaCount + 1 then
            player.role = 'doctor'
        elseif i == mafiaCount + 2 then
            player.role = 'sheriff'
        else
            player.role = 'town'
        end
        player.alive = true
        room.names[player.cid] = player.name
    end

    room.log = { 'Игра началась. Ночь.' }
    room.state = 'night'
    room.phase = 'night'
    room.phaseEnds = os.time() + 45
    room.nightKills = {}
    room.nightSave = nil
    room.dayVotes = {}

    sendMafiaState(room)
end)

RegisterNetEvent('bu-casino:server:mafiaAction', function(roomId, action, targetCid)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    local room = mafiaRooms[tonumber(roomId)]
    if not room then return end

    local member = nil
    for _, p in ipairs(room.players) do
        if p.cid == Player.PlayerData.citizenid then member = p end
    end
    if not member or not member.alive then return end

    if room.state == 'night' then
        if action == 'kill' and member.role == 'mafia' then
            room.nightKills[targetCid] = true
            mafiaNotify(member.cid, 'Цель мафии выбрана.', 'inform')
        elseif action == 'save' and member.role == 'doctor' then
            room.nightSave = targetCid
            mafiaNotify(member.cid, 'Ты будешь лечить выбранного игрока.', 'inform')
        elseif action == 'check' and member.role == 'sheriff' then
            local target = nil
            for _, p in ipairs(room.players) do
                if p.cid == targetCid then target = p end
            end
            if target then
                local isMafia = target.role == 'mafia'
                mafiaNotify(member.cid, isMafia and 'Проверка: это мафия.' or 'Проверка: это мирный житель.', 'inform')
            end
        end
    elseif room.state == 'day' then
        if action == 'vote' then
            room.dayVotes[Player.PlayerData.citizenid] = targetCid
            mafiaNotify(member.cid, 'Голос отдан.', 'inform')
        end
    end

    sendMafiaState(room)
end)
