const tuningMenu = document.getElementById('tuning');
const vehiclesContainer = document.getElementById('vehicles');
const upgradesContainer = document.getElementById('upgrades');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentUpgrades = [];

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

        vehiclesContainer.appendChild(row);
    });
}

function renderUpgrades() {
    upgradesContainer.innerHTML = '';

    currentUpgrades.forEach(function(upgrade) {
        const row = document.createElement('div');
        row.className = 'upgrade';
        row.textContent = `Vehicle ${upgrade.vehicle_id} — ${upgrade.part} — Level ${upgrade.level}`;

        upgradesContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentUpgrades = data.upgrades || [];

        renderVehicles();
        renderUpgrades();

        tuningMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        tuningMenu.classList.remove('visible');
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
