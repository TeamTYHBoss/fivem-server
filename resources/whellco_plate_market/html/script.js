const marketMenu = document.getElementById('plate-market');
const listingsContainer = document.getElementById('listings');
const closeButton = document.getElementById('close-button');

let currentListings = [];

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

function renderListings() {
    listingsContainer.innerHTML = '';

    currentListings.forEach(function(listing) {
        const row = document.createElement('div');
        row.className = 'listing-item';

        const info = document.createElement('div');
        info.className = 'listing-info';
        info.textContent = `${listing.plate} — £${listing.price}`;

        const buyButton = document.createElement('button');
        buyButton.textContent = 'Buy';

        buyButton.addEventListener('click', function() {
            post('buyPlate', {
                listingId: listing.id
            });
        });

        row.appendChild(info);
        row.appendChild(buyButton);
        listingsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentListings = data.listings || [];
        renderListings();
        marketMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        marketMenu.classList.remove('visible');
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
