const vehiclesMenu = document.getElementById('vehicles');
const title = document.getElementById('title');
const subtitle = document.getElementById('subtitle');
const itemsContainer = document.getElementById('items');
const closeButton = document.getElementById('close-button');

let currentMode = 'garage';

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

function renderGarage(vehicles) {
    title.textContent = 'Garage';
    subtitle.textContent = 'Manage your vehicles.';
    itemsContainer.innerHTML = '';

    vehicles.forEach(function(vehicle) {
        const row = document.createElement('div');
        row.className = 'item';

        const info = document.createElement('div');
        info.className = 'item-info';

        const name = document.createElement('h2');
        name.textContent = vehicle.model;

        const plate = document.createElement('p');
        plate.textContent = vehicle.plate;

        info.appendChild(name);
        info.appendChild(plate);

        const spawnButton = document.createElement('button');
        spawnButton.textContent = 'Spawn';

        spawnButton.addEventListener('click', function() {
            post('spawnVehicle', {
                vehicleId: vehicle.id
            });
        });

        row.appendChild(info);
        row.appendChild(spawnButton);
        itemsContainer.appendChild(row);
    });
}

function renderDealership(vehicles) {
    title.textContent = 'Dealership';
    subtitle.textContent = 'Buy a new vehicle.';
    itemsContainer.innerHTML = '';

    vehicles.forEach(function(vehicle) {
        const row = document.createElement('div');
        row.className = 'item';

        const info = document.createElement('div');
        info.className = 'item-info';

        const name = document.createElement('h2');
        name.textContent = vehicle.label;

        const price = document.createElement('p');
        price.textContent = `£${vehicle.price}`;

        info.appendChild(name);
        info.appendChild(price);

        const buyButton = document.createElement('button');
        buyButton.textContent = 'Buy';

        buyButton.addEventListener('click', function() {
            post('purchaseVehicle', {
                model: vehicle.model
            });
        });

        row.appendChild(info);
        row.appendChild(buyButton);
        itemsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'openGarage') {
        currentMode = 'garage';
        renderGarage(data.vehicles || []);
        vehiclesMenu.classList.add('visible');
    }

    if (data.action === 'openDealership') {
        currentMode = 'dealership';
        renderDealership(data.vehicles || []);
        vehiclesMenu.classList.add('visible');
    }

    if (data.action === 'closeGarage' || data.action === 'closeDealership') {
        vehiclesMenu.classList.remove('visible');
    }
});

closeButton.addEventListener('click', function() {
    if (currentMode === 'garage') {
        post('closeGarage');
    } else {
        post('closeDealership');
    }
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        if (currentMode === 'garage') {
            post('closeGarage');
        } else {
            post('closeDealership');
        }
    }
});
