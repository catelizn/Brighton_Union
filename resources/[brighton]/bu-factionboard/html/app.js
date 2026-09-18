const overlay = document.getElementById('overlay');
const boardEl = document.getElementById('board');

function render(data) {
    if (!data || data.type === 'none') {
        boardEl.innerHTML = '<div class="b-row">Ты не состоишь ни в семье, ни в банде, ни в мафии</div>';
        return;
    }

    let html = '<div class="b-row"><span>Организация</span><span>' + data.name + '</span></div>';
    html += '<div class="b-row"><span>Казна</span><span>$' + (data.money || 0) + '</span></div>';
    if (data.type === 'family') html += '<div class="b-row"><span>Твой ранг</span><span>' + data.rank + '</span></div>';
    if (data.type === 'gang') html += '<div class="b-row"><span>Захвачено</span><span>' + (data.zones || 0) + '</span></div>';
    if (data.type === 'mafia') html += '<div class="b-row"><span>Бизнесы</span><span>' + (data.control || 0) + '</span></div>';

    if (data.type === 'family' && data.members) {
        html += '<div class="members"><div class="m-title">Участники</div>';
        data.members.forEach((m) => {
            html += '<div class="member"><span>' + (m.firstname || '') + ' ' + (m.lastname || '') + '</span><span class="rank">' + m.rank + '</span></div>';
        });
        html += '</div>';
    }

    boardEl.innerHTML = html;
}

function fetchData() { fetch('https://bu-factionboard/get', { method: 'POST', body: '{}' }); }

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;
    if (message.action === 'open') { overlay.classList.add('visible'); fetchData(); }
    if (message.action === 'close') { overlay.classList.remove('visible'); }
    if (message.action === 'data') { render(message.data); }
});

document.getElementById('deposit-btn').addEventListener('click', () => {
    const amount = document.getElementById('amount').value;
    fetch('https://bu-factionboard/deposit', { method: 'POST', body: JSON.stringify({ amount: amount }) });
    setTimeout(fetchData, 500);
});

document.getElementById('close-btn').addEventListener('click', () => fetch('https://bu-factionboard/close', { method: 'POST', body: '{}' }));

// Закрытие доски по Esc
window.addEventListener('keydown', (e) => {
    if (e.key === 'Escape' && overlay.classList.contains('visible')) {
        fetch('https://bu-factionboard/close', { method: 'POST', body: '{}' });
    }
});
