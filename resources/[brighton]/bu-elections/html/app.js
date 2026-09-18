const overlay = document.getElementById('overlay');
const candidatesEl = document.getElementById('candidates');
const statusEl = document.getElementById('status');

function render(data) {
    statusEl.textContent = data.active ? 'Выборы идут' : 'Выборы завершены / ожидание';
    candidatesEl.innerHTML = '';
    (data.candidates || []).forEach((c) => {
        const div = document.createElement('div');
        div.className = 'cand';
        div.innerHTML = '<div class="c-info"><span class="c-name">' + c.name + '</span><span class="c-votes">' + c.votes + ' голосов</span></div>' +
            '<button class="cand-vote" data-cid="' + c.citizenid + '">Голосовать</button>';
        div.querySelector('.cand-vote').addEventListener('click', () => {
            fetch('https://bu-elections/vote', { method: 'POST', body: JSON.stringify({ citizenid: c.citizenid }) });
        });
        candidatesEl.appendChild(div);
    });
    if (!data.candidates || data.candidates.length === 0) {
        candidatesEl.innerHTML = '<div class="cand"><span class="c-votes">Пока нет кандидатов</span></div>';
    }
}

function fetchState() {
    fetch('https://bu-elections/getState', { method: 'POST', body: '{}' });
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;
    if (message.action === 'open') { overlay.classList.add('visible'); fetchState(); }
    if (message.action === 'close') { overlay.classList.remove('visible'); }
    if (message.action === 'state') { render(message.data); }
    if (message.action === 'refresh') { fetchState(); }
});

document.getElementById('run-btn').addEventListener('click', () => {
    fetch('https://bu-elections/run', { method: 'POST', body: '{}' });
    setTimeout(fetchState, 600);
});

document.getElementById('close-btn').addEventListener('click', () => {
    fetch('https://bu-elections/close', { method: 'POST', body: '{}' });
});
