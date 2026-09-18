const overlay = document.getElementById('overlay');

function switchTab(tab) {
    document.querySelectorAll('.tab').forEach((t) => t.classList.toggle('active', t.dataset.tab === tab));
    document.getElementById('panel-buy').classList.toggle('hidden', tab !== 'buy');
    document.getElementById('panel-mine').classList.toggle('hidden', tab !== 'mine');
    if (tab === 'buy') fetchListings(); else fetchMine();
}

function fetchListings() { fetch('https://bu-carmarket/getListings', { method: 'POST', body: '{}' }); }
function fetchMine() { fetch('https://bu-carmarket/getMy', { method: 'POST', body: '{}' }); }

function renderListings(list) {
    const el = document.getElementById('buy-list');
    el.innerHTML = '';
    (list || []).forEach((l) => {
        const div = document.createElement('div');
        div.className = 'item';
        div.innerHTML = '<div><div class="i-label">' + l.model + '</div><div class="i-sub">' + l.plate + ' · ' + l.owner + '</div></div>' +
            '<span class="i-price">$' + l.price + '</span><button class="act" data-id="' + l.id + '">Купить</button>';
        div.querySelector('.act').addEventListener('click', () => {
            fetch('https://bu-carmarket/buy', { method: 'POST', body: JSON.stringify({ id: l.id }) });
            setTimeout(fetchListings, 600);
        });
        el.appendChild(div);
    });
    if (!list || list.length === 0) el.innerHTML = '<div class="item">Сейчас нет объявлений</div>';
}

function renderMine(list) {
    const el = document.getElementById('mine-list');
    el.innerHTML = '';
    (list || []).forEach((m) => {
        const div = document.createElement('div');
        div.className = 'item';
        div.innerHTML = '<div class="i-label">' + m.vehicle + '</div><div class="i-sub">' + m.plate + '</div>' +
            '<input class="price-input" placeholder="Цена" />' +
            '<button class="act small" data-plate="' + m.plate + '">Продать</button>';
        div.querySelector('.act').addEventListener('click', () => {
            const price = div.querySelector('.price-input').value;
            fetch('https://bu-carmarket/list', { method: 'POST', body: JSON.stringify({ plate: m.plate, price: price }) });
            setTimeout(fetchMine, 600);
        });
        el.appendChild(div);
    });
    if (!list || list.length === 0) el.innerHTML = '<div class="item">У тебя нет машин для продажи</div>';
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;
    if (message.action === 'open') { overlay.classList.add('visible'); switchTab('buy'); }
    if (message.action === 'close') { overlay.classList.remove('visible'); }
    if (message.action === 'listings') { renderListings(message.list); }
    if (message.action === 'mine') { renderMine(message.list); }
});

document.querySelectorAll('.tab').forEach((t) => t.addEventListener('click', () => switchTab(t.dataset.tab)));
document.getElementById('close-btn').addEventListener('click', () => fetch('https://bu-carmarket/close', { method: 'POST', body: '{}' }));
