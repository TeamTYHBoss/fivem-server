const progressBar = document.getElementById('progress-bar');
const percentage = document.getElementById('percentage');
const status = document.getElementById('status');
const tipText = document.getElementById('tip-text');

const music = document.getElementById('background-music');
const muteButton = document.getElementById('mute-button');
const volumeSlider = document.getElementById('volume-slider');

const tips = [
    'Tip: Use /hello once you are in the city.',
    'Tip: Be respectful to other players.',
    'Tip: Report bugs so the server can improve.',
    'Tip: Check the server rules before roleplaying.',
    'Tip: Explore, make friends, and enjoy the city.'
];

let tipIndex = 0;
let isMuted = false;

function setTip() {
    tipText.textContent = tips[tipIndex];
    tipIndex = (tipIndex + 1) % tips.length;
}

setInterval(setTip, 5000);

function updateMuteButton() {
    muteButton.textContent = isMuted ? '🔇' : '🔊';
}

function applyVolume() {
    music.volume = Number(volumeSlider.value);
    music.muted = isMuted;

    localStorage.setItem('whellco_music_volume', volumeSlider.value);
    localStorage.setItem('whellco_music_muted', isMuted ? '1' : '0');
}

const savedVolume = localStorage.getItem('whellco_music_volume');
const savedMute = localStorage.getItem('whellco_music_muted');

if (savedVolume !== null) {
    volumeSlider.value = savedVolume;
}

if (savedMute === '1') {
    isMuted = true;
}

music.volume = Number(volumeSlider.value);
music.muted = isMuted;
updateMuteButton();

music.play().catch(function() {
    status.textContent = 'Click anywhere to enable music';
});

document.addEventListener('click', function() {
    if (music.paused) {
        music.play().catch(function() {});
    }
});

muteButton.addEventListener('click', function() {
    isMuted = !isMuted;
    updateMuteButton();
    applyVolume();
});

volumeSlider.addEventListener('input', function() {
    if (Number(volumeSlider.value) === 0) {
        isMuted = true;
    } else {
        isMuted = false;
    }

    updateMuteButton();
    applyVolume();
});

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
