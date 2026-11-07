const cash = document.getElementById('cash');
const bank = document.getElementById('bank');
const level = document.getElementById('level');
const xp = document.getElementById('xp');
const xpFill = document.getElementById('xp-fill');
const job = document.getElementById('job');
const jobLabel = document.getElementById('job-label');
const jobProgress = document.getElementById('job-progress');

let currentLevel = 1;
let currentXp = 0;

function updateAccount(account) {
    cash.textContent = `£${account.cash}`;
    bank.textContent = `£${account.bank}`;

    currentLevel = account.level;
    currentXp = account.xp;

    level.textContent = account.level;
    xp.textContent = `${account.xp} XP`;

    const thresholds = [0, 250, 600, 1100, 1750, 2600, 3700, 5000, 6600, 8500];
    const nextThreshold = thresholds[account.level] || thresholds[thresholds.length - 1];
    const previousThreshold = account.level > 1 ? thresholds[account.level - 1] : 0;
    const progress = Math.max(0, Math.min(100, ((account.xp - previousThreshold) / (nextThreshold - previousThreshold)) * 100));

    xpFill.style.width = `${progress}%`;
}

function updateJob(label, routeIndex, routeTotal) {
    if (!label) {
        job.classList.remove('visible');
        return;
    }

    job.classList.add('visible');
    jobLabel.textContent = label;
    jobProgress.textContent = routeTotal > 0 ? `${Math.min(routeIndex, routeTotal)}/${routeTotal}` : '';
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'updateAccount') {
        updateAccount(data.account);
    }

    if (data.action === 'jobStarted') {
        updateJob(data.job.label, data.job.routeIndex, data.job.routeTotal);
    }

    if (data.action === 'routeAdvanced') {
        updateJob(jobLabel.textContent, data.routeIndex, data.routeTotal);
    }

    if (data.action === 'jobCompleted') {
        updateJob(null);
    }
});
