const deploymentMenu = document.getElementById('deployment');
const checksContainer = document.getElementById('checks');
const historyContainer = document.getElementById('history');
const closeButton = document.getElementById('close-button');

let currentChecks = [];
let currentHistory = [];

function post(callbackName, data) {
    return fetch(`https://${GetParentResourceName()}/${callbackName}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data || {})
    }).then(function(response) {
        return response.json();
    });
}

function renderChecks() {
    checksContainer.innerHTML = '';

    currentChecks.forEach(function(check) {
        const row = document.createElement('div');
        row.className = 'check';
        row.textContent = `${check.label} — ${check.status}`;

        checksContainer.appendChild(row);
    });
}

function renderHistory() {
    historyContainer.innerHTML = '';

    currentHistory.forEach(function(entry) {
        const row = document.createElement('div');
        row.className = 'history-item';
        row.textContent = `${entry.check_name} — ${entry.status} — ${entry.message}`;

        historyContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentChecks = data.checks || [];
        currentHistory = data.history || [];

        renderChecks();
        renderHistory();

        deploymentMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        deploymentMenu.classList.remove('visible');
    }
});

closeButton.addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
