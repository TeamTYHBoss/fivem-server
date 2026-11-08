const audioMenu = document.getElementById('audio');
const vehiclesContainer = document.getElementById('vehicles');
const audioList = document.getElementById('audio-list');
const systemSelect = document.getElementById('system-select');
const volumeSelect = document.getElementById('volume-select');
const applyButton = document.getElementById('apply-button');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentSystems = [];
let currentVolumes = [];
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
    systemSelect.innerHTML = '';
    volumeSelect.innerHTML = '';

    currentSystems.forEach(function(system) {
        const option = document.createElement('option');
        option.value = system.id;
        option.textContent = system.name;
        systemSelect.appendChild(option);
    });

    currentVolumes.forEach(function(volume) {
        const option = document.createElement('option');
        option.value = volume.id;
        option.textContent = volume.name;
        volumeSelect.appendChild(option);
    });
}

function renderAudio() {
    audioList.innerHTML = '';
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentSystems = data.systems || [];
        currentVolumes = data.volumes || [];

        renderVehicles();
        renderOptions();
        renderAudio();

        audioMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        audioMenu.classList.remove('visible');
    }
});

applyButton.addEventListener('click', function() {
    if (!selectedVehicleId) {
        return;
    }

    post('applyAudio', {
        vehicleId: selectedVehicleId,
        systemId: systemSelect.value,
        volumeId: volumeSelect.value
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
