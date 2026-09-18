const radial = document.getElementById('radial');
let items = [];

function layout() {
    radial.innerHTML = '';
    const n = items.length;
    const R = 150;
    items.forEach((item, i) => {
        const angle = (i / n) * Math.PI * 2 - Math.PI / 2;
        const x = Math.cos(angle) * R;
        const y = Math.sin(angle) * R;
        const el = document.createElement('div');
        el.className = 'item';
        el.style.left = (50 + x) + '%';
        el.style.top = (50 + y) + '%';
        el.style.transform = 'translate(-50%,-50%)';
        el.innerHTML = '<span class="ico">' + item.icon + '</span><span class="lbl">' + item.label + '</span>';
        el.addEventListener('click', () => {
            fetch('https://bu-radial/action', { method: 'POST', body: JSON.stringify({ id: item.id }) });
        });
        radial.appendChild(el);
    });
}

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;
    if (message.action === 'open') { items = message.items; radial.classList.add('visible'); layout(); }
    if (message.action === 'close') { radial.classList.remove('visible'); }
});
