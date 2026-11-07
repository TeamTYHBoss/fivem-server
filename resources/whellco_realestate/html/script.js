const realEstateMenu = document.getElementById('realestate');
const propertiesContainer = document.getElementById('properties');
const purchasesContainer = document.getElementById('purchases');
const rentalsContainer = document.getElementById('rentals');
const closeButton = document.getElementById('close-button');

let currentProperties = [];
let currentPurchases = [];
let currentRentals = [];

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

function renderProperties() {
    propertiesContainer.innerHTML = '';

    currentProperties.forEach(function(property) {
        const row = document.createElement('div');
        row.className = 'property';

        const info = document.createElement('div');
        info.className = 'property-info';

        const title = document.createElement('h2');
        title.textContent = property.label;

        const details = document.createElement('p');
        details.textContent = `£${property.price} | £${property.rent} rent | ${property.owner_id ? 'Owned' : 'Available'}`;

        info.appendChild(title);
        info.appendChild(details);

        const actions = document.createElement('div');

        const buyButton = document.createElement('button');
        buyButton.textContent = 'Buy';

        buyButton.addEventListener('click', function() {
            post('buyProperty', {
                propertyId: property.property_id
            });
        });

        const rentButton = document.createElement('button');
        rentButton.textContent = 'Rent';

        rentButton.addEventListener('click', function() {
            post('rentProperty', {
                propertyId: property.property_id
            });
        });

        const sellButton = document.createElement('button');
        sellButton.textContent = 'Sell';

        sellButton.addEventListener('click', function() {
            post('sellProperty', {
                propertyId: property.property_id
            });
        });

        actions.appendChild(buyButton);
        actions.appendChild(rentButton);
        actions.appendChild(sellButton);

        row.appendChild(info);
        row.appendChild(actions);
        propertiesContainer.appendChild(row);
    });
}

function renderPurchases() {
    purchasesContainer.innerHTML = '';

    currentPurchases.forEach(function(purchase) {
        const row = document.createElement('div');
        row.className = 'purchase';
        row.textContent = `${purchase.property_id} — £${purchase.price}`;

        purchasesContainer.appendChild(row);
    });
}

function renderRentals() {
    rentalsContainer.innerHTML = '';

    currentRentals.forEach(function(rental) {
        const row = document.createElement('div');
        row.className = 'rental';
        row.textContent = `${rental.property_id} — £${rental.rent} — ${rental.ended_at ? 'Ended' : 'Active'}`;

        rentalsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentProperties = data.properties || [];
        currentPurchases = data.purchases || [];
        currentRentals = data.rentals || [];

        renderProperties();
        renderPurchases();
        renderRentals();

        realEstateMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        realEstateMenu.classList.remove('visible');
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
