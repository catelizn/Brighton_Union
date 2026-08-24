const overlay = document.getElementById('overlay');
const vehiclesContainer = document.getElementById('vehicles');
const notice = document.getElementById('notice');
const hoursSelect = document.getElementById('hours-select');

let activeRental = false;
let currentVehicles = [];

const icons = {
    'bmx': '🚲',
    'faggio': '🛵',
    'asea': '🚗',
    'washington': '🚗'
};

function post(action, data) {
    fetch(`https://bu-rental/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

function selectedHours() {
    return Number(hoursSelect.value) || 1;
}

function render(vehicles) {
    vehiclesContainer.innerHTML = '';
    currentVehicles = vehicles;

    vehicles.forEach((vehicle) => {
        const card = document.createElement('div');
        card.className = 'vehicle-card';

        const actions = vehicle.available
            ? `
                <button class="pay-button bank" data-id="${vehicle.id}" data-payment="bank">Карта</button>
                <button class="pay-button cash" data-id="${vehicle.id}" data-payment="cash">Наличные</button>
            `
            : '<span class="locked-note">Нужны права B</span>';

        card.innerHTML = `
            <div class="vehicle-icon">${icons[vehicle.model] || '🚗'}</div>
            <div class="vehicle-info">
                <div class="vehicle-label">${vehicle.label}</div>
                <div class="vehicle-price" data-price-id="${vehicle.id}">$${vehicle.price.toLocaleString('ru-RU')} в час</div>
                <div class="vehicle-total" data-total-id="${vehicle.id}"></div>
            </div>
            <div class="vehicle-actions">${actions}</div>
        `;
        vehiclesContainer.appendChild(card);
    });

    updateTotals();
    cardListeners();
}

function updateTotals() {
    const hours = selectedHours();
    currentVehicles.forEach((vehicle) => {
        const total = document.querySelector(`[data-total-id="${vehicle.id}"]`);
        if (total) {
            total.textContent = `Итого за ${hours} ч: $${(vehicle.price * hours).toLocaleString('ru-RU')}`;
        }
    });
}

function cardListeners() {
    document.querySelectorAll('.pay-button').forEach((button) => {
        button.addEventListener('click', () => {
            post('rent', {
                vehicleId: button.dataset.id,
                payment: button.dataset.payment,
                hours: selectedHours()
            });
        });
    });
}

hoursSelect.addEventListener('change', updateTotals);

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:rental:open') {
        activeRental = message.data.active;
        notice.textContent = activeRental
            ? 'У тебя уже есть арендованный транспорт. Сначала верни его через «Вернуть транспорт».'
            : 'Выбери транспорт и срок аренды. Машины требуют права категории B.';
        overlay.classList.add('visible');
        render(message.data.vehicles);
    }
});

document.getElementById('close-button').addEventListener('click', () => post('close'));

document.addEventListener('keyup', (event) => {
    if (event.key === 'Escape') {
        post('close');
    }
});
