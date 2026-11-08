const taxMenu = document.getElementById('vehicletax');
const vehiclesContainer = document.getElementById('vehicles');
const taxRecordsContainer = document.getElementById('tax-records');
const penaltiesContainer = document.getElementById('penalties');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentTaxRecords = [];
let currentPenalties = [];

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

        const payButton = document.createElement('button');
        payButton.textContent = 'Pay Tax';

        payButton.addEventListener('click', function() {
            post('payTax', {
                vehicleId: vehicle.id
            });
        });

        row.appendChild(info);
        row.appendChild(payButton);
        vehiclesContainer.appendChild(row);
    });
}

function renderTaxRecords() {
    taxRecordsContainer.innerHTML = '';

    currentTaxRecords.forEach(function(record) {
        const row = document.createElement('div');
        row.className = 'tax-record';
        row.textContent = `Vehicle ${record.vehicle_id} — £${record.tax_amount} — Paid until ${record.paid_until}`;

        taxRecordsContainer.appendChild(row);
    });
}

function renderPenalties() {
    penaltiesContainer.innerHTML = '';

    currentPenalties.forEach(function(penalty) {
        const row = document.createElement('div');
        row.className = 'penalty';

        const info = document.createElement('div');
        info.className = 'penalty-info';
        info.textContent = `${penalty.reason} — £${penalty.penalty_amount}`;

        const payButton = document.createElement('button');
        payButton.textContent = 'Pay';

        payButton.addEventListener('click', function() {
            post('payPenalty', {
                penaltyId: penalty.id
            });
        });

        row.appendChild(info);
        row.appendChild(payButton);
        penaltiesContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVehicles = data.vehicles || [];
        currentTaxRecords = data.taxRecords || [];
        currentPenalties = data.penalties || [];

        renderVehicles();
        renderTaxRecords();
        renderPenalties();

        taxMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        taxMenu.classList.remove('visible');
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
