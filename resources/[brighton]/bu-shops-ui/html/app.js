const windowEl = document.getElementById('shop-window');
const chipsEl = document.getElementById('chips');
const productsEl = document.getElementById('products');
const searchEl = document.getElementById('search');

let shopKey = '';
let items = [];
let category = 'Всё';
let search = '';

function post(action, data) {
    fetch(`https://bu-shops-ui/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

const categoryOf = (item) => {
    const drinks = ['water', 'water_bottle', 'kurkakola', 'coffee', 'beer', 'whiskey', 'vodka', 'wine', 'grapejuice'];
    const food = ['sandwich', 'tosti', 'twerks_candy', 'snikkel_candy', 'burger', 'fries', 'hotdog', 'chocolate'];
    if (drinks.includes(item.name)) return 'Напитки';
    if (food.includes(item.name)) return 'Еда';
    if (item.type === 'tool' || item.name.includes('kit') || item.name.includes('repair')) return 'Инструменты';
    return 'Другое';
};

// Название из общей базы предметов; если позиции там нет — читаемые слова
const labelOf = (item) => item.label || String(item.name || '').replace(/_/g, ' ');

function renderChips() {
    const categories = ['Всё'];
    items.forEach((item) => {
        const cat = categoryOf(item);
        if (!categories.includes(cat)) categories.push(cat);
    });

    chipsEl.innerHTML = '';
    categories.forEach((cat) => {
        const chip = document.createElement('button');
        chip.className = 'chip' + (cat === category ? ' active' : '');
        chip.textContent = cat;
        chip.addEventListener('click', () => {
            category = cat;
            renderChips();
            renderProducts();
        });
        chipsEl.appendChild(chip);
    });
}

function renderProducts() {
    productsEl.innerHTML = '';
    const query = search.trim().toLowerCase();

    items
        .filter((item) => category === 'Всё' || categoryOf(item) === category)
        .filter((item) => !query || labelOf(item).toLowerCase().includes(query))
        .forEach((item, index) => {
            const card = document.createElement('div');
            card.className = 'product-card';
            card.style.animationDelay = (index * 0.03) + 's';

            const imageName = (item.image || item.name || '') + '.png';
            const emoji = categoryOf(item) === 'Напитки' ? '🥤' : categoryOf(item) === 'Еда' ? '🍔' : categoryOf(item) === 'Инструменты' ? '🔧' : '📦';

            card.innerHTML = `
                <div class="product-head">
                    <span class="product-name">${labelOf(item)}</span>
                    <span class="product-stock">${item.amount && item.amount > 0 ? item.amount + ' шт' : '∞'}</span>
                </div>
                <img class="product-image" src="nui://qb-inventory/html/images/${imageName}" alt=""
                    onerror="this.classList.add('missing'); this.style.background='none'; this.removeAttribute('src'); this.textContent='${emoji}';" />
                <div class="product-shade"></div>
                <div class="product-price">$${Number(item.price).toLocaleString('ru-RU')}</div>
                <div class="product-actions">
                    <button class="pay-button" data-slot="${item.slot}" data-payment="cash">Наличные</button>
                    <button class="pay-button bank" data-slot="${item.slot}" data-payment="bank">Карта</button>
                </div>
            `;
            productsEl.appendChild(card);
        });

    productsEl.querySelectorAll('.pay-button').forEach((button) => {
        button.addEventListener('click', () => {
            post('buy', { shop: shopKey, slot: button.dataset.slot, amount: 1, payment: button.dataset.payment });
        });
    });
}

let searchTimer = null;
searchEl.addEventListener('input', () => {
    clearTimeout(searchTimer);
    searchTimer = setTimeout(() => {
        search = searchEl.value;
        renderProducts();
    }, 150);
});

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:shops:open') {
        shopKey = message.shop;
        items = message.items || [];
        category = 'Всё';
        search = '';
        searchEl.value = '';
        document.getElementById('shop-title').textContent = message.label || 'Магазин';
        document.body.classList.add('open');
        renderChips();
        renderProducts();
    }

    if (message.type === 'bu:shops:close') {
        document.body.classList.remove('open');
    }
});
