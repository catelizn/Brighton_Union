const dialog = document.getElementById('dialog');
let currentKey = null;

window.addEventListener('message', (event) => {
    const message = event.data;
    if (!message) return;

    if (message.action === 'open') {
        currentKey = message.job.key;
        document.getElementById('job-title').textContent = 'Работа: ' + message.job.label;
        document.getElementById('job-pay').textContent = '$' + message.job.basePay;
        document.getElementById('job-level').textContent = message.job.level + '/10';
        document.getElementById('job-current').textContent = '$' + message.job.currentPay;
        document.getElementById('job-max').textContent = '$' + message.job.maxPay;
        dialog.classList.add('visible');
    }

    if (message.action === 'close') {
        dialog.classList.remove('visible');
        currentKey = null;
    }
});

document.getElementById('btn-hire').addEventListener('click', () => {
    if (!currentKey) return;
    fetch(`https://bu-jobs/hire`, {
        method: 'POST',
        body: JSON.stringify({ job: currentKey })
    });
});

document.getElementById('btn-cancel').addEventListener('click', () => {
    fetch(`https://bu-jobs/close`, {
        method: 'POST',
        body: '{}'
    });
});
