const categoryMenu = document.getElementById('auction-categories');
const categorySelect = document.getElementById('category-select');
const auctionList = document.getElementById('auction-list');
const setButton = document.getElementById('set-button');
const closeButton = document.getElementById('close-button');

let currentCategories = [];
let currentAuctions = [];
let selectedAuctionId = null;

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

function renderCategories() {
    categorySelect.innerHTML = '';

    currentCategories.forEach(function(category) {
        const option = document.createElement('option');
        option.value = category.id;
        option.textContent = category.name;
        categorySelect.appendChild(option);
    });
}

function renderAuctions() {
    auctionList.innerHTML = '';

    currentAuctions.forEach(function(auction) {
        const row = document.createElement('div');
        row.className = 'auction-item';
        row.textContent = `Auction ${auction.auction_id} — Category ${auction.category_id}`;

        row.addEventListener('click', function() {
            selectedAuctionId = auction.auction_id;
        });

        auctionList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentCategories = data.categories || [];
        currentAuctions = data.auctions || [];

        renderCategories();
        renderAuctions();

        categoryMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        categoryMenu.classList.remove('visible');
    }
});

setButton.addEventListener('click', function() {
    if (!selectedAuctionId) {
        return;
    }

    post('setCategory', {
        auctionId: selectedAuctionId,
        categoryId: categorySelect.value
    });
});

closeButton.addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
