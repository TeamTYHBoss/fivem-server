window.addEventListener('load', () => {
    const music = document.getElementById('music');

    if (music) {
        music.volume = 0.35;
        music.play().catch(() => {});
    }

    const shutdown = () => {
        fetch(`https://${GetParentResourceName()}/shutdown`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({})
        });
    };

    window.addEventListener('message', (event) => {
        const data = event.data || {};

        if (data.eventName === 'loadProgress') {
            const progress = document.querySelector('.progress-fill');

            if (progress && typeof data.loadFraction === 'number') {
                progress.style.width = `${Math.floor(data.loadFraction * 100)}%`;
            }
        }

        if (data.eventName === 'startInitFunctions' || data.eventName === 'startInitFunctionsOrder') {
            shutdown();
        }
    });
});