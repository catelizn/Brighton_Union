window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'init' && message.theme) {
        document.body.className = 'theme-' + (message.theme === 'brooklyn' ? 'brooklyn' : 'asphalt');
    }

    if (message.action === 'hide') {
        document.body.style.display = 'none';
    }
});
