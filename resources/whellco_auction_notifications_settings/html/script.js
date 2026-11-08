const settingsMenu = document.getElementById('notification-settings');
const channelSelect = document.getElementById('channel-select');
const preferenceList = document.getElementById('preference-list');
const saveButton = document.getElementById('save-button');
const closeButton = document.getElementById('close-button');

let currentSettings = {};
let currentChannels = {};
let currentPreferences = {};

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

function renderSettings() {
    channelSelect.innerHTML = '';

    Object.keys(currentChannels).forEach(function(key) {
        const option = document.createElement('option');
        option.value = key;
        option.textContent = currentChannels[key];
        channelSelect.appendChild(option);
    });

    channelSelect.value = currentSettings.alert_channel || 'in_game';

    preferenceList.innerHTML = '';

    Object.keys(currentPreferences).forEach(function(key) {
        const row = document.createElement('div');
        row.className = 'preference-item';

        const label = document.createElement('div');
        label.textContent = currentPreferences[key];

        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.id = `preference-${key}`;
        checkbox.checked = currentSettings[key] == 1;

        row.appendChild(label);
        row.appendChild(checkbox);
        preferenceList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentSettings = data.settings || {};
        currentChannels = data.channels || {};
        currentPreferences = data.preferences || {};

        renderSettings();
        settingsMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        settingsMenu.classList.remove('visible');
    }
});

saveButton.addEventListener('click', function() {
    const settings = {
        alert_channel: channelSelect.value
    };

    Object.keys(currentPreferences).forEach(function(key) {
        settings[key] = document.getElementById(`preference-${key}`).checked;
    });

    post('saveSettings', settings);
});

closeButton.addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
