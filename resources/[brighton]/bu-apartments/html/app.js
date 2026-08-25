const overlay = document.getElementById('overlay');
const buildingLabel = document.getElementById('building-label');
const flatsGrid = document.getElementById('flats-grid');
const notice = document.getElementById('notice');
const leaveButton = document.getElementById('leave-button');
const interiorSection = document.getElementById('interior-section');
const interiorButtons = document.getElementById('interior-buttons');

let buildingKey = '';
let interiors = [];

function post(action, data) {
    fetch(`https://bu-apartments/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

function renderInteriors() {
    interiorButtons.innerHTML = '';
    interiors.forEach((item) => {
        const button = document.createElement('button');
        button.className = 'interior-button';
        button.textContent = `${item.label} — $${Number(item.price).toLocaleString('ru-RU')}`;
        button.addEventListener('click', () => post('interior', { interior: item.id }));
        interiorButtons.appendChild(button);
    });
}

function render(data, inside, flat) {
    buildingKey = data.key;
    interiors = data.interiors || [];
    buildingLabel.textContent = data.label;
    flatsGrid.innerHTML = '';

    data.flats.forEach((item) => {
        const cell = document.createElement('div');

        if (item.owner && item.owner !== 'me') {
            cell.className = 'flat owned-other';
            cell.textContent = item.number;
        } else if (inside && flat === item.number) {
            cell.className = 'flat mine';
            cell.innerHTML = `${item.number}<span class="flat-price">Ты внутри</span>`;
        } else if (item.owner === 'me') {
            cell.className = 'flat mine';
            cell.innerHTML = `${item.number}<span class="flat-price">Моя</span>`;
            cell.addEventListener('click', () => post('enter', { number: item.number }));
        } else {
            cell.className = 'flat free';
            cell.innerHTML = `${item.number}<span class="flat-price">$${Number(item.price).toLocaleString('ru-RU')}</span>`;
            cell.addEventListener('click', () => post('buy', { building: data.key, number: item.number }));
        }

        flatsGrid.appendChild(cell);
    });

    interiorSection.classList.toggle('hidden', !inside);
    if (inside) {
        renderInteriors();
    }

    leaveButton.classList.toggle('hidden', !inside);
    notice.textContent = inside
        ? `Квартира №${flat}. Мебель покупается и меняется ниже.`
        : 'Серые квартиры куплены, зелёные — твои. Нажми на свободную, чтобы купить.';
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:apartments:open') {
        render(message.data, message.inside, message.flat);
        overlay.classList.add('visible');
    }

    if (message.type === 'bu:apartments:close') {
        overlay.classList.remove('visible');
    }
});

document.getElementById('close-button').addEventListener('click', () => post('close'));
leaveButton.addEventListener('click', () => post('leave'));

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        post('close');
    }
});
