const hud = document.getElementById('hud');
const armorWrap = document.getElementById('armor-wrap');

const money = (value) => '$' + Number(value || 0).toLocaleString('ru-RU');

function setRing(id, textId, percent) {
    const ring = document.getElementById(id);
    const p = Math.max(0, Math.min(100, Math.round(percent)));
    ring.style.setProperty('--p', p);
    document.getElementById(textId).textContent = p + '%';
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:hud:show') {
        hud.classList.add('visible');
    }

    if (message.type === 'bu:hud:hide') {
        hud.classList.remove('visible');
    }

    if (message.type === 'bu:hud:update') {
        const data = message.data;

        setRing('ring-health', 'text-health', data.health);
        setRing('ring-hunger', 'text-hunger', data.hunger);
        setRing('ring-thirst', 'text-thirst', data.thirst);

        // Броня: кольцо вокруг здоровья, только когда она есть
        if (data.armor > 0) {
            armorWrap.style.setProperty('--p', Math.max(0, Math.min(100, Math.round(data.armor))));
            armorWrap.classList.add('on');
        } else {
            armorWrap.classList.remove('on');
        }

        // Выносливость видна, только когда персонаж устал
        const stamina = document.getElementById('ring-stamina');
        if (data.stamina < 99) {
            setRing('ring-stamina', 'text-stamina', data.stamina);
            stamina.classList.remove('hidden');
        } else {
            stamina.classList.add('hidden');
        }

        document.getElementById('money-cash').textContent = money(data.cash);
        document.getElementById('money-bank').textContent = money(data.bank);
        document.getElementById('location').textContent = data.location;
        document.getElementById('online').textContent = data.online;

        if (data.time) {
            const hh = String(data.time.hour).padStart(2, '0');
            const mm = String(data.time.minute).padStart(2, '0');
            document.getElementById('clock').textContent = hh + ':' + mm;
        }

        const quest = document.getElementById('quest');
        if (data.quest) {
            quest.style.display = 'block';
            quest.textContent = data.quest;
        } else {
            quest.style.display = 'none';
        }
    }
});

// Скрытие подсказок запоминается
const hints = document.getElementById('hints');
if (localStorage.getItem('bu-hud-hints') === '0') {
    hints.classList.add('hidden');
}

document.getElementById('hints-hide').addEventListener('click', () => {
    const hidden = hints.classList.toggle('hidden');
    localStorage.setItem('bu-hud-hints', hidden ? '0' : '1');
});
