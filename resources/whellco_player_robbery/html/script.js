document.addEventListener('DOMContentLoaded', () => {
    const minigame = document.getElementById('robbery-minigame');
    const marker = document.getElementById('moving-marker');
    const timer = document.getElementById('timer');
    const progressBar = document.getElementById('progress-bar');
    let active = false;
    let markerPosition = 0;
    let markerDirection = 1;
    let timeLeft = 8;

    window.addEventListener('message', (event) => {
        const data = event.data;

        if (data.action === 'start') {
            minigame.classList.remove('hidden');
            active = true;
            timeLeft = 8;
            markerPosition = 0;
            markerDirection = 1;
            startTimer();
        } else if (data.action === 'close') {
            minigame.classList.add('hidden');
            active = false;
        }
    });

    function startTimer() {
        const interval = setInterval(() => {
            if (!active) {
                clearInterval(interval);
                return;
            }

            timeLeft--;
            timer.textContent = timeLeft;
            progressBar.style.width = `${(timeLeft / 8) * 100}%`;

            if (timeLeft <= 0) {
                clearInterval(interval);
                complete(false);
            }
        }, 1000);
    }

    function complete(success) {
        active = false;
        minigame.classList.add('hidden');

        fetch(`https://${GetParentResourceName()}/complete`, {
            method: 'POST',
            body: JSON.stringify({ success })
        });
    }

    document.addEventListener('keydown', (event) => {
        if (!active || event.code !== 'KeyE') {
            return;
        }

        const success = markerPosition >= 40 && markerPosition <= 60;
        complete(success);
    });

    function animateMarker() {
        if (!active) {
            return;
        }

        markerPosition += markerDirection * 2;

        if (markerPosition >= 100) {
            markerPosition = 100;
            markerDirection = -1;
        } else if (markerPosition <= 0) {
            markerPosition = 0;
            markerDirection = 1;
        }

        marker.style.left = `${markerPosition}%`;
        requestAnimationFrame(animateMarker);
    }

    requestAnimationFrame(animateMarker);
});