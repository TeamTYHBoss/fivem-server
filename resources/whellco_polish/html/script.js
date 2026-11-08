const polishMenu = document.getElementById('polish');
const checksContainer = document.getElementById('checks');
const reviewsContainer = document.getElementById('reviews');
const closeButton = document.getElementById('close-button');

let currentChecks = [];
let currentReviews = [];

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

function renderChecks() {
    checksContainer.innerHTML = '';

    currentChecks.forEach(function(check) {
        const row = document.createElement('div');
        row.className = 'check';
        row.textContent = `${check.label} — ${check.status}`;

        checksContainer.appendChild(row);
    });
}

function renderReviews() {
    reviewsContainer.innerHTML = '';

    currentReviews.forEach(function(review) {
        const row = document.createElement('div');
        row.className = 'review';
        row.textContent = `${review.check_name} — ${review.status} — ${review.message}`;

        reviewsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentChecks = data.checks || [];
        currentReviews = data.reviews || [];

        renderChecks();
        renderReviews();

        polishMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        polishMenu.classList.remove('visible');
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
