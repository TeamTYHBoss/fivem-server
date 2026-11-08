const registrationMenu = document.getElementById('registration');
const vehiclesContainer = document.getElementById('vehicles');
const registrationsContainer = document.getElementById('registrations');
const transfersContainer = document.getElementById('transfers');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentRegistrations = [];
let currentTransfers = [];

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

function renderRegistrations() {
    registrationsContainer.innerHTML = '';

    currentRegistrations.forEach(function(registration) {
        const row = document.createElement('div');
        row.className = 'registration-item';
        row.textContent = `${registration.plate} — ${registration.registered ? 'Registered' : 'Unregistered'}`;

        registrationsContainer.appendChild(row);
    });
}

function renderTransfers() {
    transfersContainer.innerHTML = '';

    currentTransfers.forEach(function(transfer) {
        const row = document.createElement('div');
        row.className = 'transfer';
        row.textContent = `Vehicle ${transfer.vehicle_id} — £${transfer.transfer_fee} — ${transfer.transferred_at}`;

        transfersContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentRegistrations = data.registrations || [];
        currentTransfers = data.transfers || [];

        renderVehicles();
        renderRegistrations();
        renderTransfers();

        registrationMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        registrationMenu.classList.remove('visible');
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
