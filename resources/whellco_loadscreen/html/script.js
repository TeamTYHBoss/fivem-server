const progressBar = document.getElementById('progress-bar');
const percentage = document.getElementById('percentage');
const status = document.getElementById('status');
const tipText = document.getElementById('tip-text');

const tips = [
    'Tip: Use /hello once you are in the city.',
    'Tip: Be respectful to other players.',
    'Tip: Report bugs so the server can improve.',
    'Tip: Check the server rules before roleplaying.',
    'Tip: Explore, make friends, and enjoy the city.'
];

let tipIndex = 0;

function setTip() {
    tipText.textContent = tips[tipIndex];
    tipIndex = (tipIndex + 1) % tips.length;
}

setInterval(setTip, 5000);

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data || data.eventName !== 'loadProgress') {
        return;
    }

    const fraction = Number(data.loadFraction);

    if (!Number.isFinite(fraction)) {
        return;
    }

    const percent = Math.max(0, Math.min(1, fraction)) * 100;

    progressBar.style.width = percent + '%';
    percentage.textContent = Math.round(percent) + '%';
    status.textContent = percent < 100 ? 'Loading game data…' : 'Almost ready…';
});
