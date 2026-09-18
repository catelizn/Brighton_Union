const hint = document.getElementById('hint');
const hintText = document.getElementById('hint-text');

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message || message.type !== 'bu:hint') return;

    if (message.text) {
        hintText.textContent = message.text;
        hint.classList.add('visible');
    } else {
        hint.classList.remove('visible');
    }
});
