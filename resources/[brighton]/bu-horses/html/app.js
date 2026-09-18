const overlay = document.getElementById('overlay');
const horsesEl = document.getElementById('horses');
const statusEl = document.getElementById('status');
const poolEl = document.getElementById('pool');

let horses = [];
let selected = null;
let racing = false;

function renderHorses(list) {
    horses = list;
    horsesEl.innerHTML = '';
    list.forEach((h, i) => {
        const el = document.createElement('div');
        el.className = 'horse';
        el.innerHTML = '<span class="horse-dot" style="background:hsl(' + (h.color * 40) + ',70%,55%)"></span><span class="horse-name">' + h.name + '</span>';
        el.addEventListener('click', () => {
            selected = i + 1;
            horsesEl.querySelectorAll('.horse').forEach((x, j) => x.classList.toggle('selected', j === i));
        });
        horsesEl.appendChild(el);
    });
}

function fetchState() {
    fetch('https://bu-horses/getState', { method: 'POST', body: '{}' });
}

function showTrack() {
    horsesEl.innerHTML = '';
    horses.forEach((h, i) => {
        const track = document.createElement('div');
        track.className = 'race-track';
        track.innerHTML = '<div class="track"><div class="runner" id="runner-' + i + '" style="background:hsl(' + (h.color * 40) + ',70%,55%)"></div></div>';
        horsesEl.appendChild(track);
    });
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.action === 'open') {
        overlay.classList.add('visible');
        statusEl.textContent = 'Ожидание заезда…';
        fetchState();
    }

    if (message.action === 'close') {
        overlay.classList.remove('visible');
    }

    if (message.action === 'state') {
        renderHorses(message.state.horses || []);
        statusEl.textContent = message.state.stage === 'betting' ? 'Ставки открыты' : 'Ставки закрыты';
        poolEl.textContent = 'Банк: $' + (message.state.pool || 0);
    }

    if (message.action === 'race') {
        racing = true;
        statusEl.textContent = 'ЗАЕЗД!';
        showTrack();
        let t = 0;
        const timer = setInterval(() => {
            t += 0.2;
            document.querySelectorAll('.runner').forEach((r, i) => {
                const progress = Math.max(0, Math.min(1, (t / 12) + (Math.sin(i + t * 3) * 0.08)));
                r.style.left = (progress * 100) + '%';
            });
            if (t >= 14) { clearInterval(timer); racing = false; }
        }, 200);
    }

    if (message.action === 'reset') {
        racing = false;
        statusEl.textContent = 'Ожидание заезда…';
        fetchState();
    }
});

document.getElementById('bet-btn').addEventListener('click', () => {
    if (racing || !selected) return;
    const amount = document.getElementById('amount').value;
    fetch('https://bu-horses/bet', { method: 'POST', body: JSON.stringify({ horse: selected, amount: amount }) });
});

document.getElementById('close-btn').addEventListener('click', () => {
    fetch('https://bu-horses/close', { method: 'POST', body: '{}' });
});
