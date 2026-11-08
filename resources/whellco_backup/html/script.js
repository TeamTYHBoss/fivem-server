const backupMenu = document.getElementById('backup');
const typesContainer = document.getElementById('types');
const logsContainer = document.getElementById('logs');
const closeButton = document.getElementById('close-button');

let currentTypes = [];
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

function renderTypes() {
    typesContainer.innerHTML = '';

    currentTypes.forEach(function(backupType) {
        const row = document.createElement('div');
        row.className = 'type';

        const info = document.createElement('div');
        info.className = 'type-info';
        info.textContent = backupType.label;

        const createButton = document.createElement('button');
        createButton.textContent = 'Create';

        createButton.addEventListener('click', function() {
            post('createBackup', {
                backupType: backupType.id
            });
        });

        row.appendChild(info);
        row.appendChild(createButton);
        typesContainer.appendChild(row);
    });
}

function renderLogs() {
    logsContainer.innerHTML = '';

    currentLogs.forEach(function(log) {
        const row = document.createElement('div');
        row.className = 'log';
        row.textContent = `${log.backup_type} — ${log.file_name} — ${log.status} — ${log.message}`;

        logsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentTypes = data.types || [];
        currentLogs = data.logs || [];

        renderTypes();
        renderLogs();

        backupMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        backupMenu.classList.remove('visible');
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
