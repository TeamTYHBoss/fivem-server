const paintMenu = document.getElementById('paint');
const vehiclesContainer = document.getElementById('vehicles');
const paintsContainer = document.getElementById('paints');
const colorSelect = document.getElementById('color-select');
const finishSelect = document.getElementById('finish-select');
const applyButton = document.getElementById('apply-button');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentColors = [];
let currentFinishes = [];
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
    finishSelect.innerHTML = '';

    currentColors.forEach(function(color) {
        const option = document.createElement('option');
        option.value = color.id;
        option.textContent = color.name;
        colorSelect.appendChild(option);
    });

    currentFinishes.forEach(function(finish) {
        const option = document.createElement('option');
        option.value = finish.id;
        option.textContent = finish.name;
        finishSelect.appendChild(option);
    });
}

function renderPaints() {
    paintsContainer.innerHTML = '';
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentColors = data.colors || [];
        currentFinishes = data.finishes || [];

        renderVehicles();
        renderOptions();
        renderPaints();

        paintMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        paintMenu.classList.remove('visible');
    }
});

applyButton.addEventListener('click', function() {
    if (!selectedVehicleId) {
        return;
    }

    post('applyPaint', {
        vehicleId: selectedVehicleId,
        colorId: colorSelect.value,
        finishId: finishSelect.value
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
