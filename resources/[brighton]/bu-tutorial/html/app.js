const overlay = document.getElementById('overlay');
const progressFill = document.getElementById('progress-fill');
const progressText = document.getElementById('progress-text');
const dialogText = document.getElementById('dialog-text');
const rewardLine = document.getElementById('task-reward');
const advanceButton = document.getElementById('advance-button');
const okButton = document.getElementById('ok-button');
const closeButton = document.getElementById('close-button');

function post(action) {
    fetch(`https://bu-tutorial/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function hideOverlay() {
    overlay.classList.remove('visible');
    post('close');
}

// Одно окно на всё: реплика NPC, награда и одна кнопка.
window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:tutorial:open') {
        const data = message.data;

        document.getElementById('npc-name').textContent = data.npcName;
        document.getElementById('quest-label').textContent = data.label;
        document.getElementById('npc-avatar').textContent =
            data.npcName.split(' ').map((word) => word[0]).join('').slice(0, 2);

        const progress = data.completed ? 100 : Math.round((data.stage / data.total) * 100);
        progressFill.style.width = progress + '%';
        progressText.textContent = data.stage + ' / ' + data.total;

        advanceButton.classList.add('hidden');
        okButton.classList.add('hidden');
        rewardLine.classList.add('hidden');

        if (data.completed) {
            dialogText.textContent = 'Путь новичка пройден. Хорошей игры в Лос-Сантосе!';
            okButton.textContent = 'Закрыть';
            okButton.classList.remove('hidden');
        } else if (data.task) {
            dialogText.textContent = data.task.text;
            if (data.task.reward) {
                rewardLine.textContent = 'Награда: $' + data.task.reward.toLocaleString('ru-RU');
                rewardLine.classList.remove('hidden');
            }
            if (data.canTurnIn) {
                advanceButton.classList.remove('hidden');
            } else {
                okButton.textContent = 'Хорошо';
                okButton.classList.remove('hidden');
            }
        }

        overlay.classList.add('visible');
    }

    if (message.type === 'bu:tutorial:close') {
        overlay.classList.remove('visible');
    }
});

advanceButton.addEventListener('click', () => post('advance'));
okButton.addEventListener('click', hideOverlay);
closeButton.addEventListener('click', hideOverlay);

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') hideOverlay();
});
