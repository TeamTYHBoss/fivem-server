const recommendationMenu = document.getElementById('auction-recommendations');
const recommendationList = document.getElementById('recommendation-list');
const refreshButton = document.getElementById('refresh-button');
const closeButton = document.getElementById('close-button');

let currentRecommendations = [];

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

function renderRecommendations() {
    recommendationList.innerHTML = '';

    currentRecommendations.forEach(function(recommendation) {
        const row = document.createElement('div');
        row.className = 'recommendation-item';
        row.textContent = `Auction ${recommendation.auction_id} — ${recommendation.recommendation_type} — Score: ${recommendation.score} — ${recommendation.reason}`;

        recommendationList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentRecommendations = data.recommendations || [];
        renderRecommendations();
        recommendationMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        recommendationMenu.classList.remove('visible');
    }
});

refreshButton.addEventListener('click', function() {
    post('generateRecommendations');
});

closeButton.addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
