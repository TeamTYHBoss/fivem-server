const impoundMenu = document.getElementById('impound');
const impoundsContainer = document.getElementById('impounds');
const closeButton = document.getElementById('close-button');

let currentImpounds = [];

function post(callbackName, data) {
    return fetch(`https://${GetParentResourceName()}/${callbackName}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data || {})
    }).then(function(response) {
        return response.json();
    });
}

function renderImpounds() {
    impoundsContainer.innerHTML = '';

    currentImpounds.forEach(function(impound) {
        const row = document.createElement('div');
        row.className = 'impound-item';

        const info = document.createElement('div');
        info.className = 'impound-info';
        info.textContent = `Vehicle ${impound.vehicle_id} — ${impound.reason} — £${impound.release_fee}`;

        const releaseButton = document.createElement('button');
        releaseButton.textContent = 'Release';

        releaseButton.addEventListener('click', function() {
            post('releaseVehicle', {
                impoundId: impound.id
            });
        });

        row.appendChild(info);
        row.appendChild(releaseButton);
        impoundsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentImpounds = data.impounds || [];
        renderImpounds();
        impoundMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        impoundMenu.classList.remove('visible');
    }
});

closeButton.addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
