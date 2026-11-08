const archiveMenu = document.getElementById('auction-archive');
const archiveList = document.getElementById('archive-list');
const filterSelect = document.getElementById('filter-select');
const filterButton = document.getElementById('filter-button');
const closeButton = document.getElementById('close-button');

let currentAuctions = [];
let currentFilters = {};

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

function renderFilters() {
    filterSelect.innerHTML = '';

    Object.keys(currentFilters).forEach(function(key) {
        const option = document.createElement('option');
        option.value = key;
        option.textContent = currentFilters[key];
        filterSelect.appendChild(option);
    });
}

function renderArchive() {
    archiveList.innerHTML = '';

    currentAuctions.forEach(function(auction) {
        const row = document.createElement('div');
        row.className = 'archive-item';
        row.textContent = `Auction ${auction.auction_id} — ${auction.plate} — ${auction.final_price} — ${auction.status}`;

        archiveList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentAuctions = data.auctions || [];
        currentFilters = data.filters || {};

        renderFilters();
        renderArchive();

        archiveMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        archiveMenu.classList.remove('visible');
    }
});

filterButton.addEventListener('click', function() {
    post('filterArchive', {
        filter: filterSelect.value
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
