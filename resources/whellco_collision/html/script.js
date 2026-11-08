const collisionMenu = document.getElementById('collision');
const collisionsContainer = document.getElementById('collisions');
const closeButton = document.getElementById('close-button');

let currentCollisions = [];

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

function renderCollisions() {
    collisionsContainer.innerHTML = '';

    currentCollisions.forEach(function(collision) {
        const row = document.createElement('div');
        row.className = 'collision-item';

        const info = document.createElement('div');
        info.className = 'collision-info';
        info.textContent = `Vehicle ${collision.vehicle_id} — ${collision.collision_type} — Damage ${collision.damage} — £${collision.repair_cost}`;

        const repairButton = document.createElement('button');
        repairButton.textContent = 'Repair';

        repairButton.addEventListener('click', function() {
            post('repairVehicle', {
                collisionId: collision.id
            });
        });

        row.appendChild(info);
        row.appendChild(repairButton);
        collisionsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentCollisions = data.collisions || [];
        renderCollisions();
        collisionMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        collisionMenu.classList.remove('visible');
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
