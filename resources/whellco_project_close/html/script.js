const projectCloseMenu = document.getElementById('projectclose');
const stepsContainer = document.getElementById('steps');
const recordsContainer = document.getElementById('records');
const closeButton = document.getElementById('close-button');

let currentSteps = [];
let currentRecords = [];

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

function renderSteps() {
    stepsContainer.innerHTML = '';

    currentSteps.forEach(function(step) {
        const row = document.createElement('div');
        row.className = 'step';

        const info = document.createElement('div');
        info.className = 'step-info';
        info.textContent = step.label;

        const completeButton = document.createElement('button');
        completeButton.textContent = 'Complete';

        completeButton.addEventListener('click', function() {
            post('completeStep', {
                step: step.id
            });
        });

        row.appendChild(info);
        row.appendChild(completeButton);
        stepsContainer.appendChild(row);
    });
}

function renderRecords() {
    recordsContainer.innerHTML = '';

    currentRecords.forEach(function(record) {
        const row = document.createElement('div');
        row.className = 'record';
        row.textContent = `${record.step} — ${record.completed ? 'Completed' : 'Pending'}`;

        recordsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentSteps = data.steps || [];
        currentRecords = data.records || [];

        renderSteps();
        renderRecords();

        projectCloseMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        projectCloseMenu.classList.remove('visible');
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
