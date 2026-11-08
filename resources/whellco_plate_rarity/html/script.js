const rarityMenu = document.getElementById('plate-rarity');
const platesContainer = document.getElementById('plates');
const closeButton = document.getElementById('close-button');

let currentPlates = [];

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

function renderPlates() {
    platesContainer.innerHTML = '';

    currentPlates.forEach(function(plate) {
        const row = document.createElement('div');
        row.className = 'plate-item';
        row.textContent = `${plate.plate} — Rarity ${plate.rarity_level} — Value £${plate.rarity_value}`;

        platesContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentPlates = data.plates || [];
        renderPlates();
        rarityMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        rarityMenu.classList.remove('visible');
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
