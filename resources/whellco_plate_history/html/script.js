const plateHistoryMenu = document.getElementById('plate-history');
const historyContainer = document.getElementById('history');
const closeButton = document.getElementById('close-button');

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

function renderHistory() {
    historyContainer.innerHTML = '';

    currentHistory.forEach(function(item) {
        const row = document.createElement('div');
        row.className = 'history-item';
        row.textContent = `Vehicle ${item.vehicle_id} — ${item.old_plate} to ${item.new_plate} — ${item.changed_at}`;

        historyContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentHistory = data.history || [];
        renderHistory();
        plateHistoryMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        plateHistoryMenu.classList.remove('visible');
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
