const neonMenu = document.getElementById('neon');
const vehiclesContainer = document.getElementById('vehicles');
const neonList = document.getElementById('neon-list');
const colorSelect = document.getElementById('color-select');
const styleSelect = document.getElementById('style-select');
const applyButton = document.getElementById('apply-button');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentColors = [];
let currentStyles = [];
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
    colorSelect.innerHTML = '';
    styleSelect.innerHTML = '';

    currentColors.forEach(function(color) {
        const option = document.createElement('option');
        option.value = color.id;
        option.textContent = color.name;
        colorSelect.appendChild(option);
    });

    currentStyles.forEach(function(style) {
        const option = document.createElement('option');
        option.value = style.id;
        option.textContent = style.name;
        styleSelect.appendChild(option);
    });
}

function renderNeons() {
    neonList.innerHTML = '';
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentColors = data.colors || [];
        currentStyles = data.styles || [];

        renderVehicles();
        renderOptions();
        renderNeons();

        neonMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        neonMenu.classList.remove('visible');
    }
});

applyButton.addEventListener('click', function() {
    if (!selectedVehicleId) {
        return;
    }

    post('applyNeon', {
        vehicleId: selectedVehicleId,
        colorId: colorSelect.value,
        styleId: styleSelect.value
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
