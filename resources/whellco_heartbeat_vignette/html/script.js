window.addEventListener('message', function(event) {
    const data = event.data || {};
    const vignette = document.getElementById('vignette');

    if (data.action === 'heartbeat') {
        vignette.classList.remove('hidden');
        vignette.classList.add('active');

        vignette.classList.remove('pulse');
        void vignette.offsetWidth;
        vignette.classList.add('pulse');
    }

    if (data.action === 'hide') {
        vignette.classList.remove('active', 'pulse');
        vignette.classList.add('hidden');
    }
});