const overlay = document.getElementById('overlay');

let myLots = {};
let auctionSection = 'live';

function post(action, data) {
    fetch(`https://bu-auction/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

function switchTab(tabName) {
    auctionSection = tabName;
    document.querySelectorAll('.tab').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.auctiontab === tabName);
    });
    document.getElementById('auction-live').classList.toggle('hidden', tabName !== 'live');
    document.getElementById('auction-sell').classList.toggle('hidden', tabName !== 'sell');
}

function renderLive(auctions) {
    const container = document.getElementById('auction-live');
    container.innerHTML = '';

    if (!auctions || auctions.length === 0) {
        container.innerHTML = '<div class="empty-note">Сейчас нет активных торгов. Выставь свой лот!</div>';
        return;
    }

    auctions.forEach((auction) => {
        const card = document.createElement('div');
        card.className = 'auction-card';
        const left = Math.max(0, auction.endsAt - Math.floor(Date.now() / 1000));
        const minutes = Math.floor(left / 60);
        const seconds = left % 60;
        card.innerHTML = `
            <div class="auction-title">${auction.label}</div>
            <div class="auction-sub">${auction.lotType} • до конца: ${minutes}:${String(seconds).padStart(2, '0')}</div>
            <div class="auction-bid">${auction.currentBid > 0 ? 'Текущая ставка: $' + Number(auction.currentBid).toLocaleString('ru-RU') + ' (' + auction.bidderName + ')' : 'Стартовая цена: $' + Number(auction.startPrice).toLocaleString('ru-RU')}</div>
            <div class="auction-row">
                <span class="auction-sub">${auction.isMine ? 'Твой лот' : ''}</span>
                ${!auction.isMine ? `<button class="button buy" data-bid="${auction.id}" data-mult="1">Ставка</button><button class="button buy" data-bid="${auction.id}" data-mult="3">×3</button><button class="button buy" data-bid="${auction.id}" data-mult="5">×5</button>` : ''}
            </div>
        `;
        container.appendChild(card);
    });

    container.querySelectorAll('[data-bid]').forEach((button) => {
        button.addEventListener('click', () => post('bid', { id: Number(button.dataset.bid), mult: Number(button.dataset.mult || 1) }));
    });
}

function fillLotOptions() {
    const type = document.getElementById('sell-type').value;
    const select = document.getElementById('sell-lot');
    select.innerHTML = '';

    const source = {
        business: myLots.properties || [],
        house: myLots.houses || [],
        apartment: myLots.apartments || [],
        vehicle: myLots.vehicles || [],
        item: myLots.items || []
    }[type];

    if (!source || source.length === 0) {
        select.innerHTML = '<option value="">Нет доступных лотов</option>';
        return;
    }

    source.forEach((lot) => {
        const option = document.createElement('option');
        option.value = lot.key !== undefined ? lot.key : lot.name;
        option.textContent = lot.label + (lot.amount !== undefined ? ' (есть: ' + lot.amount + ')' : '');
        option.dataset.name = lot.name || '';
        option.dataset.amount = lot.amount || 1;
        select.appendChild(option);
    });
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:auction:open') {
        myLots = message.myLots || {};
        renderLive(message.auctions || []);
        fillLotOptions();
        switchTab('live');
        overlay.classList.add('visible');
    }

    if (message.type === 'bu:auction:close') {
        overlay.classList.remove('visible');
    }
});

document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => switchTab(tab.dataset.auctiontab));
});

document.getElementById('sell-type').addEventListener('change', fillLotOptions);

document.getElementById('sell-create').addEventListener('click', () => {
    const type = document.getElementById('sell-type').value;
    const select = document.getElementById('sell-lot');
    const option = select.selectedOptions[0];

    if (!option || !option.value) return;

    post('create', {
        lotType: type,
        lotKey: option.value,
        label: option.textContent,
        price: document.getElementById('sell-price').value,
        duration: Number(document.getElementById('sell-duration').value) * 60,
        itemName: option.dataset.name || '',
        itemAmount: option.dataset.amount || 1
    });
});

document.getElementById('close-button').addEventListener('click', () => post('close'));

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        post('close');
    }
});
