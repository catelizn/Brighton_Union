const badge = document.getElementById('zone-badge');
const zoneName = document.getElementById('zone-name');

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message || message.type !== 'zone') return;

    badge.classList.toggle('visible', message.show === true);
    zoneName.textContent = message.name || '';
});
