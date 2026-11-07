const performanceMenu = document.getElementById('performance');
const metricsContainer = document.getElementById('metrics');
const loadOrderContainer = document.getElementById('load-order');
const closeButton = document.getElementById('close-button');

let currentMetrics = [];
let currentLoadOrder = [];

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

    currentMetrics.forEach(function(metric) {
        const row = document.createElement('div');
        row.className = 'metric';
        row.textContent = `${metric.label} — ${metric.value}`;

        metricsContainer.appendChild(row);
    });
}

function renderLoadOrder() {
    loadOrderContainer.innerHTML = '';

    currentLoadOrder.forEach(function(resource, index) {
        const row = document.createElement('div');
        row.className = 'resource';

        const info = document.createElement('div');
        info.className = 'resource-info';
        info.textContent = `${index + 1}. ${resource}`;

        const optimizeButton = document.createElement('button');
        optimizeButton.textContent = 'Optimize';

        optimizeButton.addEventListener('click', function() {
            post('optimizeResource', {
                resource: resource
            });
        });

        row.appendChild(info);
        row.appendChild(optimizeButton);
        loadOrderContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentMetrics = data.metrics || [];
        currentLoadOrder = data.loadOrder || [];

        renderMetrics();
        renderLoadOrder();

        performanceMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        performanceMenu.classList.remove('visible');
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
