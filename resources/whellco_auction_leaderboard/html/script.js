const leaderboardMenu = document.getElementById('leaderboard');
const biddersContainer = document.getElementById('bidders');
const sellersContainer = document.getElementById('sellers');
const closeButton = document.getElementById('close-button');

let currentBidders = [];
let currentSellers = [];

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

function renderBidders() {
    biddersContainer.innerHTML = '';

    currentBidders.forEach(function(player) {
        const row = document.createElement('div');
        row.className = 'leaderboard-item';
        row.textContent = `${player.player_id} — Bids ${player.total_bids} — Spent £${player.total_spent} — Won ${player.auctions_won}`;

        biddersContainer.appendChild(row);
    });
}

function renderSellers() {
    sellersContainer.innerHTML = '';

    currentSellers.forEach(function(player) {
        const row = document.createElement('div');
        row.className = 'leaderboard-item';
        row.textContent = `${player.player_id} — Sold ${player.auctions_sold} — Value £${player.total_spent}`;

        sellersContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentBidders = data.bidders || [];
        currentSellers = data.sellers || [];

        renderBidders();
        renderSellers();

        leaderboardMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        leaderboardMenu.classList.remove('visible');
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
