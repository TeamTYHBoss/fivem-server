window.addEventListener('message', function(event) {
    const data = event.data || {};

    if (data.action === 'updateStealth') {
        const widget = document.getElementById('stealth-widget');
        const level = document.getElementById('stealth-level');
        const fill = document.getElementById('stealth-fill');
        const xp = document.getElementById('stealth-xp');

        widget.classList.remove('hidden');
        level.textContent = 'Level ' + data.level;
        fill.style.width = data.progress + '%';
        xp.textContent = data.currentXp + ' / ' + data.requiredXp + ' XP';
    }

    if (data.action === 'hideStealth') {
        document.getElementById('stealth-widget').classList.add('hidden');
    }
});