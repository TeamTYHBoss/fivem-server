const shop = document.getElementById('shop');
const shopTitle = document.getElementById('shop-title');
const shopBalance = document.getElementById('shop-balance');
const itemsContainer = document.getElementById('items');
const receipt = document.getElementById('receipt');
const closeButton = document.getElementById('close-button');

let currentShop = null;

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

function renderItems() {
    itemsContainer.innerHTML = '';

    Object.entries(currentShop.items).forEach(function([itemId, item]) {
        const row = document.createElement('div');
        row.className = 'item';

        const info = document.createElement('div');
        info.className = 'item-info';

        const title = document.createElement('h2');
        title.textContent = item.label;

        const description = document.createElement('p');
        description.textContent = `${item.description || ''} — £${item.price}`;

        info.appendChild(title);
        info.appendChild(description);

        const actions = document.createElement('div');
        actions.className = 'item-actions';

        const quantity = document.createElement('input');
        quantity.type = 'number';
        quantity.min = 1;
        quantity.max = 10;
        quantity.value = 1;

        const buyButton = document.createElement('button');
        buyButton.textContent = 'Buy';

        buyButton.addEventListener('click', async function() {
            const result = await post('purchaseItem', {
                shopId: currentShop.shopId,
                itemId: itemId,
                quantity: Number(quantity.value)
            });

            if (result.ok) {
                const data = result.receipt;

                receipt.textContent = [
                    'Receipt',
                    `${data.quantity}x ${data.item}`,
                    `Total: £${data.total}`,
                    `Cash remaining: £${data.cash}`,
                    `XP: ${data.xp}`,
                    `Level: ${data.level}`
                ].join('\n');
            } else {
                receipt.textContent = result.error || 'Purchase failed.';
            }
        });

        actions.appendChild(quantity);
        actions.appendChild(buyButton);

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

    if (data.action === 'open') {
        currentShop = data.shop;
        shopTitle.textContent = currentShop.label;
        shopBalance.textContent = `Cash: £${currentShop.cash} | Bank: £${currentShop.bank}`;

        renderItems();
        shop.classList.add('visible');
    }

    if (data.action === 'updateAccount' && currentShop) {
        shopBalance.textContent = `Cash: £${data.account.cash} | Bank: £${data.account.bank}`;
    }

    if (data.action === 'close') {
        shop.classList.remove('visible');
    }
});

closeButton.addEventListener('click', function() {
    post('closeShop');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeShop');
    }
});
