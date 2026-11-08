const statsMenu = document.getElementById('auction-stats');
const statsContainer = document.getElementById('stats');
const closeButton = document.getElementById('close-button');

let currentStats = [];

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

function renderStats() {
    statsContainer.innerHTML = '';

    currentStats.forEach(function(stat) {
        const row = document.createElement('div');
        row.className = 'stat-item';
        row.textContent = `${stat.plate} — Bids ${stat.total_bids} — Highest £${stat.highest_bid} — Final £${stat.final_bid}`;

        statsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentStats = data.stats || [];
        renderStats();
        statsMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        statsMenu.classList.remove('visible');
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
