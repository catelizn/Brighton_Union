const hud = document.getElementById('hud');

const format = (value) => '$' + Number(value || 0).toLocaleString('ru-RU');

function setBar(id, percent, className) {
    const bar = document.getElementById(id);
    bar.style.width = Math.max(0, Math.min(100, percent)) + '%';
    bar.className = 'bar-fill ' + className;
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

        setBar('bar-health', data.health, 'health');
        setBar('bar-armor', data.armor, 'armor');
        setBar('bar-hunger', data.hunger, 'hunger');
        setBar('bar-thirst', data.thirst, 'thirst');
        setBar('bar-stress', 100 - data.stress, 'stress');

        document.getElementById('money-cash').textContent = format(data.cash);
        document.getElementById('money-bank').textContent = format(data.bank);
        document.getElementById('location').textContent = data.location;
        document.getElementById('online').textContent = data.online;

        const quest = document.getElementById('quest');
        if (data.quest) {
            quest.style.display = 'block';
            quest.textContent = data.quest;
        } else {
            quest.style.display = 'none';
        }

        const now = new Date();
        const time = now.toLocaleTimeString('ru-RU', { hour: '2-digit', minute: '2-digit' });
        document.getElementById('clock').textContent = time;
    }
});
