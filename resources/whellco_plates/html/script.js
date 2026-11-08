const plateMenu = document.getElementById('plates');
const vehiclesContainer = document.getElementById('vehicles');
const plateList = document.getElementById('plate-list');
const typeSelect = document.getElementById('type-select');
const colorSelect = document.getElementById('color-select');
const applyButton = document.getElementById('apply-button');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentTypes = [];
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
    typeSelect.innerHTML = '';
    colorSelect.innerHTML = '';

    currentTypes.forEach(function(type) {
        const option = document.createElement('option');
        option.value = type.id;
        option.textContent = type.name;
        typeSelect.appendChild(option);
    });

    currentColors.forEach(function(color) {
        const option = document.createElement('option');
        option.value = color.id;
        option.textContent = color.name;
        colorSelect.appendChild(option);
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
        currentTypes = data.types || [];
        currentColors = data.colors || [];

        renderVehicles();
        renderOptions();
        renderPlates();

        plateMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        plateMenu.classList.remove('visible');
    }
});

applyButton.addEventListener('click', function() {
    if (!selectedVehicleId) {
        return;
    }

    post('applyPlate', {
        vehicleId: selectedVehicleId,
        typeId: typeSelect.value,
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
