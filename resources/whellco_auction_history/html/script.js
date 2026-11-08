const historyMenu = document.getElementById('auction-history');
const auctionsContainer = document.getElementById('auctions');
const bidsContainer = document.getElementById('bids');
const closeButton = document.getElementById('close-button');

let currentAuctions = [];
let currentBids = [];

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

function renderAuctions() {
    auctionsContainer.innerHTML = '';

    currentAuctions.forEach(function(auction) {
        const row = document.createElement('div');
        row.className = 'auction-item';
        row.textContent = `${auction.plate} — Final bid £${auction.final_bid} — Winner ${auction.winner_id or 'None'}`;

        auctionsContainer.appendChild(row);
    });
}

function renderBids() {
    bidsContainer.innerHTML = '';

    currentBids.forEach(function(bid) {
        const row = document.createElement('div');
        row.className = 'bid-item';
        row.textContent = `Auction ${bid.auction_id} — £${bid.bid_amount} — ${bid.created_at}`;

        bidsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentAuctions = data.auctions || [];
        currentBids = data.bids || [];

        renderAuctions();
        renderBids();

        historyMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        historyMenu.classList.remove('visible');
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
