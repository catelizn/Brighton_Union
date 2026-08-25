const tips = [
    'Новички начинают путь в аэропорту — тебя встретит Mike Ford',
    'Планшет открывается на стрелку вниз, телефон — на стрелку вверх',
    'На работу устраиваются у NPC на месте, а не в мэрии',
    'Банк работает с 09:00 до 21:00, банкоматы — круглосуточно',
    'Права получают в автошколе: теория и практика',
    'Недвижимость покупается через маркер у двери',
];

let tipIndex = Math.floor(Math.random() * tips.length);

function renderTips() {
    const container = document.getElementById('tips');
    const tip = document.createElement('div');
    tip.className = 'tip';
    tip.textContent = tips[tipIndex];
    container.appendChild(tip);

    setTimeout(() => {
        tip.classList.add('visible');
    }, 1200);

    setTimeout(() => {
        tip.classList.remove('visible');
        setTimeout(() => {
            tip.remove();
            tipIndex = (tipIndex + 1) % tips.length;
            renderTips();
        }, 600);
    }, 6000);
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'init') {
        document.body.className = 'theme-' + (message.theme === 'brooklyn' ? 'brooklyn' : 'asphalt');
        document.getElementById('max-clients').textContent = message.maxClients;
        renderTips();
    }
});
