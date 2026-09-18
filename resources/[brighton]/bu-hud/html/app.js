const hud = document.getElementById('hud');
const armorWrap = document.getElementById('armor-wrap');

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

    if (message.type === 'bu:hud:quest') {
        const panel = document.getElementById('quest-panel');
        if (message.hide) {
            panel.classList.add('hidden');
            return;
        }
        const data = message.data;
        document.getElementById('quest-hint').textContent = data.hint;
        document.getElementById('quest-step').textContent = data.stage + '/' + data.total;
        document.getElementById('quest-check').classList.toggle('done', data.done === true);
        panel.classList.remove('hidden');
    }

    if (message.type === 'bu:hud:toggleHints') {
        const hidden = hints.classList.toggle('hidden');
        localStorage.setItem('bu-hud-hints', hidden ? '0' : '1');
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

        // Выносливость всегда видна
        setRing('ring-stamina', 'text-stamina', data.stamina);
        const staminaEl = document.getElementById('ring-stamina');
        staminaEl.classList.remove('hidden');

    }
});

// Скрытие подсказок запоминается (переключается клавишей F6)
const hints = document.getElementById('hints');
if (localStorage.getItem('bu-hud-hints') === '0') {
    hints.classList.add('hidden');
}
