const favoritesMenu = document.getElementById('auction-favorites');
const favoritesContainer = document.getElementById('favorites');
const closeButton = document.getElementById('close-button');

let currentFavorites = [];

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

function renderFavorites() {
    favoritesContainer.innerHTML = '';

    currentFavorites.forEach(function(item) {
        const row = document.createElement('div');
        row.className = 'favorite-item';

        const info = document.createElement('div');
        info.className = 'favorite-info';
        info.textContent = `Auction ${item.auction_id} — ${item.plate}`;

        const unfavoriteButton = document.createElement('button');
        unfavoriteButton.textContent = 'Unfavorite';

        unfavoriteButton.addEventListener('click', function() {
            post('unfavoriteAuction', {
                auctionId: item.auction_id
            });
        });

        row.appendChild(info);
        row.appendChild(unfavoriteButton);
        favoritesContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentFavorites = data.favorites || [];
        renderFavorites();
        favoritesMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        favoritesMenu.classList.remove('visible');
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
