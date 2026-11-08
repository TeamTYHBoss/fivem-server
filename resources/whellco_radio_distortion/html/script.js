window.addEventListener('message', function(event) {
    const data = event.data || {};
    const overlay = document.getElementById('distortion-overlay');

    if (data.action === 'setDistortion') {
        const intensity = Math.max(0, Math.min(1, data.intensity || 0));

        overlay.classList.toggle('active', intensity > 0.05);
        overlay.style.opacity = intensity;
    }

    if (data.action === 'hideDistortion') {
        overlay.classList.remove('active');
        overlay.style.opacity = 0;
    }
});