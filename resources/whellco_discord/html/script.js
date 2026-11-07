const discordMenu = document.getElementById('discord');
const rolesContainer = document.getElementById('roles');
const logsContainer = document.getElementById('logs');
const closeButton = document.getElementById('close-button');

let currentRoles = [];
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

function renderRoles() {
    rolesContainer.innerHTML = '';

    currentRoles.forEach(function(role) {
        const row = document.createElement('div');
        row.className = 'role';

        const info = document.createElement('div');
        info.className = 'role-info';
        info.textContent = role.label;

        const linkButton = document.createElement('button');
        linkButton.textContent = 'Link';

        linkButton.addEventListener('click', function() {
            post('linkDiscord', {
                discordId: role.role_id
            });
        });

        const unlinkButton = document.createElement('button');
        unlinkButton.textContent = 'Unlink';

        unlinkButton.addEventListener('click', function() {
            post('unlinkDiscord', {
                discordId: role.role_id
            });
        });

        row.appendChild(info);
        row.appendChild(linkButton);
        row.appendChild(unlinkButton);
        rolesContainer.appendChild(row);
    });
}

function renderLogs() {
    logsContainer.innerHTML = '';

    currentLogs.forEach(function(log) {
        const row = document.createElement('div');
        row.className = 'log';
        row.textContent = `${log.log_type} — ${log.message}`;

        logsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentRoles = data.roles || [];
        currentLogs = data.logs || [];

        renderRoles();
        renderLogs();

        discordMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        discordMenu.classList.remove('visible');
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
