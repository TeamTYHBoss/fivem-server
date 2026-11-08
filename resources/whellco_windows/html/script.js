const windowMenu = document.getElementById('windows');
const vehiclesContainer = document.getElementById('vehicles');
const windowList = document.getElementById('window-list');
const tintSelect = document.getElementById('tint-select');
const colorSelect = document.getElementById('color-select');
const applyButton = document.getElementById('apply-button');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentTints = [];
let currentColors = [];
let selectedVehicleId = null;

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

function renderVehicles() {
    vehiclesContainer.innerHTML = '';

    currentVehicles.forEach(function(vehicle) {
        const row = document.createElement('div');
        row.className = 'vehicle';
        row.textContent = `${vehicle.model} — ${vehicle.plate}`;

        row.addEventListener('click', function() {
            selectedVehicleId = vehicle.id;
        });

        vehiclesContainer.appendChild(row);
    });
}

function renderOptions() {
    tintSelect.innerHTML = '';
    colorSelect.innerHTML = '';

    currentTints.forEach(function(tint) {
        const option = document.createElement('option');
        option.value = tint.id;
        option.textContent = tint.name;
        tintSelect.appendChild(option);
    });

    currentColors.forEach(function(color) {
        const option = document.createElement('option');
        option.value = color.id;
        option.textContent = color.name;
        colorSelect.appendChild(option);
    });
}

function renderWindows() {
    windowList.innerHTML = '';
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentTints = data.tints || [];
        currentColors = data.colors || [];

        renderVehicles();
        renderOptions();
        renderWindows();

        windowMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        windowMenu.classList.remove('visible');
    }
});

applyButton.addEventListener('click', function() {
    if (!selectedVehicleId) {
        return;
    }

    post('applyWindows', {
        vehicleId: selectedVehicleId,
        tintId: tintSelect.value,
        colorId: colorSelect.value
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
