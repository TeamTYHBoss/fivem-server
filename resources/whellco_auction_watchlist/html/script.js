const watchlistMenu = document.getElementById('auction-watchlist');
const watchlistContainer = document.getElementById('watchlist');
const closeButton = document.getElementById('close-button');

let currentWatchlist = [];

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

function renderWatchlist() {
    watchlistContainer.innerHTML = '';

    currentWatchlist.forEach(function(item) {
        const row = document.createElement('div');
        row.className = 'watch-item';

        const info = document.createElement('div');
        info.className = 'watch-info';
        info.textContent = `Auction ${item.auction_id} — ${item.plate}`;

        const unwatchButton = document.createElement('button');
        unwatchButton.textContent = 'Unwatch';

        unwatchButton.addEventListener('click', function() {
            post('unwatchAuction', {
                auctionId: item.auction_id
            });
        });

        row.appendChild(info);
        row.appendChild(unwatchButton);
        watchlistContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentWatchlist = data.watchlist || [];
        renderWatchlist();
        watchlistMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        watchlistMenu.classList.remove('visible');
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
