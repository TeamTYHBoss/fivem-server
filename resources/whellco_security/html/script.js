const securityMenu = document.getElementById('security');
const rulesContainer = document.getElementById('rules');
const eventsContainer = document.getElementById('events');
const closeButton = document.getElementById('close-button');

let currentRules = [];
let currentEvents = [];

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

function renderRules() {
    rulesContainer.innerHTML = '';

    currentRules.forEach(function(rule) {
        const row = document.createElement('div');
        row.className = 'rule';
        row.textContent = rule.label;

        rulesContainer.appendChild(row);
    });
}

function renderEvents() {
    eventsContainer.innerHTML = '';

    currentEvents.forEach(function(event) {
        const row = document.createElement('div');
        row.className = 'event';
        row.textContent = `${event.event_type} — ${event.details}`;

        eventsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentRules = data.rules || [];
        currentEvents = data.events || [];

        renderRules();
        renderEvents();

        securityMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        securityMenu.classList.remove('visible');
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
