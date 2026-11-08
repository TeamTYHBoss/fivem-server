const plateTextMenu = document.getElementById('plate-text');
const vehiclesContainer = document.getElementById('vehicles');
const plateList = document.getElementById('plate-list');
const plateInput = document.getElementById('plate-input');
const applyButton = document.getElementById('apply-button');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
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

function renderPlates() {
    plateList.innerHTML = '';
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];

        renderVehicles();
        renderPlates();

        plateTextMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        plateTextMenu.classList.remove('visible');
    }
});

applyButton.addEventListener('click', function() {
    if (!selectedVehicleId) {
        return;
    }

    post('applyPlateText', {
        vehicleId: selectedVehicleId,
        plateText: plateInput.value
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
