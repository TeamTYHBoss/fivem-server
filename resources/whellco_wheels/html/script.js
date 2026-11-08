const wheelMenu = document.getElementById('wheels');
const vehiclesContainer = document.getElementById('vehicles');
const wheelList = document.getElementById('wheel-list');
const wheelTypeSelect = document.getElementById('wheel-type-select');
const wheelColorSelect = document.getElementById('wheel-color-select');
const applyButton = document.getElementById('apply-button');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentWheelTypes = [];
let currentWheelColors = [];
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
    wheelTypeSelect.innerHTML = '';
    wheelColorSelect.innerHTML = '';

    currentWheelTypes.forEach(function(wheelType) {
        const option = document.createElement('option');
        option.value = wheelType.id;
        option.textContent = wheelType.name;
        wheelTypeSelect.appendChild(option);
    });

    currentWheelColors.forEach(function(wheelColor) {
        const option = document.createElement('option');
        option.value = wheelColor.id;
        option.textContent = wheelColor.name;
        wheelColorSelect.appendChild(option);
    });
}

function renderWheels() {
    wheelList.innerHTML = '';
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentWheelTypes = data.wheelTypes || [];
        currentWheelColors = data.wheelColors || [];

        renderVehicles();
        renderOptions();
        renderWheels();

        wheelMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        wheelMenu.classList.remove('visible');
    }
});

applyButton.addEventListener('click', function() {
    if (!selectedVehicleId) {
        return;
    }

    post('applyWheels', {
        vehicleId: selectedVehicleId,
        wheelType: wheelTypeSelect.value,
        wheelColor: wheelColorSelect.value
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
