const policeMenu = document.getElementById('police');
const jobsContainer = document.getElementById('jobs');
const citationsContainer = document.getElementById('citations');
const arrestsContainer = document.getElementById('arrests');
const closeButton = document.getElementById('close-button');

let currentJobs = [];
let currentCitations = [];
let currentArrests = [];

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

function renderCitations() {
    citationsContainer.innerHTML = '';

    currentCitations.forEach(function(citation) {
        const row = document.createElement('div');
        row.className = 'citation';
        row.textContent = `${citation.citation_type} — £${citation.fine}`;

        citationsContainer.appendChild(row);
    });
}

function renderArrests() {
    arrestsContainer.innerHTML = '';

    currentArrests.forEach(function(arrest) {
        const row = document.createElement('div');
        row.className = 'arrest';
        row.textContent = `${arrest.reason} — ${arrest.released_at ? 'Released' : 'In custody'}`;

        arrestsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentJobs = data.jobs || [];
        currentCitations = data.citations || [];
        currentArrests = data.arrests || [];

        renderJobs();
        renderCitations();
        renderArrests();

        policeMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        policeMenu.classList.remove('visible');
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
