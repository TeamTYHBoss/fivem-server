const mechanicMenu = document.getElementById('mechanic');
const jobsContainer = document.getElementById('jobs');
const repairsContainer = document.getElementById('repairs');
const upgradesContainer = document.getElementById('upgrades');
const closeButton = document.getElementById('close-button');

let currentJobs = [];
let currentRepairs = [];
let currentUpgrades = [];

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

function renderRepairs() {
    repairsContainer.innerHTML = '';

    currentRepairs.forEach(function(repair) {
        const row = document.createElement('div');
        row.className = 'repair';
        row.textContent = `${repair.vehicle_plate} — ${repair.repair_type} — £${repair.price}`;

        repairsContainer.appendChild(row);
    });
}

function renderUpgrades() {
    upgradesContainer.innerHTML = '';

    currentUpgrades.forEach(function(upgrade) {
        const row = document.createElement('div');
        row.className = 'upgrade';
        row.textContent = `${upgrade.vehicle_plate} — ${upgrade.upgrade_type} — £${upgrade.price}`;

        upgradesContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentJobs = data.jobs || [];
        currentRepairs = data.repairs || [];
        currentUpgrades = data.upgrades || [];

        renderJobs();
        renderRepairs();
        renderUpgrades();

        mechanicMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        mechanicMenu.classList.remove('visible');
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
