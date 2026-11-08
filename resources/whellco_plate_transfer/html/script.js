const plateTransferMenu = document.getElementById('plate-transfer');
const vehiclesContainer = document.getElementById('vehicles');
const transferList = document.getElementById('transfer-list');
const targetInput = document.getElementById('target-input');
const plateInput = document.getElementById('plate-input');
const transferButton = document.getElementById('transfer-button');
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

function renderTransfers() {
    transferList.innerHTML = '';
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];

        renderVehicles();
        renderTransfers();

        plateTransferMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        plateTransferMenu.classList.remove('visible');
    }
});

transferButton.addEventListener('click', function() {
    if (!selectedVehicleId) {
        return;
    }

    post('transferPlate', {
        vehicleId: selectedVehicleId,
        targetId: targetInput.value,
        plate: plateInput.value
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
