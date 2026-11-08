document.addEventListener('DOMContentLoaded', () => {
    const meter = document.getElementById('suspicion-meter');
    const fill = document.getElementById('suspicion-fill');

    window.addEventListener('message', (event) => {
        const data = event.data;

        if (data.action === 'suspicion') {
            meter.classList.remove('hidden');
            fill.style.width = `${data.value}%`;

            if (data.value >= 75) {
                fill.style.background = '#d64545';
            } else if (data.value >= 40) {
                fill.style.background = '#ffb347';
            } else {
                fill.style.background = '#2f81f7';
            }
        }
    });
});