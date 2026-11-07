const inventory = document.getElementById('inventory');
const inventoryCount = document.getElementById('inventory-count');
const itemsContainer = document.getElementById('items');
const closeButton = document.getElementById('close-button');

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

function renderItems(items) {
    itemsContainer.innerHTML = '';
    inventoryCount.textContent = `${items.length} items`;

    items.forEach(function(item) {
        const row = document.createElement('div');
        row.className = 'item';

        const info = document.createElement('div');
        info.className = 'item-info';

        const title = document.createElement('h2');
        title.textContent = `${item.label} x${item.quantity}`;

        const description = document.createElement('p');
        description.textContent = item.description || '';

        info.appendChild(title);
        info.appendChild(description);

        const actions = document.createElement('div');
        actions.className = 'item-actions';

        if (item.usable) {
            const useButton = document.createElement('button');
            useButton.textContent = 'Use';

            useButton.addEventListener('click', function() {
                post('useItem', {
                    itemId: item.id
                });
            });

            actions.appendChild(useButton);
        }

        row.appendChild(info);
        row.appendChild(actions);
        itemsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'openInventory') {
        renderItems(data.items || []);
        inventory.classList.add('visible');
    }

    if (data.action === 'closeInventory') {
        inventory.classList.remove('visible');
    }
});

closeButton.addEventListener('click', function() {
    post('closeInventory');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeInventory');
    }
});
