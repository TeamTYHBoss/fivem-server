const testingMenu = document.getElementById('testing');
const suitesContainer = document.getElementById('suites');
const resultsContainer = document.getElementById('results');
const closeButton = document.getElementById('close-button');

let currentSuites = [];
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

function renderSuites() {
    suitesContainer.innerHTML = '';

    currentSuites.forEach(function(suite) {
        const row = document.createElement('div');
        row.className = 'suite';

        const info = document.createElement('div');
        info.className = 'suite-info';
        info.textContent = suite.label;

        const runButton = document.createElement('button');
        runButton.textContent = 'Run';

        runButton.addEventListener('click', function() {
            post('runSuite', {
                suite: suite.id
            });
        });

        row.appendChild(info);
        row.appendChild(runButton);
        suitesContainer.appendChild(row);
    });
}

function renderResults() {
    resultsContainer.innerHTML = '';

    currentResults.forEach(function(result) {
        const row = document.createElement('div');
        row.className = 'result';
        row.textContent = `${result.suite} — ${result.test_name} — ${result.status} — ${result.message}`;

        resultsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentSuites = data.suites || [];
        currentResults = data.results || [];

        renderSuites();
        renderResults();

        testingMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        testingMenu.classList.remove('visible');
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
