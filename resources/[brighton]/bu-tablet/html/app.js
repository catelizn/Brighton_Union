const overlay = document.getElementById('overlay');
const viewHome = document.getElementById('view-home');
const viewDocuments = document.getElementById('view-documents');
const viewVehicles = document.getElementById('view-vehicles');
const viewMarketplace = document.getElementById('view-marketplace');
const viewNews = document.getElementById('view-news');
const viewFamily = document.getElementById('view-family');
const viewFaction = document.getElementById('view-faction');
const viewTaxi = document.getElementById('view-taxi');
const viewTrucker = document.getElementById('view-trucker');
const viewDarknet = document.getElementById('view-darknet');

const docIcons = {};

function post(action, data) {
    fetch(`https://bu-tablet/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

function showView(view) {
    [viewHome, viewDocuments, viewVehicles, viewMarketplace, viewNews, viewFamily, viewFaction, viewTaxi, viewTrucker, viewDarknet].forEach((element) => element.classList.add('hidden'));
    view.classList.remove('hidden');
}

function updateClock() {
    const now = new Date();
    const time = now.toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' });
    document.getElementById('statusbar-time').textContent = time;
    const wd = document.getElementById('widget-date');
    const wt = document.getElementById('widget-time');
    if (wd) wd.textContent = now.toLocaleDateString('ru-RU', { weekday: 'long', day: 'numeric', month: 'long' });
    if (wt) wt.textContent = time;
}

function renderPersonal(data) {
    const genderMap = { 0: 'Мужской', 1: 'Женский' };
    const nationality = data.charinfo.nationality === 'Russian Federation' ? 'Россия' : (data.charinfo.nationality || '—');
    const gender = genderMap[data.charinfo.gender] !== undefined ? genderMap[data.charinfo.gender] : '—';

    const rows = [
        ['Имя', `${data.charinfo.firstname || '—'} ${data.charinfo.lastname || ''}`.trim()],
        ['Дата рождения', data.charinfo.birthdate || '—'],
        ['Национальность', nationality],
        ['Пол', gender],
        ['Фото на документы', data.photoDate || 'Не сделано — фотоателье на карте']
    ];

    const personal = document.getElementById('documents-personal');
    personal.innerHTML = '';
    rows.forEach(([label, value]) => {
        const row = document.createElement('div');
        row.className = 'info-row';
        row.innerHTML = `<span class="info-label">${label}</span><span class="info-value">${value}</span>`;
        personal.appendChild(row);
    });
}

function renderLicenses(data) {
    const documentsList = document.getElementById('documents-list');
    documentsList.innerHTML = '';
    if (data.licenses.length === 0) {
        documentsList.innerHTML = '<div class="empty-note">Документов нет. Удостоверение и лицензии оформляются в мэрии, права — в автошколе.</div>';
    }
    data.licenses.forEach((license) => {
        const card = document.createElement('div');
        card.className = 'document-card';
        card.innerHTML = `
            <div class="document-icon"><i class="fas ${license.icon || 'fa-file-alt'}"></i></div>
            <div>
                <div class="document-label">${license.label}</div>
                ${license.category ? `<div class="document-category">${license.category}</div>` : ''}
            </div>
        `;
        documentsList.appendChild(card);
    });
}

function render(data) {
    const fullName = `${data.charinfo.firstname || ''} ${data.charinfo.lastname || ''}`.trim();
    document.getElementById('profile-name').textContent = fullName || 'Без имени';
    document.getElementById('profile-job').textContent = data.job || 'Безработный';

    const initials = fullName.split(' ').map((word) => word[0]).join('').slice(0, 2);
    document.getElementById('profile-avatar').textContent = initials || '?';

    document.getElementById('money-cash').textContent = '$' + Number(data.money.cash || 0).toLocaleString('ru-RU');
    document.getElementById('money-bank').textContent = '$' + Number(data.money.bank || 0).toLocaleString('ru-RU');

    renderPersonal(data);
    renderLicenses(data);

    const vehiclesList = document.getElementById('vehicles-list');
    vehiclesList.innerHTML = '';
    if (data.vehicles.length === 0) {
        vehiclesList.innerHTML = '<div class="empty-note">Своего транспорта пока нет. Купи машину в автосалоне или возьми в аренду.</div>';
    }
    data.vehicles.forEach((vehicle) => {
        const card = document.createElement('div');
        card.className = 'document-card';
        card.innerHTML = `
            <div class="document-icon"><i class="fas fa-car-side"></i></div>
            <div>
                <div class="document-label">${vehicle.label}</div>
                <div class="document-category">${vehicle.plate} • ${vehicle.garage}</div>
            </div>
        `;
        vehiclesList.appendChild(card);
    });
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:tablet:open') {
        render(message.data);
        showView(viewHome);
        overlay.classList.add('visible');
        updateClock();
    }

    if (message.type === 'bu:tablet:close') {
        overlay.classList.remove('visible');
    }

    if (message.type === 'bu:mp:list') {
        renderMpShop(message.data);
    }

    if (message.type === 'bu:mp:my') {
        renderMpMine(message.data);
    }

    if (message.type === 'bu:news:list') {
        renderNews(message.data);
    }

    if (message.type === 'bu:family:data') {
        renderFamily(message.data);
    }

    if (message.type === 'bu:taxi:data') {
        taxiData = message.data;
        renderTaxi();
    }

    if (message.type === 'bu:trucker:data') {
        truckerData = message.data;
        renderTrucker();
    }

    if (message.type === 'bu:darknet:list') {
        renderDarknet(message.data);
    }
});

document.querySelectorAll('.app').forEach((app) => {
    app.addEventListener('click', () => {
        const target = app.dataset.app;
        if (target === 'documents') showView(viewDocuments);
        if (target === 'vehicles') showView(viewVehicles);
        if (target === 'marketplace') {
            showView(viewMarketplace);
            switchMpTab('shop');
            post('mpList');
        }
        if (target === 'news') {
            showView(viewNews);
            switchNewsTab('feed');
            post('newsList');
        }
        if (target === 'family') {
            famSection = 'family';
            showView(viewFamily);
            post('familyData');
        }
        if (target === 'faction') {
            famSection = 'faction';
            showView(viewFaction);
            post('familyData');
        }
        if (target === 'taxi') {
            showView(viewTaxi);
            switchTaxiTab('orders');
            post('taxiList');
        }
        if (target === 'trucker') {
            showView(viewTrucker);
            switchTruckerTab('business');
            post('truckerList');
        }
        if (target === 'darknet') {
            showView(viewDarknet);
            post('darknetList');
        }
    });
});

document.querySelectorAll('.back-button').forEach((button) => {
    button.addEventListener('click', () => showView(viewHome));
});

document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => {
        const target = tab.closest('.view');

        if (target === viewDocuments) {
            document.querySelectorAll('#view-documents .tab').forEach((other) => other.classList.remove('active'));
            tab.classList.add('active');
            const showLicenses = tab.dataset.tab === 'licenses';
            document.getElementById('documents-personal').classList.toggle('hidden', showLicenses);
            document.getElementById('documents-list').classList.toggle('hidden', !showLicenses);
        }

        if (target === viewMarketplace) {
            switchMpTab(tab.dataset.tab);
        }

        if (target === viewNews) {
            switchNewsTab(tab.dataset.tab);
        }
    });
});

function switchMpTab(tabName) {
    document.querySelectorAll('#view-marketplace .tab').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.tab === tabName);
    });
    document.getElementById('mp-shop').classList.toggle('hidden', tabName !== 'shop');
    document.getElementById('mp-mine').classList.toggle('hidden', tabName !== 'mine');
    if (tabName === 'shop') post('mpList');
    if (tabName === 'mine') post('mpMy');
}

function switchNewsTab(tabName) {
    document.querySelectorAll('#view-news .tab').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.tab === tabName);
    });
    document.getElementById('news-feed').classList.toggle('hidden', tabName !== 'feed');
    document.getElementById('news-submit').classList.toggle('hidden', tabName !== 'submit');
    if (tabName === 'feed') post('newsList');
}

// ============================================================
// Семья / Фракция
// ============================================================

let famSection = 'family';
let famTab = 'info';
let famData = null;

function famAction(payload) {
    post('familyAction', payload);
    setTimeout(() => post('familyData'), 700);
}

function renderFamCreate() {
    const price = famSection === 'faction' ? '$150 000' : '$25 000';
    const kind = famSection === 'faction' ? 'Фракция' : 'Семья';
    const container = document.getElementById(famSection + '-content');
    container.innerHTML = `
        <div class="fam-create">
            <div class="fam-create-title">Создание: ${kind}</div>
            <div class="fam-create-price">Цена: ${price} (со счёта банка)</div>
            <input type="text" id="fam-name" maxlength="24" placeholder="Название (3–24 символа)" />
            <button class="mp-button buy" id="fam-create-button">Создать</button>
        </div>
    `;
    document.getElementById('fam-create-button').addEventListener('click', () => {
        const name = document.getElementById('fam-name').value.trim();
        if (!name) return;
        famAction({ action: 'create', name: name, familyType: 'family' });
    });
}

function renderFamInfo() {
    const container = document.getElementById(famSection + '-content');
    const kind = famData.type === 'faction' ? 'Фракция' : famData.type === 'gang' ? 'Банда' : 'Семья';
    const contractLine = famData.activeContract
        ? `Активный контракт: ${famData.activeContract.label} (взял: ${famData.activeContract.taker})`
        : 'Активных контрактов нет';
    const territoriesLine = famData.territories && famData.territories.length > 0
        ? famData.territories.join(', ')
        : 'нет';
    container.innerHTML = `
        <div class="fam-card">
            <div class="fam-name">${famData.name}</div>
            <div class="fam-type">${kind}</div>
        </div>
        <div class="fam-row"><span>Мой ранг</span><span>${famData.rank}</span></div>
        <div class="fam-row"><span>Участников</span><span>${famData.memberCount}</span></div>
        <div class="fam-row"><span>Казна</span><span>$${Number(famData.money).toLocaleString('ru-RU')}</span></div>
        <div class="fam-row"><span>Офис</span><span>${famData.office || 'не назначен'}</span></div>
        <div class="fam-row"><span>Территории</span><span>${territoriesLine}</span></div>
        <div class="fam-row"><span>Контракт</span><span>${contractLine}</span></div>
    `;
}

function renderFamMembers() {
    const container = document.getElementById(famSection + '-content');
    let html = '';

    if (famData.isLeader) {
        html += `
            <div class="fam-invite">
                <input type="number" id="fam-invite-id" placeholder="ID игрока" />
                <button class="mp-button buy" id="fam-invite-button">Пригласить</button>
            </div>
        `;
    }

    famData.members.forEach((member) => {
        let controls = '';
        if (famData.isLeader && member.rank < famData.leaderRank) {
            controls = `
                <button class="fam-mini" data-act="setRank" data-cid="${member.citizenid}" data-rank="${member.rank + 1}">Повысить</button>
                <button class="fam-mini" data-act="setRank" data-cid="${member.citizenid}" data-rank="${member.rank - 1}">Понизить</button>
                <button class="fam-mini danger" data-act="kick" data-cid="${member.citizenid}">Исключить</button>
            `;
        }
        html += `
            <div class="fam-row">
                <span>${member.name}</span>
                <span>Ранг ${member.rank} ${controls}</span>
            </div>
        `;
    });
    container.innerHTML = html;

    const inviteButton = document.getElementById('fam-invite-button');
    if (inviteButton) {
        inviteButton.addEventListener('click', () => {
            const targetId = Number(document.getElementById('fam-invite-id').value);
            if (targetId) famAction({ action: 'invite', targetId: targetId });
        });
    }

    container.querySelectorAll('.fam-mini').forEach((button) => {
        button.addEventListener('click', () => {
            famAction({ action: button.dataset.act, targetCid: button.dataset.cid, rank: Number(button.dataset.rank) });
        });
    });
}

function renderFamMoney() {
    const container = document.getElementById(famSection + '-content');
    let withdrawHtml = '';
    if (famData.isLeader) {
        withdrawHtml = `
            <div class="fam-form">
                <input type="number" id="fam-withdraw" placeholder="Сумма" />
                <button class="mp-button buy" id="fam-withdraw-button">Снять из казны</button>
            </div>
        `;
    }
    container.innerHTML = `
        <div class="fam-row"><span>Баланс казны</span><span>$${Number(famData.money).toLocaleString('ru-RU')}</span></div>
        <div class="fam-form">
            <input type="number" id="fam-deposit" placeholder="Сумма" />
            <button class="mp-button buy" id="fam-deposit-button">Внести наличные</button>
        </div>
        ${withdrawHtml}
    `;
    document.getElementById('fam-deposit-button').addEventListener('click', () => {
        const amount = Number(document.getElementById('fam-deposit').value);
        if (amount > 0) famAction({ action: 'deposit', amount: amount });
    });
    const withdrawButton = document.getElementById('fam-withdraw-button');
    if (withdrawButton) {
        withdrawButton.addEventListener('click', () => {
            const amount = Number(document.getElementById('fam-withdraw').value);
            if (amount > 0) famAction({ action: 'withdraw', amount: amount });
        });
    }
}

function renderFamLogs() {
    const container = document.getElementById(famSection + '-content');
    if (!famData.isLeader) {
        container.innerHTML = '<div class="empty-note">Логи доступны только лидеру.</div>';
        return;
    }
    if (!famData.logs || famData.logs.length === 0) {
        container.innerHTML = '<div class="empty-note">Логов пока нет.</div>';
        return;
    }
    container.innerHTML = '';
    famData.logs.forEach((log) => {
        const row = document.createElement('div');
        row.className = 'fam-log';
        row.innerHTML = `
            <div class="fam-log-top"><span>${log.name}</span><span class="fam-log-date">${log.date}</span></div>
            <div class="fam-log-detail">${log.detail}</div>
        `;
        container.appendChild(row);
    });
}

function renderFamContracts() {
    const container = document.getElementById(famSection + '-content');
    let html = '';

    if (famData.activeContract) {
        const active = famData.activeContract;
        html += `
            <div class="fam-card active">
                <div class="fam-name">Активный контракт: ${active.label}</div>
                <div class="fam-type">Награда: $${Number(active.reward).toLocaleString('ru-RU')} • Взял: ${active.taker}</div>
                <div class="fam-actions">
                    ${!active.pickupDone ? '<button class="mp-button buy" id="fam-pickup">Забрать груз</button>' : '<button class="mp-button buy" id="fam-deliver">Сдать груз</button>'}
                </div>
            </div>
        `;
    } else {
        famData.contracts.forEach((contract, index) => {
            html += `
                <div class="fam-card">
                    <div class="fam-name">${contract.label}</div>
                    <div class="fam-type">Награда: $${Number(contract.reward).toLocaleString('ru-RU')}</div>
                    <div class="fam-actions">
                        <button class="mp-button buy" data-contract="${index + 1}">Взять контракт</button>
                    </div>
                </div>
            `;
        });
    }

    container.innerHTML = html || '<div class="empty-note">Контрактов нет.</div>';

    const pickupButton = document.getElementById('fam-pickup');
    if (pickupButton) pickupButton.addEventListener('click', () => famAction({ action: 'contractPickup' }));
    const deliverButton = document.getElementById('fam-deliver');
    if (deliverButton) deliverButton.addEventListener('click', () => famAction({ action: 'contractDeliver' }));

    container.querySelectorAll('[data-contract]').forEach((button) => {
        button.addEventListener('click', () => famAction({ action: 'takeContract', index: Number(button.dataset.contract) }));
    });
}

function renderFamGarage() {
    const container = document.getElementById(famSection + '-content');
    let html = '';

    if (famData.isLeader) {
        html += '<div class="fam-form-title">Купить для организации (со счёта казны):</div>';
        famData.garageCatalog.forEach((vehicle, index) => {
            html += `
                <div class="fam-row">
                    <span>${vehicle.label}</span>
                    <span>$${Number(vehicle.price).toLocaleString('ru-RU')} <button class="fam-mini" data-buy="${index + 1}">Купить</button></span>
                </div>
            `;
        });
    }

    html += '<div class="fam-form-title">Гараж организации:</div>';
    if (!famData.garage || famData.garage.length === 0) {
        html += '<div class="empty-note">Машин пока нет.</div>';
    }
    (famData.garage || []).forEach((vehicle) => {
        html += `
            <div class="fam-row">
                <span>${vehicle.label}</span>
                <span>${vehicle.plate} • ${vehicle.inUse ? 'у участника' : 'в гараже'}</span>
            </div>
        `;
    });

    container.innerHTML = html;
    container.querySelectorAll('[data-buy]').forEach((button) => {
        button.addEventListener('click', () => famAction({ action: 'buyVehicle', index: Number(button.dataset.buy) }));
    });
}

function renderFamTab() {
    const renderers = {
        info: renderFamInfo,
        members: renderFamMembers,
        money: renderFamMoney,
        logs: renderFamLogs,
        contracts: renderFamContracts,
        garage: renderFamGarage
    };
    (renderers[famTab] || renderFamInfo)();
}

function switchFamTab(tabName) {
    famTab = tabName;
    document.querySelectorAll('#' + famSection + '-tabs .tab').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.famtab === tabName);
    });
    renderFamTab();
}

function renderFamily(data) {
    famData = data;
    if (!data || data.none) {
        renderFamCreate();
        return;
    }
    renderFamTab();
}

document.querySelectorAll('#family-tabs .tab, #faction-tabs .tab').forEach((tab) => {
    tab.addEventListener('click', () => switchFamTab(tab.dataset.famtab));
});

function renderDarknet(data) {
    if (!data) return;

    const notice = document.getElementById('darknet-notice');
    const list = document.getElementById('darknet-list');

    const cooldown = data.cooldownLeft > 0
        ? `Между заказами подожди ${Math.ceil(data.cooldownLeft / 60)} мин.`
        : 'Оплата наличными, выдача — в точке на карте.';
    notice.textContent = data.pending
        ? `Ждёт выдачи: ${data.pending.label}. Забери в точке на карте.`
        : cooldown;

    list.innerHTML = '';
    data.items.forEach((item) => {
        const card = document.createElement('div');
        card.className = 'fam-card';
        card.innerHTML = `
            <div class="fam-name">${item.label}</div>
            <div class="fam-type">$${Number(item.price).toLocaleString('ru-RU')}</div>
            <div class="fam-actions">
                <button class="mp-button buy" data-darknet-buy="${item.id}">Заказать</button>
            </div>
        `;
        list.appendChild(card);
    });

    list.querySelectorAll('[data-darknet-buy]').forEach((button) => {
        button.addEventListener('click', () => {
            post('darknetBuy', { item: button.dataset.darknetBuy });
        });
    });
}

// ============================================================
// Brighton Taxi
// ============================================================

let taxiData = null;

function renderTaxi() {
    const orders = document.getElementById('taxi-orders');
    const mine = document.getElementById('taxi-mine');

    orders.innerHTML = '';
    if (!taxiData || !taxiData.orders || taxiData.orders.length === 0) {
        orders.innerHTML = '<div class="empty-note">Открытых заказов нет.</div>';
    }
    (taxiData ? taxiData.orders : []).forEach((order) => {
        const card = document.createElement('div');
        card.className = 'fam-card';
        card.innerHTML = `
            <div class="fam-name">${order.name} → ${order.destination}</div>
            <div class="fam-type">Цена поездки: $${Number(order.price).toLocaleString('ru-RU')}</div>
            <div class="fam-actions">
                <button class="mp-button buy" data-taxi-take="${order.id}">Взять заказ</button>
            </div>
        `;
        orders.appendChild(card);
    });
    orders.querySelectorAll('[data-taxi-take]').forEach((button) => {
        button.addEventListener('click', () => {
            post('taxiTake', { id: Number(button.dataset.taxiTake) });
            setTimeout(() => post('taxiList'), 700);
        });
    });

    mine.innerHTML = '';
    if (taxiData && taxiData.mine) {
        const order = taxiData.mine;
        mine.innerHTML = `
            <div class="fam-card active">
                <div class="fam-name">${order.name} → ${order.destination}</div>
                <div class="fam-type">Цена: $${Number(order.price).toLocaleString('ru-RU')}</div>
                <div class="fam-actions">
                    <button class="mp-button buy" id="taxi-finish">Завершить поездку</button>
                </div>
            </div>
        `;
        document.getElementById('taxi-finish').addEventListener('click', () => {
            post('taxiFinish', { id: order.id });
            setTimeout(() => post('taxiList'), 700);
        });
    } else {
        mine.innerHTML = '<div class="empty-note">У тебя нет активного заказа.</div>';
    }
}

function switchTaxiTab(tabName) {
    document.querySelectorAll('#view-taxi .tab').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.taxitab === tabName);
    });
    document.getElementById('taxi-orders').classList.toggle('hidden', tabName !== 'orders');
    document.getElementById('taxi-mine').classList.toggle('hidden', tabName !== 'mine');
}

document.querySelectorAll('#view-taxi .tab').forEach((tab) => {
    tab.addEventListener('click', () => switchTaxiTab(tab.dataset.taxitab));
});

// ============================================================
// Дальнобой
// ============================================================

let truckerData = null;

function renderTrucker() {
    const orders = document.getElementById('trucker-orders');
    const routes = document.getElementById('trucker-routes');
    const mine = document.getElementById('trucker-mine');

    orders.innerHTML = '';
    if (!truckerData || !truckerData.orders || truckerData.orders.length === 0) {
        orders.innerHTML = '<div class="empty-note">Заказов от бизнесов нет. Можно взять маршрут NPC.</div>';
    }
    (truckerData ? truckerData.orders : []).forEach((order) => {
        const card = document.createElement('div');
        card.className = 'fam-card';
        card.innerHTML = `
            <div class="fam-name">${order.label}</div>
            <div class="fam-type">Товары: ${order.units} ед. • Оплата: $${Number(order.reward).toLocaleString('ru-RU')}</div>
            <div class="fam-actions">
                <button class="mp-button buy" data-truck-take="order:${order.id}">Взять рейс</button>
            </div>
        `;
        orders.appendChild(card);
    });
    orders.querySelectorAll('[data-truck-take]').forEach((button) => {
        button.addEventListener('click', () => {
            post('truckerAction', { action: 'take', key: button.dataset.truckTake });
            setTimeout(() => post('truckerList'), 700);
        });
    });

    routes.innerHTML = '';
    (truckerData ? truckerData.npcRoutes : []).forEach((route, index) => {
        const card = document.createElement('div');
        card.className = 'fam-card';
        card.innerHTML = `
            <div class="fam-name">${route.label}</div>
            <div class="fam-type">Оплата: $${Number(route.reward).toLocaleString('ru-RU')}</div>
            <div class="fam-actions">
                <button class="mp-button buy" data-truck-npc="npc:${index + 1}">Взять рейс</button>
            </div>
        `;
        routes.appendChild(card);
    });
    routes.querySelectorAll('[data-truck-npc]').forEach((button) => {
        button.addEventListener('click', () => {
            post('truckerAction', { action: 'take', key: button.dataset.truckNpc });
            setTimeout(() => post('truckerList'), 700);
        });
    });

    mine.innerHTML = '';
    if (truckerData && truckerData.mine) {
        const active = truckerData.mine;
        const actionButton = active.pickupDone
            ? `<button class="mp-button buy" id="truck-finish">Сдать груз</button>`
            : `<button class="mp-button buy" id="truck-pickup">Забрать груз со склада</button>`;
        mine.innerHTML = `
            <div class="fam-card active">
                <div class="fam-name">${active.label}</div>
                <div class="fam-type">Оплата: $${Number(active.reward).toLocaleString('ru-RU')} • ${active.pickupDone ? 'Груз у тебя' : 'Нужно забрать груз'}</div>
                <div class="fam-actions">${actionButton}</div>
            </div>
        `;
        const pickupButton = document.getElementById('truck-pickup');
        if (pickupButton) {
            pickupButton.addEventListener('click', () => {
                post('truckerAction', { action: 'pickup', key: active.key });
                setTimeout(() => post('truckerList'), 700);
            });
        }
        const finishButton = document.getElementById('truck-finish');
        if (finishButton) {
            finishButton.addEventListener('click', () => {
                post('truckerAction', { action: 'finish', key: active.key });
                setTimeout(() => post('truckerList'), 700);
            });
        }
    } else {
        mine.innerHTML = '<div class="empty-note">У тебя нет активного рейса.</div>';
    }
}

function switchTruckerTab(tabName) {
    document.querySelectorAll('#view-trucker .tab').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.trucktab === tabName);
    });
    document.getElementById('trucker-orders').classList.toggle('hidden', tabName !== 'business');
    document.getElementById('trucker-routes').classList.toggle('hidden', tabName !== 'routes');
    document.getElementById('trucker-mine').classList.toggle('hidden', tabName !== 'mine');
}

document.querySelectorAll('#view-trucker .tab').forEach((tab) => {
    tab.addEventListener('click', () => switchTruckerTab(tab.dataset.trucktab));
});

function renderNews(data) {
    document.getElementById('news-price-label').textContent = `Цена объявления: $${Number(data.price || 0).toLocaleString('ru-RU')}`;

    const feed = document.getElementById('news-feed');
    feed.innerHTML = '';
    if (!data.ads || data.ads.length === 0) {
        feed.innerHTML = '<div class="empty-note">Объявлений пока нет.</div>';
        return;
    }
    data.ads.forEach((ad) => {
        const card = document.createElement('div');
        card.className = 'news-card';
        card.innerHTML = `
            <div class="news-text">${ad.text}</div>
            <div class="news-meta"><span class="news-author">${ad.author}</span><span>${ad.createdAt}</span></div>
        `;
        feed.appendChild(card);
    });
}

document.getElementById('news-send').addEventListener('click', () => {
    const text = document.getElementById('news-text').value.trim();
    if (!text) return;
    post('newsSubmit', { text: text });
    document.getElementById('news-text').value = '';
    setTimeout(() => post('newsList'), 600);
});

function itemImage(image) {
    if (!image) return '📦';
    return `<img src="nui://qb-inventory/html/images/${image}" onerror="this.remove()" />`;
}

let mpFilter = 'all';

function renderMpShop(list) {
    const filters = document.getElementById('mp-filters');
    if (filters && filters.children.length === 0) {
        const chips = [
            { key: 'all', label: 'Все' },
            { key: 'item', label: 'Предметы' },
            { key: 'property', label: 'Недвижимость' },
            { key: 'rentveh', label: 'Аренда' },
            { key: 'fav', label: 'Избранное' }
        ];
        chips.forEach((chip) => {
            const button = document.createElement('button');
            button.className = 'mp-chip' + (chip.key === mpFilter ? ' active' : '');
            button.textContent = chip.label;
            button.addEventListener('click', () => {
                mpFilter = chip.key;
                post('mpList');
            });
            filters.appendChild(button);
        });
    }
    filters.querySelectorAll('.mp-chip').forEach((chip) => {
        const key = chip.textContent === 'Все' ? 'all' : chip.textContent === 'Предметы' ? 'item' : chip.textContent === 'Недвижимость' ? 'property' : chip.textContent === 'Аренда' ? 'rentveh' : 'fav';
        chip.classList.toggle('active', key === mpFilter);
    });

    const container = document.getElementById('mp-shop');
    container.innerHTML = '';

    const visible = (list || []).filter((listing) => {
        if (mpFilter === 'all') return true;
        if (mpFilter === 'fav') return listing.isFavourite;
        return listing.lotType === mpFilter;
    });

    if (!visible || visible.length === 0) {
        container.innerHTML = '<div class="empty-note">Здесь пока пусто.</div>';
        return;
    }

    visible.forEach((listing) => {
        const card = document.createElement('div');
        card.className = 'mp-card';

        if (listing.lotType === 'rentveh') {
            const available = listing.available !== false;
            const total = listing.price * listing.amount;
            card.innerHTML = `
                <div class="mp-image">🚗</div>
                <div class="mp-info">
                    <div class="mp-title">${listing.itemLabel}</div>
                    <div class="mp-sub">Аренда: ${listing.amount} ч • ${listing.sellerName}</div>
                    <div class="mp-price">$${Number(listing.price).toLocaleString('ru-RU')}/час</div>
                    <div class="mp-meta">👁 ${listing.views || 0} • ☆ ${listing.favouritesCount || 0}</div>
                </div>
                <div class="mp-actions">
                    <button class="mp-button star ${listing.isFavourite ? 'on' : ''}" data-fav="${listing.id}">${listing.isFavourite ? '★' : '☆'}</button>
                    <button class="mp-button buy" data-rent="${listing.id}" ${available ? '' : 'disabled'}>${available ? 'Арендовать' : 'В аренде'}</button>
                </div>
            `;
            container.appendChild(card);
            return;
        }

        const imageHtml = listing.lotType === 'property' ? '🏢' : itemImage(listing.image);
        const amountHtml = listing.lotType === 'property' ? '' : ` ×${listing.amount}`;
        card.innerHTML = `
            <div class="mp-image">${imageHtml}</div>
            <div class="mp-info">
                <div class="mp-title">${listing.itemLabel}${amountHtml}</div>
                <div class="mp-sub">${listing.sellerName}</div>
                <div class="mp-price">$${Number(listing.price).toLocaleString('ru-RU')}</div>
                <div class="mp-meta">👁 ${listing.views || 0} • ☆ ${listing.favouritesCount || 0}</div>
            </div>
            <div class="mp-actions">
                <button class="mp-button star ${listing.isFavourite ? 'on' : ''}" data-fav="${listing.id}">${listing.isFavourite ? '★' : '☆'}</button>
                <button class="mp-button buy" data-id="${listing.id}">Купить</button>
            </div>
        `;
        container.appendChild(card);
    });

    container.querySelectorAll('.star').forEach((button) => {
        button.addEventListener('click', () => {
            post('mpFav', { id: button.dataset.fav });
            setTimeout(() => post('mpList'), 400);
        });
    });

    container.querySelectorAll('.buy').forEach((button) => {
        button.addEventListener('click', () => {
            post('mpView', { id: button.dataset.id || button.dataset.rent });
            if (button.dataset.rent) {
                post('mpRent', { id: button.dataset.rent });
            } else {
                post('mpBuy', { id: button.dataset.id });
            }
            setTimeout(() => post('mpList'), 500);
        });
    });
}

function renderMpMine(data) {
    const container = document.getElementById('mp-mine');
    container.innerHTML = '';

    const form = document.createElement('div');
    form.className = 'mp-form';
    form.innerHTML = `
        <div style="font-weight:600; margin-bottom:6px;">Выставить предмет</div>
        <label>Предмет</label>
        <select id="mp-item">
            ${(data.items || []).map((item) => `<option value="${item.name}" data-amount="${item.amount}">${item.label} (есть: ${item.amount})</option>`).join('')}
        </select>
        <label>Количество</label>
        <input type="number" id="mp-amount" min="1" value="1" />
        <label>Цена за лот, $</label>
        <input type="number" id="mp-price" min="1" value="100" />
        <button class="mp-button buy" id="mp-create">Выставить</button>
    `;
    container.appendChild(form);

    if ((data.items || []).length === 0) {
        container.querySelector('.mp-form').style.display = 'none';
        container.innerHTML += '<div class="empty-note">В инвентаре нет предметов для продажи.</div>';
    }

    const listingsBlock = document.createElement('div');
    listingsBlock.innerHTML = '<div style="font-weight:600; margin:14px 0 8px;">Мои лоты</div>';
    container.appendChild(listingsBlock);

    if ((data.listings || []).length === 0) {
        listingsBlock.innerHTML += '<div class="empty-note">У тебя нет активных лотов.</div>';
    }
    (data.listings || []).forEach((listing) => {
        const card = document.createElement('div');
        card.className = 'mp-card';
        card.innerHTML = `
            <div class="mp-info">
                <div class="mp-title">${listing.item} ×${listing.amount}</div>
                <div class="mp-price">$${Number(listing.price).toLocaleString('ru-RU')}</div>
            </div>
            <div class="mp-actions">
                <button class="mp-button cancel" data-id="${listing.id}">Снять</button>
            </div>
        `;
        listingsBlock.appendChild(card);
    });

    container.querySelectorAll('.cancel').forEach((button) => {
        button.addEventListener('click', () => {
            post('mpCancel', { id: button.dataset.id });
            setTimeout(() => post('mpMy'), 500);
        });
    });

    const createButton = container.querySelector('#mp-create');
    if (createButton) {
        createButton.addEventListener('click', () => {
            post('mpCreate', {
                item: container.querySelector('#mp-item').value,
                amount: container.querySelector('#mp-amount').value,
                price: container.querySelector('#mp-price').value
            });
            setTimeout(() => post('mpMy'), 500);
        });
    }

    const propertyBlock = document.createElement('div');
    propertyBlock.innerHTML = '<div style="font-weight:600; margin:14px 0 8px;">Продать недвижимость</div>';
    container.appendChild(propertyBlock);

    if ((data.properties || []).length === 0) {
        propertyBlock.innerHTML += '<div class="empty-note">У тебя нет домов и бизнесов.</div>';
    } else {
        const propertyForm = document.createElement('div');
        propertyForm.className = 'mp-form';
        propertyForm.innerHTML = `
            <label>Объект</label>
            <select id="mp-property">
                ${(data.properties || []).map((property) => `<option value="${property.key}">${property.label}</option>`).join('')}
            </select>
            <label>Цена, $</label>
            <input type="number" id="mp-property-price" min="1" value="100000" />
            <button class="mp-button buy" id="mp-property-create">Выставить</button>
        `;
        propertyBlock.appendChild(propertyForm);

        propertyForm.querySelector('#mp-property-create').addEventListener('click', () => {
            post('mpCreateProperty', {
                key: propertyForm.querySelector('#mp-property').value,
                price: propertyForm.querySelector('#mp-property-price').value
            });
            setTimeout(() => post('mpMy'), 500);
        });
    }

    const rentalBlock = document.createElement('div');
    rentalBlock.innerHTML = '<div style="font-weight:600; margin:14px 0 8px;">Сдать машину в аренду</div>';
    container.appendChild(rentalBlock);

    if ((data.vehicles || []).length === 0) {
        rentalBlock.innerHTML += '<div class="empty-note">В гараже нет машин.</div>';
    } else {
        const rentalForm = document.createElement('div');
        rentalForm.className = 'mp-form';
        rentalForm.innerHTML = `
            <label>Машина</label>
            <select id="mp-rental-vehicle">
                ${(data.vehicles || []).map((vehicle) => `<option value="${vehicle.plate}">${vehicle.label} (${vehicle.plate})</option>`).join('')}
            </select>
            <label>Цена за час, $</label>
            <input type="number" id="mp-rental-price" min="100" value="500" />
            <label>Срок аренды, часов (1–24)</label>
            <input type="number" id="mp-rental-hours" min="1" max="24" value="3" />
            <button class="mp-button buy" id="mp-rental-create">Сдать в аренду</button>
        `;
        rentalBlock.appendChild(rentalForm);

        rentalForm.querySelector('#mp-rental-create').addEventListener('click', () => {
            post('mpCreateRental', {
                plate: rentalForm.querySelector('#mp-rental-vehicle').value,
                price: rentalForm.querySelector('#mp-rental-price').value,
                hours: rentalForm.querySelector('#mp-rental-hours').value
            });
            setTimeout(() => post('mpMy'), 500);
        });
    }
}

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        post('close');
    }
});

setInterval(updateClock, 30000);
