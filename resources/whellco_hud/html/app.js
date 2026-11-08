window.addEventListener('message', (event) => {
    const data = event.data || {};

    if (data.action === 'updateHud') {
        document.getElementById('hud').classList.remove('hidden');
        updateBars(data.data || {});
    }

    if (data.action === 'hideHud') {
        document.getElementById('hud').classList.add('hidden');
    }
});

function updateBars(data) {
    const bars = {
        health: data.health || 0,
        armor: data.armor || 0,
        stamina: data.stamina || 0,
        hunger: data.hunger || 0,
        thirst: data.thirst || 0,
        stress: data.stress || 0,
        oxygen: data.oxygen || 0
    };

    for (const [name, value] of Object.entries(bars)) {
        const element = document.querySelector(`.${name} .fill`);

        if (element) {
            element.style.width = `${Math.max(0, Math.min(100, value))}%`;
        }
    }
}

fetch(`https://${GetParentResourceName()}/close`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({})
});