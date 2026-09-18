const tabLogin = document.getElementById('tab-login');
const tabRegister = document.getElementById('tab-register');
const username = document.getElementById('username');
const password = document.getElementById('password');
const error = document.getElementById('error');
const submit = document.getElementById('submit');

let mode = 'login';

function setMode(next) {
    mode = next;
    error.textContent = '';
    if (mode === 'login') {
        tabLogin.classList.add('active');
        tabRegister.classList.remove('active');
        submit.textContent = 'Войти';
    } else {
        tabRegister.classList.add('active');
        tabLogin.classList.remove('active');
        submit.textContent = 'Создать аккаунт';
    }
}

tabLogin.addEventListener('click', () => setMode('login'));
tabRegister.addEventListener('click', () => setMode('register'));

function post(action, data) {
    fetch(`https://bu-auth/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data || {})
    });
}

submit.addEventListener('click', () => {
    const name = username.value.trim();
    const pass = password.value;
    if (!name || !pass) {
        error.textContent = 'Заполни логин и пароль.';
        return;
    }
    error.textContent = '';
    post('submit', { mode, username: name, password: pass });
});

password.addEventListener('keydown', (event) => {
    if (event.key === 'Enter') {
        submit.click();
    }
});

// Страница отрисована: клиент закроет лоадер только после этого сигнала
post('ready', {});

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.type === 'bu:auth:open') {
        document.body.classList.remove('done');
        document.body.classList.add('open');
        // Лоадер закрывается в тот же момент: держим чёрный кадр чуть дольше,
        // чтобы стык двух экранов не выглядел вспышкой
        setTimeout(() => document.body.classList.add('reveal'), 250);
    }

    if (message.type === 'bu:auth:hide') {
        document.body.classList.remove('open');
        document.body.classList.remove('reveal');
        document.body.classList.add('done');
    }

    if (message.type === 'bu:auth:error') {
        error.textContent = message.message;
    }
});
