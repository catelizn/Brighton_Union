const overlay = document.getElementById('overlay');

function post(action) {
    fetch(`https://bu-documents/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({})
    });
}

function switchTab(tabName) {
    document.querySelectorAll('.tab').forEach((tab) => {
        tab.classList.toggle('active', tab.dataset.doctab === tabName);
    });
    document.getElementById('doc-passport').classList.toggle('hidden', tabName !== 'passport');
    document.getElementById('doc-licenses').classList.toggle('hidden', tabName !== 'licenses');
    document.getElementById('doc-driving').classList.toggle('hidden', tabName !== 'driving');
}

function renderPassport(data) {
    const container = document.getElementById('doc-passport');
    const charinfo = data.charinfo || {};
    const genderMap = { 0: 'Мужской', 1: 'Женский' };
    const nationality = charinfo.nationality === 'Russian Federation' ? 'Россия' : (charinfo.nationality || '—');

    container.innerHTML = `
        <div class="doc-card">
            <div class="doc-title">Паспорт гражданина Сан-Андреаса</div>
            <div class="doc-row"><span>Имя</span><span>${(charinfo.firstname || '—')} ${(charinfo.lastname || '').trim()}</span></div>
            <div class="doc-row"><span>Дата рождения</span><span>${charinfo.birthdate || '—'}</span></div>
            <div class="doc-row"><span>Национальность</span><span>${nationality}</span></div>
            <div class="doc-row"><span>Пол</span><span>${genderMap[charinfo.gender] !== undefined ? genderMap[charinfo.gender] : '—'}</span></div>
            <div class="doc-row"><span>Фото на документы</span><span>${data.photoDate || 'Не сделано — фотоателье в городе'}</span></div>
        </div>
    `;
}

function renderLicenses(data) {
    const container = document.getElementById('doc-licenses');
    const general = (data.licenses || []).filter((license) => !license.category);

    if (general.length === 0) {
        container.innerHTML = '<div class="doc-empty">Лицензий нет. Охота и рыбалка оформляются в мэрии.</div>';
        return;
    }

    container.innerHTML = general.map((license) => `
        <div class="doc-card">
            <div class="doc-title">${license.label}</div>
            <div class="doc-row"><span>Статус</span><span>Действительна</span></div>
        </div>
    `).join('');
}

function renderDriving(data) {
    const container = document.getElementById('doc-driving');
    const driving = (data.licenses || []).find((license) => license.category);

    if (!driving) {
        container.innerHTML = '<div class="doc-empty">Водительского удостоверения нет. Экзамены — в автошколе у Вайнвуда.</div>';
        return;
    }

    container.innerHTML = `
        <div class="doc-card">
            <div class="doc-title">Водительское удостоверение</div>
            <div class="doc-row"><span>Открытые категории</span><span>${driving.category}</span></div>
            <div class="doc-row"><span>Статус</span><span>Действительно</span></div>
        </div>
    `;
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:documents:open') {
        renderPassport(message.data);
        renderLicenses(message.data);
        renderDriving(message.data);
        switchTab('passport');
        overlay.classList.add('visible');
    }

    if (message.type === 'bu:documents:close') {
        overlay.classList.remove('visible');
    }
});

document.querySelectorAll('.tab').forEach((tab) => {
    tab.addEventListener('click', () => switchTab(tab.dataset.doctab));
});

document.getElementById('close-button').addEventListener('click', () => post('closeDocuments'));

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        post('closeDocuments');
    }
});
