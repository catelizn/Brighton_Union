const overlay = document.getElementById('overlay');
const wheelEl = document.getElementById('wheel');
const spinBtn = document.getElementById('spin-btn');
const centerLabel = document.getElementById('center-label');

let rewards = [];
let spinning = false;

const palette = ['#2F8F83', '#D97706', '#4A7BA6', '#33445A', '#5FC3B4', '#EAB308', '#2F8F83', '#D97706',
    '#4A7BA6', '#33445A', '#5FC3B4', '#EAB308', '#2F8F83', '#D97706'];

function buildWheel(list) {
    rewards = list;
    const n = list.length;
    const angle = 360 / n;
    const parts = list.map((r, i) => palette[i % palette.length] + ' ' + (i * angle) + 'deg ' + ((i + 1) * angle) + 'deg');
    wheelEl.style.background = 'conic-gradient(' + parts.join(', ') + ')';

    wheelEl.querySelectorAll('.seg-label').forEach((x) => x.remove());
    const R = 118;
    list.forEach((r, i) => {
        const a = ((i * angle) + (angle / 2)) * Math.PI / 180;
        const x = 190 + Math.sin(a) * R;
        const y = 190 - Math.cos(a) * R;
        const label = document.createElement('div');
        label.className = 'seg-label';
        label.style.left = x + 'px';
        label.style.top = y + 'px';
        label.style.transform = 'translate(-50%,-50%) rotate(' + ((i * angle) + (angle / 2)) + 'deg)';
        label.textContent = r.label;
        wheelEl.appendChild(label);
    });
}

function spinTo(index) {
    const n = rewards.length;
    const angle = 360 / n;
    const target = 4 * 360 - (index - 0.5) * angle;
    wheelEl.style.transform = 'rotate(' + target + 'deg)';
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.action === 'open') {
        buildWheel(message.rewards);
        centerLabel.textContent = 'КРУТИ';
        spinBtn.disabled = false;
        spinBtn.textContent = 'Вращать ($' + message.cost + ')';
        overlay.classList.add('visible');
    }

    if (message.action === 'close') {
        overlay.classList.remove('visible');
        spinning = false;
        spinBtn.disabled = false;
    }

    if (message.action === 'spin') {
        spinTo(message.index);
        spinning = true;
        spinBtn.disabled = true;
        centerLabel.textContent = message.reward.label === 'Мимо' ? 'МИМО' : '+' + message.reward.label;
        setTimeout(() => {
            spinning = false;
            spinBtn.disabled = false;
        }, 3400);
    }
});

spinBtn.addEventListener('click', () => {
    if (spinning) return;
    fetch('https://bu-luckywheel/spin', { method: 'POST', body: '{}' });
});

document.getElementById('close-btn').addEventListener('click', () => {
    fetch('https://bu-luckywheel/close', { method: 'POST', body: '{}' });
});
