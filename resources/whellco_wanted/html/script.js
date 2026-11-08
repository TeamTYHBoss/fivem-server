const wantedMenu = document.getElementById('wanted');
const wantedList = document.getElementById('wanted-list');
const closeButton = document.getElementById('close-button');

let currentWanted = [];

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

function renderWanted() {
    wantedList.innerHTML = '';

    currentWanted.forEach(function(item) {
        const row = document.createElement('div');
        row.className = 'wanted-item';
        row.textContent = `Vehicle ${item.vehicle_id} — Level ${item.wanted_level} — ${item.reason}`;

        wantedList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentWanted = data.wanted || [];
        renderWanted();
        wantedMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        wantedMenu.classList.remove('visible');
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
