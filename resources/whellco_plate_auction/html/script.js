const auctionMenu = document.getElementById('plate-auction');
const auctionsContainer = document.getElementById('auctions');
const closeButton = document.getElementById('close-button');

let currentAuctions = [];

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

        const info = document.createElement('div');
        info.className = 'auction-info';
        info.textContent = `${auction.plate} — Current bid £${auction.current_bid || auction.starting_bid} — Ends ${auction.ends_at}`;

        const bidInput = document.createElement('input');
        bidInput.type = 'number';
        bidInput.placeholder = 'Bid amount';

        const bidButton = document.createElement('button');
        bidButton.textContent = 'Bid';

        bidButton.addEventListener('click', function() {
            post('placeBid', {
                auctionId: auction.id,
                bidAmount: bidInput.value
            });
        });

        row.appendChild(info);
        row.appendChild(bidInput);
        row.appendChild(bidButton);
        auctionsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentAuctions = data.auctions || [];
        renderAuctions();
        auctionMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        auctionMenu.classList.remove('visible');
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
