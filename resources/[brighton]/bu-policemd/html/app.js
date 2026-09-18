const mdt = document.getElementById('mdt');
let currentCid = null;
let currentLevels = { low: '#3E8E5A', medium: '#D97706', high: '#D64545' };

function switchTab(tab) {
    document.querySelectorAll('.tab').forEach((t) => t.classList.toggle('active', t.dataset.tab === tab));
    document.getElementById('panel-player').classList.toggle('hidden', tab !== 'player');
    document.getElementById('panel-vehicle').classList.toggle('hidden', tab !== 'vehicle');
    document.getElementById('panel-profile').classList.add('hidden');
}

function renderPlayers(list) {
    const el = document.getElementById('p-results');
    el.innerHTML = '';
    (list || []).forEach((p) => {
        const div = document.createElement('div');
        div.className = 'result';
        div.textContent = p.firstname + ' ' + p.lastname + ' (' + p.citizenid + ')';
        div.addEventListener('click', () => loadProfile(p.citizenid));
        el.appendChild(div);
    });
    if (!list || list.length === 0) el.innerHTML = '<div class="result">Ничего не найдено</div>';
}

function loadProfile(citizenid) {
    fetch('https://bu-policemd/getProfile', { method: 'POST', body: JSON.stringify({ citizenid: citizenid }) });
}

function renderProfile(data) {
    currentCid = data.citizenid;
    document.getElementById('panel-player').classList.add('hidden');
    document.getElementById('panel-vehicle').classList.add('hidden');
    document.getElementById('panel-profile').classList.remove('hidden');
    document.getElementById('pp-name').textContent = data.name;
    document.getElementById('pp-cid').textContent = data.citizenid;
    document.getElementById('pp-vehicles').textContent = (data.vehicles || []).map((v) => v.plate).join(', ') || 'нет';

    const w = document.getElementById('pp-warrants');
    w.innerHTML = '';
    (data.warrants || []).forEach((warrant) => {
        const div = document.createElement('div');
        div.className = 'warrant';
        div.innerHTML = '<span class="w-text">' + (warrant.reason || '') + '</span>' +
            '<span class="w-level" style="background:' + (currentLevels[warrant.level] || currentLevels.low) + '">' + (warrant.level || 'low') + '</span>' +
            '<button class="w-remove">✕</button>';
        div.querySelector('.w-remove').addEventListener('click', () => {
            fetch('https://bu-policemd/removeWarrant', { method: 'POST', body: JSON.stringify({ id: warrant.id }) });
        });
        w.appendChild(div);
    });
}

function renderVehicle(data) {
    const el = document.getElementById('v-results');
    el.innerHTML = '';
    if (!data.vehicle) { el.innerHTML = '<div class="result">ТС не найдено</div>'; return; }
    const v = data.vehicle;
    const div = document.createElement('div');
    div.className = 'result';
    div.textContent = 'Госномер: ' + v.plate + ' · Владелец: ' + (v.citizenid || '—');
    el.appendChild(div);
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.action === 'open') { mdt.classList.add('visible'); }
    if (message.action === 'close') { mdt.classList.remove('visible'); }

    if (message.action === 'players') { renderPlayers(message.data.players || []); }
    if (message.action === 'profile') { renderProfile(message.data); }
    if (message.action === 'vehicle') { renderVehicle(message.data); }

    if (message.action === 'refresh') {
        if (currentCid) loadProfile(currentCid);
    }
});

document.querySelectorAll('.tab').forEach((t) =>
    t.addEventListener('click', () => switchTab(t.dataset.tab)));

document.getElementById('p-search').addEventListener('click', () => {
    fetch('https://bu-policemd/searchPlayer', { method: 'POST', body: JSON.stringify({ query: document.getElementById('p-query').value }) });
});

document.getElementById('v-search').addEventListener('click', () => {
    fetch('https://bu-policemd/searchVehicle', { method: 'POST', body: JSON.stringify({ plate: document.getElementById('v-plate').value }) });
});

document.getElementById('w-add').addEventListener('click', () => {
    if (!currentCid) return;
    fetch('https://bu-policemd/addWarrant', { method: 'POST', body: JSON.stringify({
        citizenid: currentCid,
        reason: document.getElementById('w-reason').value,
        level: document.getElementById('w-level').value
    }) });
});

document.getElementById('pp-back').addEventListener('click', () => {
    document.getElementById('panel-profile').classList.add('hidden');
    switchTab('player');
});
