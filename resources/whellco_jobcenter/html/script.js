const jobCenter = document.getElementById('jobcenter');
const jobsContainer = document.getElementById('jobs');
const applicationsContainer = document.getElementById('applications');
const historyContainer = document.getElementById('history');
const closeButton = document.getElementById('close-button');

let currentJobs = [];
let currentApplications = [];
let currentHistory = [];

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
        details.textContent = `${job.description} | £${job.payout} | ${job.xp} XP | Level ${job.requiredLevel}`;

        info.appendChild(title);
        info.appendChild(details);

        const actions = document.createElement('div');

        const applyButton = document.createElement('button');
        applyButton.textContent = 'Apply';

        applyButton.addEventListener('click', function() {
            post('applyForJob', {
                jobId: job.id
            });
        });

        const startButton = document.createElement('button');
        startButton.textContent = 'Start';

        startButton.addEventListener('click', function() {
            post('startJob', {
                jobId: job.id
            });
        });

        const completeButton = document.createElement('button');
        completeButton.textContent = 'Complete';

        completeButton.addEventListener('click', function() {
            post('completeJob', {
                jobId: job.id
            });
        });

        actions.appendChild(applyButton);
        actions.appendChild(startButton);
        actions.appendChild(completeButton);

        row.appendChild(info);
        row.appendChild(actions);
        jobsContainer.appendChild(row);
    });
}

function renderApplications() {
    applicationsContainer.innerHTML = '';

    currentApplications.forEach(function(application) {
        const row = document.createElement('div');
        row.className = 'application';
        row.textContent = `${application.job_id} — ${application.status}`;

        applicationsContainer.appendChild(row);
    });
}

function renderHistory() {
    historyContainer.innerHTML = '';

    currentHistory.forEach(function(entry) {
        const row = document.createElement('div');
        row.className = 'history-item';
        row.textContent = `${entry.job_id} — £${entry.payout} — ${entry.xp} XP`;

        historyContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentJobs = data.jobs || [];
        currentApplications = data.applications || [];
        currentHistory = data.history || [];

        renderJobs();
        renderApplications();
        renderHistory();

        jobCenter.classList.add('visible');
    }

    if (data.action === 'close') {
        jobCenter.classList.remove('visible');
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
