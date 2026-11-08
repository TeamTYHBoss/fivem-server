const exportMenu = document.getElementById('auction-exports');
const exportList = document.getElementById('export-list');
const filterSelect = document.getElementById('filter-select');
const filterButton = document.getElementById('filter-button');
const closeButton = document.getElementById('close-button');

let currentExports = [];
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

function renderExports() {
    exportList.innerHTML = '';

    currentExports.forEach(function(exportRecord) {
        const row = document.createElement('div');
        row.className = 'export-item';
        row.textContent = `Auction ${exportRecord.auction_id} — ${exportRecord.plate} — ${exportRecord.final_price} — ${exportRecord.status}`;

        exportList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentExports = data.exports || [];
        currentFilters = data.filters || {};

        renderFilters();
        renderExports();

        exportMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        exportMenu.classList.remove('visible');
    }
});

filterButton.addEventListener('click', function() {
    post('filterExports', {
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
