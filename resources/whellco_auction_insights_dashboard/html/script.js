const dashboardMenu = document.getElementById('auction-dashboard');
const insightList = document.getElementById('insight-list');
const filterSelect = document.getElementById('filter-select');
const filterButton = document.getElementById('filter-button');
const closeButton = document.getElementById('close-button');

let currentInsights = [];
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

function renderInsights() {
    insightList.innerHTML = '';

    currentInsights.forEach(function(insight) {
        const row = document.createElement('div');
        row.className = 'insight-item';

        const label = document.createElement('div');
        label.textContent = `Auction ${insight.auction_id} — ${insight.category} — ${insight.metric}`;

        const value = document.createElement('div');
        value.textContent = insight.value;

        row.appendChild(label);
        row.appendChild(value);
        insightList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentInsights = data.insights || [];
        currentFilters = data.filters || {};

        renderFilters();
        renderInsights();

        dashboardMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        dashboardMenu.classList.remove('visible');
    }
});

filterButton.addEventListener('click', function() {
    post('filterDashboard', {
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
