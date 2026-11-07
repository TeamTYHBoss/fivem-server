const jobboard = document.getElementById('jobboard');
const jobsContainer = document.getElementById('jobs');
const closeButton = document.getElementById('close-button');

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

function renderJobs(jobs) {
    jobsContainer.innerHTML = '';

    jobs.forEach(function(job) {
        const row = document.createElement('div');
        row.className = 'job';

        const info = document.createElement('div');
        info.className = 'job-info';

        const title = document.createElement('h2');
        title.textContent = job.label;

        const details = document.createElement('p');
        details.textContent = `£${job.payout} | ${job.xp} XP | Cooldown: ${Math.ceil(job.cooldownRemaining / 1000)}s`;

        info.appendChild(title);
        info.appendChild(details);

        const startButton = document.createElement('button');
        startButton.textContent = 'Start';

        startButton.addEventListener('click', function() {
            post('startJob', {
                jobId: job.id
            });
        });

        row.appendChild(info);
        row.appendChild(startButton);
        jobsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'openJobBoard') {
        renderJobs(data.jobs || []);
        jobboard.classList.add('visible');
    }

    if (data.action === 'closeJobBoard') {
        jobboard.classList.remove('visible');
    }
});

closeButton.addEventListener('click', function() {
    post('closeJobBoard');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeJobBoard');
    }
});
