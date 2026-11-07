const progressBar = document.getElementById('progress-bar');
const percentage = document.getElementById('percentage');
const status = document.getElementById('status');
const tipText = document.getElementById('tip-text');

const music = document.getElementById('background-music');
const muteButton = document.getElementById('mute-button');
const volumeSlider = document.getElementById('volume-slider');

const tips = [
    'Tip: Read the server rules before entering the city.',
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

const tabs = document.querySelectorAll('.tab');
const panels = document.querySelectorAll('.panel');

tabs.forEach(function(tab) {
    tab.addEventListener('click', function() {
        const target = tab.dataset.panel;

        tabs.forEach(function(item) {
            item.classList.toggle('active', item === tab);
        });

        panels.forEach(function(panel) {
            panel.classList.toggle('active', panel.id === target);
        });
    });
});

const playerCount = document.getElementById('player-count');
const playerList = document.getElementById('player-list');

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.eventName === 'whellcoPlayerCount') {
        const players = Number(data.players) || 0;
        const maxPlayers = Number(data.maxPlayers) || 0;
        const names = Array.isArray(data.playerNames) ? data.playerNames : [];

        playerCount.textContent = maxPlayers > 0
            ? players + ' / ' + maxPlayers
            : players + ' online';

        playerList.innerHTML = '';

        if (names.length === 0) {
            const emptyItem = document.createElement('li');
            emptyItem.className = 'empty';
            emptyItem.textContent = 'No players are currently connected.';
            playerList.appendChild(emptyItem);
        } else {
            names.forEach(function(player) {
                const item = document.createElement('li');

                const name = document.createElement('span');
                name.textContent = player.name || 'Unknown Player';

                const id = document.createElement('span');
                id.className = 'player-id';
                id.textContent = 'ID ' + player.id;

                item.appendChild(name);
                item.appendChild(id);
                playerList.appendChild(item);
            });
        }

        return;
    }

    if (data.eventName !== 'loadProgress') {
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
