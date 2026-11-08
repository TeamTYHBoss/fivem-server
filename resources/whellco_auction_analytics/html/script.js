const analyticsMenu = document.getElementById('auction-analytics');
const analyticsList = document.getElementById('analytics-list');
const closeButton = document.getElementById('close-button');

let currentAnalytics = [];

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

function renderAnalytics() {
    analyticsList.innerHTML = '';

    currentAnalytics.forEach(function(item) {
        const row = document.createElement('div');
        row.className = 'analytics-item';

        const label = document.createElement('div');
        label.textContent = `Auction ${item.auction_id} — ${item.metric}`;

        const value = document.createElement('div');
        value.textContent = item.value;

        row.appendChild(label);
        row.appendChild(value);
        analyticsList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentAnalytics = data.analytics || [];
        renderAnalytics();
        analyticsMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        analyticsMenu.classList.remove('visible');
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
