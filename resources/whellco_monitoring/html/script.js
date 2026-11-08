const monitoringMenu = document.getElementById('monitoring');
const metricsContainer = document.getElementById('metrics');
const alertsContainer = document.getElementById('alerts');
const refreshButton = document.getElementById('refresh-button');
const closeButton = document.getElementById('close-button');

let currentMetrics = {};
let currentAlerts = [];

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

function renderMetrics() {
    metricsContainer.innerHTML = '';

    for (const key in currentMetrics) {
        const row = document.createElement('div');
        row.className = 'metric';
        row.textContent = `${key} — ${currentMetrics[key]}`;

        metricsContainer.appendChild(row);
    }
}

function renderAlerts() {
    alertsContainer.innerHTML = '';

    currentAlerts.forEach(function(alert) {
        const row = document.createElement('div');
        row.className = 'alert';
        row.textContent = `${alert.metric} — ${alert.value} — ${alert.message}`;

        alertsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentMetrics = data.metrics || {};
        currentAlerts = data.alerts || [];

        renderMetrics();
        renderAlerts();

        monitoringMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        monitoringMenu.classList.remove('visible');
    }
});

refreshButton.addEventListener('click', function() {
    post('refreshMetrics');
});

closeButton.addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
