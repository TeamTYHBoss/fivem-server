const insightsMenu = document.getElementById('auction-insights');
const insightList = document.getElementById('insight-list');
const auctionInput = document.getElementById('auction-input');
const categorySelect = document.getElementById('category-select');
const insightInput = document.getElementById('insight-input');
const scoreInput = document.getElementById('score-input');
const addButton = document.getElementById('add-button');
const closeButton = document.getElementById('close-button');

let currentInsights = [];
let currentCategories = {};

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

    Object.keys(currentCategories).forEach(function(key) {
        const option = document.createElement('option');
        option.value = key;
        option.textContent = currentCategories[key];
        categorySelect.appendChild(option);
    });
}

function renderInsights() {
    insightList.innerHTML = '';

    currentInsights.forEach(function(insight) {
        const row = document.createElement('div');
        row.className = 'insight-item';
        row.textContent = `Auction ${insight.auction_id} — ${insight.category} — ${insight.insight} — ${insight.score}`;

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
        currentCategories = data.categories || {};

        renderCategories();
        renderInsights();

        insightsMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        insightsMenu.classList.remove('visible');
    }
});

addButton.addEventListener('click', function() {
    post('addInsight', {
        auctionId: auctionInput.value,
        category: categorySelect.value,
        insight: insightInput.value,
        score: scoreInput.value
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
