const auditMenu = document.getElementById('auction-audit');
const logList = document.getElementById('log-list');
const auctionInput = document.getElementById('auction-input');
const actionSelect = document.getElementById('action-select');
const detailsInput = document.getElementById('details-input');
const recordButton = document.getElementById('record-button');
const closeButton = document.getElementById('close-button');

let currentActions = {};
let currentLogs = [];

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

function renderActions() {
    actionSelect.innerHTML = '';

    Object.keys(currentActions).forEach(function(key) {
        const option = document.createElement('option');
        option.value = key;
        option.textContent = currentActions[key];
        actionSelect.appendChild(option);
    });
}

function renderLogs() {
    logList.innerHTML = '';

    currentLogs.forEach(function(log) {
        const row = document.createElement('div');
        row.className = 'log-item';
        row.textContent = `Auction ${log.auction_id} — ${log.action} — ${log.details} — ${log.created_at}`;

        logList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentActions = data.actions || {};
        currentLogs = data.logs || [];

        renderActions();
        renderLogs();

        auditMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        auditMenu.classList.remove('visible');
    }
});

recordButton.addEventListener('click', function() {
    post('recordAudit', {
        auctionId: auctionInput.value,
        action: actionSelect.value,
        details: detailsInput.value
    });
});

closeButton.addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
