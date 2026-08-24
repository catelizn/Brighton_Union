const overlay = document.getElementById('overlay');
const cashLabel = document.getElementById('cash');
const rouletteWheel = document.getElementById('roulette-wheel');
const resultBox = document.getElementById('result');

const bets = [
    { type: 'color', value: 'red', label: 'Красное' },
    { type: 'color', value: 'black', label: 'Чёрное' },
    { type: 'evenodd', value: 'even', label: 'Чёт' },
    { type: 'evenodd', value: 'odd', label: 'Нечёт' },
    { type: 'half', value: 'low', label: '1–18' },
    { type: 'half', value: 'high', label: '19–36' },
    { type: 'dozen', value: '1', label: 'Дюжина 1' },
    { type: 'dozen', value: '2', label: 'Дюжина 2' },
    { type: 'dozen', value: '3', label: 'Дюжина 3' },
    { type: 'column', value: '1', label: 'Колонка 1' },
    { type: 'column', value: '2', label: 'Колонка 2' },
    { type: 'column', value: '3', label: 'Колонка 3' },
    { type: 'number', value: '0', label: 'Ноль (0)' },
    { type: 'number', value: '17', label: 'Число 17' },
    { type: 'number', value: '36', label: 'Число 36' }
];

let selectedBet = null;
let minBet = 50;
let maxBet = 50000;
let busy = false;

function post(action, data) {
    fetch(`https://bu-casino/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

function setCash(value) {
    cashLabel.textContent = '$' + Number(value || 0).toLocaleString('ru-RU');
}

function showResult(text, type) {
    resultBox.textContent = text;
    resultBox.className = 'result ' + (type || '');
}

function renderBetGrid() {
    const grid = document.getElementById('bet-grid');
    grid.innerHTML = '';
    bets.forEach((bet) => {
        const button = document.createElement('button');
        button.className = 'bet-button';
        button.textContent = bet.label;
        button.addEventListener('click', () => {
            selectedBet = bet;
            grid.querySelectorAll('.bet-button').forEach((other) => other.classList.remove('selected'));
            button.classList.add('selected');
        });
        grid.appendChild(button);
    });
}

function switchGame(game) {
    document.querySelectorAll('.tab').forEach((tab) => tab.classList.toggle('active', tab.dataset.game === game));
    document.getElementById('game-roulette').classList.toggle('hidden', game !== 'roulette');
    document.getElementById('game-slots').classList.toggle('hidden', game !== 'slots');
    document.getElementById('game-blackjack').classList.toggle('hidden', game !== 'blackjack');
    document.getElementById('game-poker').classList.toggle('hidden', game !== 'poker');
    document.getElementById('game-mafia').classList.toggle('hidden', game !== 'mafia');
    if (game === 'poker') post('getPokerTables');
    if (game === 'mafia') post('getMafiaRooms');
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:casino:open') {
        minBet = message.data.minBet;
        maxBet = message.data.maxBet;
        setCash(message.data.cash);
        document.getElementById('bet-amount').min = minBet;
        document.getElementById('slot-amount').min = minBet;
        showResult('Сделай ставку и крути.', '');
        overlay.classList.add('visible');
    }

    if (message.type === 'bu:casino:close') {
        overlay.classList.remove('visible');
    }

    if (message.type === 'bu:casino:rouletteResult') {
        busy = false;
        const data = message.data;
        rouletteWheel.textContent = data.number;
        rouletteWheel.className = 'roulette-wheel ' + data.color;
        setCash(data.cash);
        if (data.winnings > 0) {
            showResult(`Выпало ${data.number} — выигрыш $${data.winnings.toLocaleString('ru-RU')}!`, 'win');
        } else {
            showResult(`Выпало ${data.number} — ставка проиграна.`, 'lose');
        }
    }

    if (message.type === 'bu:casino:slotsResult') {
        busy = false;
        const data = message.data;
        const symbols = ['7', '🍒', '🍋', '🔔', '💎', '🍀'];
        document.getElementById('reel-1').textContent = symbols[data.reels[0] - 1];
        document.getElementById('reel-2').textContent = symbols[data.reels[1] - 1];
        document.getElementById('reel-3').textContent = symbols[data.reels[2] - 1];
        document.querySelectorAll('.reel').forEach((reel) => reel.classList.remove('spinning'));
        setCash(data.cash);
        if (data.winnings > 0) {
            showResult(`Три в ряд — выигрыш $${data.winnings.toLocaleString('ru-RU')}!`, 'win');
        } else {
            showResult('Не повезло. Попробуй ещё раз!', 'lose');
        }
    }

    if (message.type === 'bu:casino:blackjackState') {
        busy = false;
        const data = message.data;
        setCash(data.cash);

        renderCards('player-cards', data.playerCards);
        renderCards('dealer-cards', data.dealerCards);
        document.getElementById('player-value').textContent = data.playerValue;
        document.getElementById('dealer-value').textContent = data.dealerValue || '—';

        const playing = data.status === 'playing';
        document.getElementById('bj-hit').disabled = !playing;
        document.getElementById('bj-stand').disabled = !playing;
        document.getElementById('bj-start').disabled = playing;

        if (!playing) {
            const texts = {
                win: 'Победа!',
                bust: 'Перебор — ты проиграл.',
                push: 'Ничья — ставка возвращена.',
                lose: 'Дилер выиграл.'
            };
            const type = data.status === 'win' ? 'win' : 'lose';
            showResult(texts[data.status] || '', type);
        } else {
            showResult('Твой ход.', '');
        }
    }

    if (message.type === 'bu:casino:pokerTables') {
        renderPokerTables(message.data);
    }

    if (message.type === 'bu:casino:pokerState') {
        renderPokerState(message.data);
    }

    if (message.type === 'bu:casino:mafiaRooms') {
        renderMafiaRooms(message.data);
    }

    if (message.type === 'bu:casino:mafiaState') {
        renderMafiaState(message.data);
    }
});

document.getElementById('close-button').addEventListener('click', () => post('close'));

document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => switchGame(tab.dataset.game));
});

document.getElementById('spin-roulette').addEventListener('click', () => {
    if (busy) return;
    if (!selectedBet) {
        showResult('Выбери, на что ставишь.', 'lose');
        return;
    }
    const amount = Number(document.getElementById('bet-amount').value);
    if (!amount || amount < minBet || amount > maxBet) {
        showResult(`Ставка от $${minBet} до $${maxBet.toLocaleString('ru-RU')}.`, 'lose');
        return;
    }
    busy = true;
    rouletteWheel.textContent = '...';
    rouletteWheel.className = 'roulette-wheel';
    post('roulette', { bet: { type: selectedBet.type, value: selectedBet.value, amount: amount } });
});

document.getElementById('spin-slots').addEventListener('click', () => {
    if (busy) return;
    const amount = Number(document.getElementById('slot-amount').value);
    if (!amount || amount < minBet || amount > maxBet) {
        showResult(`Ставка от $${minBet} до $${maxBet.toLocaleString('ru-RU')}.`, 'lose');
        return;
    }
    busy = true;
    document.querySelectorAll('.reel').forEach((reel) => reel.classList.add('spinning'));
    post('slots', { amount: amount });
});

function renderCards(containerId, cards) {
    const container = document.getElementById(containerId);
    container.innerHTML = '';
    (cards || []).forEach((card) => {
        const element = document.createElement('div');
        element.className = 'bj-card';
        element.textContent = card;
        container.appendChild(element);
    });
}

document.getElementById('bj-start').addEventListener('click', () => {
    if (busy) return;
    const amount = Number(document.getElementById('bj-amount').value);
    if (!amount || amount < minBet || amount > maxBet) {
        showResult(`Ставка от $${minBet} до $${maxBet.toLocaleString('ru-RU')}.`, 'lose');
        return;
    }
    busy = true;
    post('blackjackStart', { amount: amount });
});

document.getElementById('bj-hit').addEventListener('click', () => {
    if (busy) return;
    busy = true;
    post('blackjackHit');
});

document.getElementById('bj-stand').addEventListener('click', () => {
    if (busy) return;
    busy = true;
    post('blackjackStand');
});

// ============================================================
// Покер
// ============================================================

let pokerState = null;

function renderPokerTables(tables) {
    const container = document.getElementById('poker-tables');
    container.innerHTML = '';

    if (!tables || tables.length === 0) {
        container.innerHTML = '<div class="casino-empty">Столов пока нет. Создай свой — бай-ин от $500.</div>';
        return;
    }

    tables.forEach((table) => {
        const row = document.createElement('div');
        row.className = 'casino-row';
        row.innerHTML = `
            <span>Стол #${table.id} — бай-ин $${Number(table.buyIn).toLocaleString('ru-RU')} • ${table.players}/6</span>
            <button class="action-button" data-poker-join="${table.id}" ${table.state !== 'waiting' ? 'disabled' : ''}>Сесть</button>
        `;
        container.appendChild(row);
    });

    container.querySelectorAll('[data-poker-join]').forEach((button) => {
        button.addEventListener('click', () => post('pokerJoin', { id: Number(button.dataset.pokerJoin) }));
    });
}

function renderPokerState(state) {
    pokerState = state;
    document.getElementById('poker-lobby').classList.add('hidden');
    document.getElementById('poker-table-view').classList.remove('hidden');

    const community = document.getElementById('poker-community');
    community.innerHTML = '';
    (state.community || []).forEach((card) => {
        const element = document.createElement('div');
        element.className = 'bj-card';
        element.textContent = card;
        community.appendChild(element);
    });
    if (state.community.length === 0) {
        community.innerHTML = '<div class="casino-empty">Общие карты появятся после флопа.</div>';
    }

    const hand = document.getElementById('poker-hand');
    hand.innerHTML = '';
    (state.hand || []).forEach((card) => {
        const element = document.createElement('div');
        element.className = 'bj-card';
        element.textContent = card;
        hand.appendChild(element);
    });

    const seats = document.getElementById('poker-seats');
    seats.innerHTML = '';
    Object.keys(state.seats || {}).forEach((seat) => {
        const player = state.seats[seat];
        const row = document.createElement('div');
        row.className = 'casino-row';
        row.innerHTML = `
            <span>Место ${seat}: ${player.name} — $${Number(player.chips).toLocaleString('ru-RU')}${player.folded ? ' (фолд)' : ''}${player.current ? ' ●' : ''}</span>
        `;
        seats.appendChild(row);
    });

    document.getElementById('poker-pot').textContent = `Банк: $${Number(state.pot || 0).toLocaleString('ru-RU')} • Твоя ставка: $${Number(state.yourBet || 0).toLocaleString('ru-RU')}`;

    const active = state.canAct === true;
    document.getElementById('poker-fold').disabled = !active;
    document.getElementById('poker-check').disabled = !active;
    document.getElementById('poker-raise').disabled = !active;
}

document.getElementById('poker-create').addEventListener('click', () => {
    const buyIn = Number(document.getElementById('poker-buyin').value);
    if (buyIn) post('pokerCreate', { buyIn: buyIn });
});

document.getElementById('poker-fold').addEventListener('click', () => post('pokerAction', { id: pokerState.tableId, action: 'fold' }));
document.getElementById('poker-check').addEventListener('click', () => post('pokerAction', { id: pokerState.tableId, action: 'check' }));
document.getElementById('poker-raise').addEventListener('click', () => post('pokerAction', { id: pokerState.tableId, action: 'raise' }));

// ============================================================
// Мафия
// ============================================================

let mafiaState = null;

function renderMafiaRooms(rooms) {
    const container = document.getElementById('mafia-rooms');
    container.innerHTML = '';

    if (!rooms || rooms.length === 0) {
        container.innerHTML = '<div class="casino-empty">Открытых комнат нет. Создай свою (от 4 игроков).</div>';
        return;
    }

    rooms.forEach((room) => {
        const row = document.createElement('div');
        row.className = 'casino-row';
        row.innerHTML = `
            <span>Комната #${room.id} — ${room.players}/10</span>
            <button class="action-button" data-mafia-join="${room.id}">Войти</button>
        `;
        container.appendChild(row);
    });

    container.querySelectorAll('[data-mafia-join]').forEach((button) => {
        button.addEventListener('click', () => post('mafiaJoin', { id: Number(button.dataset.mafiaJoin) }));
    });
}

const ROLE_NAMES = { town: 'Мирный житель', mafia: 'Мафия', doctor: 'Доктор', sheriff: 'Шериф' };

function renderMafiaState(state) {
    mafiaState = state;
    document.getElementById('mafia-lobby').classList.add('hidden');
    document.getElementById('mafia-game-view').classList.remove('hidden');

    const phaseNames = { lobby: 'Ожидание игроков', night: 'Ночь', day: 'День', ended: 'Игра окончена' };
    const status = document.getElementById('mafia-status');
    status.textContent = `Мафия — ${phaseNames[state.phase] || ''}` + (state.winner ? ` • Победили: ${state.winner}` : '');

    const players = document.getElementById('mafia-players');
    players.innerHTML = '';
    (state.players || []).forEach((player) => {
        const row = document.createElement('div');
        row.className = 'casino-row';
        row.innerHTML = `
            <span>${player.alive ? '●' : '✝'} ${player.name}${player.role ? ' — ' + (ROLE_NAMES[player.role] || player.role) : ''}</span>
        `;
        players.appendChild(row);
    });

    const targets = document.getElementById('mafia-targets');
    targets.innerHTML = '';

    let canAct = false;
    if (state.phase === 'night' && state.alive) {
        if (state.role === 'mafia') canAct = 'kill';
        if (state.role === 'doctor') canAct = 'save';
        if (state.role === 'sheriff') canAct = 'check';
    }
    if (state.phase === 'day' && state.alive) canAct = 'vote';

    if (canAct) {
        (state.players || []).forEach((player) => {
            if (!player.alive) return;
            const row = document.createElement('div');
            row.className = 'casino-row';
            row.innerHTML = `
                <span>${player.name}</span>
                <button class="action-button" data-mafia-target="${player.cid}">Выбрать</button>
            `;
            targets.appendChild(row);
        });
        targets.querySelectorAll('[data-mafia-target]').forEach((button) => {
            button.addEventListener('click', () => post('mafiaAction', { id: state.roomId, action: canAct, target: button.dataset.mafiaTarget }));
        });
    } else {
        targets.innerHTML = '<div class="casino-empty">Дождись своей фазы или своей очереди.</div>';
    }

    const log = document.getElementById('mafia-log');
    log.innerHTML = '';
    (state.log || []).slice().reverse().forEach((line) => {
        const row = document.createElement('div');
        row.className = 'casino-row';
        row.textContent = line;
        log.appendChild(row);
    });

    if (state.phase === 'lobby') {
        const start = document.createElement('div');
        start.className = 'casino-row';
        start.innerHTML = '<button class="action-button" id="mafia-start">Начать игру (от 4 игроков)</button>';
        log.appendChild(start);
        const startButton = document.getElementById('mafia-start');
        if (startButton) startButton.addEventListener('click', () => post('mafiaStart', { id: state.roomId }));
    }
}

document.getElementById('mafia-create').addEventListener('click', () => post('mafiaCreate'));

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        post('close');
    }
});

renderBetGrid();
