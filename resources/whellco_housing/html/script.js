const housingMenu = document.getElementById('housing');
const propertiesContainer = document.getElementById('properties');
const furnitureContainer = document.getElementById('furniture');
const closeButton = document.getElementById('close-button');

let currentProperties = [];
let currentFurniture = [];

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

function renderProperties(properties) {
    propertiesContainer.innerHTML = '';

    properties.forEach(function(property) {
        const row = document.createElement('div');
        row.className = 'property';

        const info = document.createElement('div');
        info.className = 'property-info';

        const title = document.createElement('h2');
        title.textContent = property.label;

        const details = document.createElement('p');
        details.textContent = property.owner ? 'Owned' : `£${property.price}`;

        info.appendChild(title);
        info.appendChild(details);

        const actions = document.createElement('div');

        if (!property.owner) {
            const buyButton = document.createElement('button');
            buyButton.textContent = 'Buy';

            buyButton.addEventListener('click', function() {
                post('buyProperty', {
                    propertyId: property.id
                });
            });

            actions.appendChild(buyButton);
        } else {
            const enterButton = document.createElement('button');
            enterButton.textContent = 'Enter';

            enterButton.addEventListener('click', function() {
                post('enterProperty', {
                    propertyId: property.id
                });
            });

            const exitButton = document.createElement('button');
            exitButton.textContent = 'Exit';

            exitButton.addEventListener('click', function() {
                post('exitProperty', {
                    propertyId: property.id
                });
            });

            actions.appendChild(enterButton);
            actions.appendChild(exitButton);
        }

        row.appendChild(info);
        row.appendChild(actions);
        propertiesContainer.appendChild(row);
    });
}

function renderFurniture(furniture) {
    furnitureContainer.innerHTML = '';

    Object.entries(furniture).forEach(function([id, item]) {
        const row = document.createElement('div');
        row.className = 'furniture-item';

        const info = document.createElement('div');
        info.className = 'furniture-info';

        const title = document.createElement('h2');
        title.textContent = item.label;

        const price = document.createElement('p');
        price.textContent = `£${item.price}`;

        info.appendChild(title);
        info.appendChild(price);

        const placeButton = document.createElement('button');
        placeButton.textContent = 'Place';

        placeButton.addEventListener('click', function() {
            post('placeFurniture', {
                propertyId: currentProperties[0] ? currentProperties[0].id : '',
                itemId: id,
                x: 0.0,
                y: 0.0,
                z: 0.0,
                heading: 0.0
            });
        });

        row.appendChild(info);
        row.appendChild(placeButton);
        furnitureContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentProperties = data.properties || [];
        currentFurniture = data.furniture || {};

        renderProperties(currentProperties);
        renderFurniture(currentFurniture);
        housingMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        housingMenu.classList.remove('visible');
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
