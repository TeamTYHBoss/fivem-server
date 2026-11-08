const chaseMenu = document.getElementById('chase');
const chasesContainer = document.getElementById('chases');
const closeButton = document.getElementById('close-button');

let currentChases = [];

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

function renderChases() {
    chasesContainer.innerHTML = '';

    currentChases.forEach(function(chase) {
        const row = document.createElement('div');
        row.className = 'chase-item';

        const info = document.createElement('div');
        info.className = 'chase-info';
        info.textContent = `Vehicle ${chase.vehicle_id} — ${chase.reason} — Started ${chase.started_at}`;

        const endButton = document.createElement('button');
        endButton.textContent = 'End Chase';

        endButton.addEventListener('click', function() {
            post('endChase', {
                chaseId: chase.id
            });
        });

        row.appendChild(info);
        row.appendChild(endButton);
        chasesContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentChases = data.chases || [];
        renderChases();
        chaseMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        chaseMenu.classList.remove('visible');
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
