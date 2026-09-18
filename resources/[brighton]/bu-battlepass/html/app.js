const overlay = document.getElementById('overlay');
const tiersEl = document.getElementById('tiers');
const barFill = document.getElementById('bar-fill');
const barLabel = document.getElementById('bar-label');

let state = null;

function render(data) {
    state = data;
    document.getElementById('season').textContent = 'Сезон ' + data.season;
    const pct = Math.min(100, (data.xp / (data.maxTier * data.xpPerTier)) * 100);
    barFill.style.width = pct + '%';
    barLabel.textContent = 'XP: ' + data.xp + ' · Ярус ' + data.tier + '/' + data.maxTier;

    tiersEl.innerHTML = '';
    for (let i = 1; i <= data.maxTier; i++) {
        const r = data.tiers[i] || {};
        const reward = (r.cash ? '$' + r.cash : '') + (r.item ? ' + ' + r.item.amount + 'x' + r.item.name : '');
        const unlocked = data.tier >= i;
        const claimed = !!(data.claimed || {})[i];

        const div = document.createElement('div');
        div.className = 'tier' + (unlocked ? '' : ' locked');
        div.innerHTML = '<span class="t-num">Ярус ' + i + '</span><span class="t-reward">' + reward + '</span>' +
            '<button class="t-claim" data-t="' + i + '"' + ((unlocked && !claimed) ? '' : ' disabled') + '>' + (claimed ? 'Получено' : (unlocked ? 'Забрать' : '—')) + '</button>';
        div.querySelector('.t-claim').addEventListener('click', (e) => {
            fetch('https://bu-battlepass/claim', { method: 'POST', body: JSON.stringify({ tier: e.target.dataset.t }) });
            setTimeout(fetchState, 500);
        });
        tiersEl.appendChild(div);
    }
}

function fetchState() {
    fetch('https://bu-battlepass/getState', { method: 'POST', body: '{}' });
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;
    if (message.action === 'open') { overlay.classList.add('visible'); fetchState(); }
    if (message.action === 'close') { overlay.classList.remove('visible'); }
    if (message.action === 'state') { render(message.data); }
});

document.getElementById('close-btn').addEventListener('click', () => {
    fetch('https://bu-battlepass/close', { method: 'POST', body: '{}' });
});
