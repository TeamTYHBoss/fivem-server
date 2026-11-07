const medicalMenu = document.getElementById('medical');
const jobsContainer = document.getElementById('jobs');
const injuriesContainer = document.getElementById('injuries');
const treatmentsContainer = document.getElementById('treatments');
const closeButton = document.getElementById('close-button');

let currentJobs = [];
let currentInjuries = [];
let currentTreatments = [];

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

function renderJobs() {
    jobsContainer.innerHTML = '';

    currentJobs.forEach(function(job) {
        const row = document.createElement('div');
        row.className = 'job';

        const info = document.createElement('div');
        info.className = 'job-info';

        const title = document.createElement('h2');
        title.textContent = job.label;

        const details = document.createElement('p');
        details.textContent = `Rank ${job.rank} | £${job.salary}`;

        info.appendChild(title);
        info.appendChild(details);

        const dutyButton = document.createElement('button');
        dutyButton.textContent = 'Toggle Duty';

        dutyButton.addEventListener('click', function() {
            post('toggleDuty', {
                jobId: job.id
            });
        });

        row.appendChild(info);
        row.appendChild(dutyButton);
        jobsContainer.appendChild(row);
    });
}

function renderInjuries() {
    injuriesContainer.innerHTML = '';

    currentInjuries.forEach(function(injury) {
        const row = document.createElement('div');
        row.className = 'injury';
        row.textContent = `${injury.injury_type} — ${injury.severity} — ${injury.healed ? 'Healed' : 'Unhealed'}`;

        injuriesContainer.appendChild(row);
    });
}

function renderTreatments() {
    treatmentsContainer.innerHTML = '';

    currentTreatments.forEach(function(treatment) {
        const row = document.createElement('div');
        row.className = 'treatment';
        row.textContent = `${treatment.injury_type} — ${treatment.treatment}`;

        treatmentsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentJobs = data.jobs || [];
        currentInjuries = data.injuries || [];
        currentTreatments = data.treatments || [];

        renderJobs();
        renderInjuries();
        renderTreatments();

        medicalMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        medicalMenu.classList.remove('visible');
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
