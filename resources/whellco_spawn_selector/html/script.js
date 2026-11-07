const overlay = document.getElementById('overlay');
const locationsContainer = document.getElementById('locations');
const closeButton = document.getElementById('close-button');

function post(callbackName, data) {
    return fetch(`https://${GetParentResourceName()}/${callbackName}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data || {})
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        locationsContainer.innerHTML = '';

        (data.locations || []).forEach(function(location) {
            const button = document.createElement('button');
            button.className = 'location';
            button.type = 'button';

            const title = document.createElement('h2');
            title.textContent = location.label;

            const description = document.createElement('p');
            description.textContent = location.description || '';

            button.appendChild(title);
            button.appendChild(description);

            button.addEventListener('click', function() {
                post('selectSpawn', { id: location.id });
            });

            locationsContainer.appendChild(button);
        });

        overlay.classList.add('visible');
    }

    if (data.action === 'close') {
        overlay.classList.remove('visible');
    }
});

closeButton.addEventListener('click', function() {
    post('close');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('close');
    }
});
