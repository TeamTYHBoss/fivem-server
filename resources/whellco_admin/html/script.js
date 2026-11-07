const adminMenu = document.getElementById('admin');
const playersContainer = document.getElementById('players');
const bansContainer = document.getElementById('bans');
const actionsContainer = document.getElementById('actions');
const closeButton = document.getElementById('close-button');

let currentPlayers = [];
let currentBans = [];
let currentActions = [];

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

function renderPlayers() {
    playersContainer.innerHTML = '';

    currentPlayers.forEach(function(player) {
        const row = document.createElement('div');
        row.className = 'player';

        const info = document.createElement('div');
        info.className = 'player-info';

        const title = document.createElement('h2');
        title.textContent = player.name;

        const details = document.createElement('p');
        details.textContent = `ID ${player.id} | ${player.identifier}`;

        info.appendChild(title);
        info.appendChild(details);

        const actions = document.createElement('div');

        const kickButton = document.createElement('button');
        kickButton.textContent = 'Kick';

        kickButton.addEventListener('click', function() {
            post('kickPlayer', {
                targetId: player.id,
                reason: 'Kicked by admin'
            });
        });

        const banButton = document.createElement('button');
        banButton.textContent = 'Ban';

        banButton.addEventListener('click', function() {
            post('banPlayer', {
                targetId: player.id,
                reason: 'Banned by admin'
            });
        });

        actions.appendChild(kickButton);
        actions.appendChild(banButton);

        row.appendChild(info);
        row.appendChild(actions);
        playersContainer.appendChild(row);
    });
}

function renderBans() {
    bansContainer.innerHTML = '';

    currentBans.forEach(function(ban) {
        const row = document.createElement('div');
        row.className = 'ban';

        const info = document.createElement('div');
        info.className = 'ban-info';
        info.textContent = `${ban.identifier} — ${ban.reason}`;

        const unbanButton = document.createElement('button');
        unbanButton.textContent = 'Unban';

        unbanButton.addEventListener('click', function() {
            post('unbanPlayer', {
                banId: ban.id
            });
        });

        row.appendChild(info);
        row.appendChild(unbanButton);
        bansContainer.appendChild(row);
    });
}

function renderActions() {
    actionsContainer.innerHTML = '';

    currentActions.forEach(function(action) {
        const row = document.createElement('div');
        row.className = 'action';
        row.textContent = `${action.action_type} — ${action.reason}`;

        actionsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentPlayers = data.players || [];
        currentBans = data.bans || [];
        currentActions = data.actions || [];

        renderPlayers();
        renderBans();
        renderActions();

        adminMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        adminMenu.classList.remove('visible');
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
