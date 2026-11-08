const dealershipMenu = document.getElementById('dealership');
const vehiclesContainer = document.getElementById('vehicles');
const customizationContainer = document.getElementById('customization');
const closeButton = document.getElementById('close-button');

let currentVehicles = [];
let currentCustomization = [];

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

        const title = document.createElement('h2');
        title.textContent = vehicle.label;

        const details = document.createElement('p');
        details.textContent = `£${vehicle.price} | ${vehicle.category}`;

        info.appendChild(title);
        info.appendChild(details);

        const buyButton = document.createElement('button');
        buyButton.textContent = 'Buy';

        buyButton.addEventListener('click', function() {
            post('buyVehicle', {
                vehicleId: vehicle.id
            });
        });

        row.appendChild(info);
        row.appendChild(buyButton);
        vehiclesContainer.appendChild(row);
    });
}

function renderCustomization() {
    customizationContainer.innerHTML = '';

    currentCustomization.forEach(function(option) {
        const row = document.createElement('div');
        row.className = 'customization-option';

        const info = document.createElement('div');
        info.className = 'customization-info';
        info.textContent = `${option.label} — £${option.price}`;

        const applyButton = document.createElement('button');
        applyButton.textContent = 'Apply';

        applyButton.addEventListener('click', function() {
            post('customizeVehicle', {
                vehicleId: 0,
                customizationType: option.id,
                value: 1
            });
        });

        row.appendChild(info);
        row.appendChild(applyButton);
        customizationContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'openDealership') {
        currentVehicles = data.vehicles || [];
        currentCustomization = [];

        renderVehicles();
        renderCustomization();

        dealershipMenu.classList.add('visible');
    }

    if (data.action === 'openGarage') {
        currentVehicles = data.vehicles || [];
        currentCustomization = data.customization || [];

        renderVehicles();
        renderCustomization();

        dealershipMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        dealershipMenu.classList.remove('visible');
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
