const motMenu = document.getElementById('mot');
const vehiclesContainer = document.getElementById('vehicles');
const certificatesContainer = document.getElementById('certificates');
const failuresContainer = document.getElementById('failures');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentCertificates = [];
let currentFailures = [];

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

        const info = document.createElement('div');
        info.className = 'vehicle-info';
        info.textContent = `${vehicle.model} — ${vehicle.plate}`;

        const bookButton = document.createElement('button');
        bookButton.textContent = 'Book MOT';

        bookButton.addEventListener('click', function() {
            post('bookMot', {
                vehicleId: vehicle.id
            });
        });

        row.appendChild(info);
        row.appendChild(bookButton);
        vehiclesContainer.appendChild(row);
    });
}

function renderCertificates() {
    certificatesContainer.innerHTML = '';

    currentCertificates.forEach(function(certificate) {
        const row = document.createElement('div');
        row.className = 'certificate';
        row.textContent = `Vehicle ${certificate.vehicle_id} — ${certificate.passed ? 'Passed' : 'Failed'} — Expires ${certificate.expiry_date}`;

        certificatesContainer.appendChild(row);
    });
}

function renderFailures() {
    failuresContainer.innerHTML = '';

    currentFailures.forEach(function(failure) {
        const row = document.createElement('div');
        row.className = 'failure';
        row.textContent = `Vehicle ${failure.vehicle_id} — ${failure.failure_reason}`;

        failuresContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentCertificates = data.certificates || [];
        currentFailures = data.failures || [];

        renderVehicles();
        renderCertificates();
        renderFailures();

        motMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        motMenu.classList.remove('visible');
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
