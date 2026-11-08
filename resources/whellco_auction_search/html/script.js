const searchMenu = document.getElementById('auction-search');
const resultsContainer = document.getElementById('results');
const filterSelect = document.getElementById('filter-select');
const searchInput = document.getElementById('search-input');
const searchButton = document.getElementById('search-button');
const closeButton = document.getElementById('close-button');

let currentFilters = [];
let currentResults = [];

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

function renderResults() {
    resultsContainer.innerHTML = '';

    currentResults.forEach(function(result) {
        const row = document.createElement('div');
        row.className = 'result-item';
        row.textContent = `${result.plate} — Current bid £${result.current_bid || result.starting_bid} — Ends ${result.ends_at}`;

        resultsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentFilters = data.filters || {};
        currentResults = data.results || [];

        renderFilters();
        renderResults();

        searchMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        searchMenu.classList.remove('visible');
    }
});

searchButton.addEventListener('click', function() {
    post('searchAuctions', {
        searchQuery: searchInput.value,
        searchFilter: filterSelect.value
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
