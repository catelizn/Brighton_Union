const overlay = document.getElementById('overlay');
const stagesContainer = document.getElementById('stages');
const progressFill = document.getElementById('progress-fill');
const progressText = document.getElementById('progress-text');
const advanceButton = document.getElementById('advance-button');
const closeButton = document.getElementById('close-button');
const toast = document.getElementById('toast');

let currentState = { stage: 0, completed: false, stages: [] };
let toastTimer = null;

function showToast(text) {
    toast.textContent = text;
    toast.classList.add('visible');
    clearTimeout(toastTimer);
    toastTimer = setTimeout(() => toast.classList.remove('visible'), 4500);
}

function render() {
    const { stages, stage, completed } = currentState;
    const total = stages.length;

    stagesContainer.innerHTML = '';

    stages.forEach((item, index) => {
        const stageNumber = index + 1;
        const row = document.createElement('div');

        let status;
        if (completed || stageNumber <= stage) {
            status = 'done';
        } else if (stageNumber === stage + 1) {
            status = 'current';
        } else {
            status = 'locked';
        }
        row.className = 'stage ' + status;

        let icon = stageNumber;
        if (completed || stageNumber <= stage) {
            icon = '✓';
        }

        row.innerHTML = `
            <div class="stage-icon">${icon}</div>
            <div class="stage-body">
                <div class="stage-title">${stageNumber}. ${item.title}</div>
                <div class="stage-text">${item.text}</div>
                ${item.reward ? `<span class="stage-reward">Награда: $${item.reward.toLocaleString('ru-RU')}</span>` : ''}
            </div>
        `;
        stagesContainer.appendChild(row);
    });

    const progress = completed ? 100 : Math.min(Math.round((stage / total) * 100), 100);
    progressFill.style.width = progress + '%';
    progressText.textContent = `${completed ? total : stage} / ${total}`;

    if (completed) {
        advanceButton.disabled = true;
        advanceButton.textContent = 'Пройдено';
    } else if (stage === total) {
        advanceButton.disabled = true;
        advanceButton.textContent = 'Пройдено';
    } else {
        advanceButton.disabled = false;
        advanceButton.textContent = stage === 0 ? 'Начать' : 'Продолжить';
    }
}

function post(action) {
    fetch(`https://bu-tutorial/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:tutorial:arrival') {
        document.getElementById('arrival').classList.toggle('visible', message.show);
    }

    if (message.type === 'bu:tutorial:open') {
        currentState = {
            stage: message.data.stage,
            completed: message.data.completed,
            stages: message.data.stages
        };
        document.getElementById('npc-name').textContent = message.data.npcName;
        document.getElementById('quest-label').textContent = message.data.label;
        const initials = message.data.npcName.split(' ').map((word) => word[0]).join('').slice(0, 2);
        document.getElementById('npc-avatar').textContent = initials;
        overlay.classList.add('visible');
        render();
    }

    if (message.type === 'bu:tutorial:update') {
        currentState.stage = message.data.stage;
        currentState.completed = message.data.completed;
        render();
    }
});

advanceButton.addEventListener('click', () => post('advance'));
closeButton.addEventListener('click', () => post('close'));

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        post('close');
    }
});

document.addEventListener('DOMContentLoaded', () => {
    if (!overlay.classList.contains('visible')) return;
});
