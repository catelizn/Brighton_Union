const overlay = document.getElementById('overlay');
const viewList = document.getElementById('view-list');
const viewTheory = document.getElementById('view-theory');
const viewExam = document.getElementById('view-exam');
const categoriesContainer = document.getElementById('categories');
const theoryRow = document.getElementById('theory-row');
const examTitle = document.getElementById('exam-title');
const examProgressFill = document.getElementById('exam-progress-fill');
const examProgressText = document.getElementById('exam-progress-text');

let theoryPassed = false;

function post(action, data) {
    fetch(`https://bu-drivingschool/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

function showView(view) {
    viewList.classList.add('hidden');
    viewTheory.classList.add('hidden');
    viewExam.classList.add('hidden');
    view.classList.remove('hidden');
}

function renderTheoryRow() {
    theoryRow.innerHTML = theoryPassed
        ? '<span class="theory-passed">Теория сдана ✓</span>'
        : '<button class="pay-button bank" id="theory-button">Сдать теоретический экзамен</button>';

    const button = document.getElementById('theory-button');
    if (button) {
        button.addEventListener('click', () => {
            renderTheory();
            showView(viewTheory);
        });
    }
}

function renderTheory() {
    const container = document.getElementById('theory-questions');
    container.innerHTML = '';

    if (!window.theoryData) return;

    window.theoryData.forEach((question, index) => {
        const block = document.createElement('div');
        block.className = 'theory-question';

        const options = question.options.map((option, optionIndex) => `
            <label class="theory-option">
                <input type="radio" name="q${index}" value="${optionIndex + 1}" />
                <span>${option}</span>
            </label>
        `).join('');

        block.innerHTML = `
            <div class="theory-question-text">${index + 1}. ${question.question}</div>
            <div class="theory-options">${options}</div>
        `;
        container.appendChild(block);
    });
}

function renderCategories(categories) {
    categoriesContainer.innerHTML = '';

    categories.forEach((category) => {
        const card = document.createElement('div');
        card.className = 'category-card';

        let actions;
        if (category.owned) {
            actions = '<span class="category-owned">Открыта ✓</span>';
        } else if (category.theory && !theoryPassed) {
            actions = '<span class="locked-note">Сначала теория</span>';
        } else {
            actions = `
                <button class="pay-button bank" data-key="${category.key}" data-payment="bank">Карта</button>
                <button class="pay-button cash" data-key="${category.key}" data-payment="cash">Наличные</button>
            `;
        }

        card.innerHTML = `
            <div class="category-label">${category.label}</div>
            <div class="category-price">${category.owned ? '' : '$' + category.price.toLocaleString('ru-RU')}</div>
            <div class="category-actions">${actions}</div>
        `;
        categoriesContainer.appendChild(card);
    });

    categoriesContainer.querySelectorAll('.pay-button').forEach((button) => {
        button.addEventListener('click', () => {
            post('start', {
                category: button.dataset.key,
                payment: button.dataset.payment
            });
        });
    });
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:exam:open') {
        theoryPassed = message.data.theoryPassed === true;
        window.theoryData = message.data.theory || [];
        window.categoryData = message.data.categories || [];
        renderTheoryRow();
        renderCategories(message.data.categories);
        showView(viewList);
        overlay.classList.add('visible');
    }

    if (message.type === 'bu:exam:theoryPassed') {
        theoryPassed = true;
        renderTheoryRow();
        if (window.categoryData) renderCategories(window.categoryData);
        showView(viewList);
    }

    if (message.type === 'bu:exam:started') {
        examTitle.textContent = 'Экзамен на категорию ' + message.data.category;
        examProgressText.textContent = '0 / ' + message.data.total;
        examProgressFill.style.width = '0%';
        showView(viewExam);
        overlay.classList.add('visible');
    }

    if (message.type === 'bu:exam:progress') {
        examProgressText.textContent = message.data.current + ' / ' + message.data.total;
        examProgressFill.style.width = Math.round((message.data.current / message.data.total) * 100) + '%';
    }

    if (message.type === 'bu:exam:finished') {
        overlay.classList.remove('visible');
    }
});

document.getElementById('close-button').addEventListener('click', () => post('close'));
document.getElementById('cancel-button').addEventListener('click', () => post('cancel'));

document.getElementById('theory-submit').addEventListener('click', () => {
    const answers = [];
    (window.theoryData || []).forEach((_, index) => {
        const selected = document.querySelector(`input[name="q${index}"]:checked`);
        answers[index + 1] = selected ? Number(selected.value) : 0;
    });
    post('theory', { answers: answers });
});

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        post('close');
    }
});
