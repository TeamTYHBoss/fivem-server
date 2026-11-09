document.addEventListener('click', async event => {
    const target = event.target;

    if (target.id === 'close') {
        ComputerState.isOpen = false;
        document.getElementById('computer').classList.add('hidden');
        postNui('escape');
        return;
    }

    if (ComputerState.pendingRequest) {
        return;
    }

    if (target.classList.contains('tab')) {
        const tabName = target.dataset.tab;

        if (!tabName) {
            return;
        }

        setActiveTab(tabName);

        document.querySelectorAll('.tab').forEach(tab => {
            tab.classList.toggle('active', tab.dataset.tab === tabName);
        });

        document.querySelectorAll('.panel').forEach(panel => {
            panel.classList.toggle('active', panel.id === tabName);
        });

        if (tabName === 'bank') {
            await refreshBank();
        } else if (tabName === 'shop') {
            await refreshShop();
        } else if (tabName === 'marketplace') {
            await refreshMarketplace();
        } else if (tabName === 'social') {
            await refreshSocial();
        } else if (tabName === 'notifications') {
            await refreshNotifications();
        }

        return;
    }

    if (target.id === 'refresh-balance') {
        setPendingRequest(true);
        await refreshBank();
        setPendingRequest(false);
        return;
    }

    if (target.id === 'send-transfer') {
        const recipientInput = document.getElementById('transfer-recipient');
        const amountInput = document.getElementById('transfer-amount');

        const recipientId = recipientInput ? recipientInput.value.trim() : '';
        const amount = amountInput ? amountInput.value : 0;

        if (!recipientId || !amount) {
            showMessage('Enter a recipient citizen ID and transfer amount.', 'error');
            return;
        }

        setPendingRequest(true);

        const result = await transferMoney({
            recipientId,
            amount: Number(amount)
        });

        setPendingRequest(false);
        showMessage(result.message, result.success ? 'success' : 'error');

        if (recipientInput) {
            recipientInput.value = '';
        }

        if (amountInput) {
            amountInput.value = '';
        }

        await refreshBank();
        return;
    }

    if (target.id === 'refresh-marketplace') {
        setPendingRequest(true);
        await refreshMarketplace();
        setPendingRequest(false);
        return;
    }

    if (target.id === 'create-listing') {
        const itemInput = document.getElementById('listing-item');
        const quantityInput = document.getElementById('listing-quantity');
        const priceInput = document.getElementById('listing-price');

        const itemName = itemInput ? itemInput.value.trim() : '';
        const quantity = quantityInput ? Number(quantityInput.value) : 0;
        const price = priceInput ? Number(priceInput.value) : 0;

        if (!itemName || !quantity || !price) {
            showMessage('Enter an item name, quantity, and price.', 'error');
            return;
        }

        setPendingRequest(true);

        const result = await createListing({
            itemName,
            quantity,
            price
        });

        setPendingRequest(false);
        showMessage(result.message, result.success ? 'success' : 'error');

        if (itemInput) {
            itemInput.value = '';
        }

        if (quantityInput) {
            quantityInput.value = '';
        }

        if (priceInput) {
            priceInput.value = '';
        }

        await refreshMarketplace();
        return;
    }

    if (target.id === 'create-post') {
        const contentInput = document.getElementById('post-content');
        const content = contentInput ? contentInput.value.trim() : '';

        if (!content) {
            showMessage('Enter a post before publishing.', 'error');
            return;
        }

        setPendingRequest(true);

        const result = await createPost(content);

        setPendingRequest(false);
        showMessage(result.message, result.success ? 'success' : 'error');

        if (contentInput) {
            contentInput.value = '';
        }

        await refreshSocial();
        return;
    }

    if (target.id === 'refresh-notifications') {
        setPendingRequest(true);
        await refreshNotifications();
        setPendingRequest(false);
        return;
    }

    if (target.dataset.itemId) {
        setPendingRequest(true);

        const result = await buyItem(target.dataset.itemId);

        setPendingRequest(false);
        showMessage(result.message, result.success ? 'success' : 'error');
        await refreshShop();
    }

    if (target.dataset.cancelId) {
        setPendingRequest(true);

        const result = await cancelListing(target.dataset.cancelId);

        setPendingRequest(false);
        showMessage(result.message, result.success ? 'success' : 'error');
        await refreshMarketplace();
    }

    if (target.dataset.buyId) {
        setPendingRequest(true);

        const result = await buyListing(target.dataset.buyId);

        setPendingRequest(false);
        showMessage(result.message, result.success ? 'success' : 'error');
        await refreshMarketplace();
    }

    if (target.dataset.notificationId) {
        setPendingRequest(true);

        await markNotificationRead(target.dataset.notificationId);

        setPendingRequest(false);
        await refreshNotifications();
    }
});

async function refreshBank() {
    const balance = await getBankBalance();
    const transfers = await getTransfers();

    setBankBalance(balance);
    setTransfers(transfers);
    renderBank();
}

async function refreshShop() {
    const shop = await getShop();

    setShopItems(shop);
    renderShop();
}

async function refreshMarketplace() {
    const listings = await getMarketplace();

    setListings(listings);
    renderMarketplace();
}

async function refreshSocial() {
    const posts = await getPosts();

    setPosts(posts);
    renderSocial();
}

async function refreshNotifications() {
    const notifications = await getNotifications();
    const unreadCount = await postNui('getUnreadCount');

    setNotifications(notifications);
    setUnreadCount(unreadCount);
    renderNotifications();
}

window.addEventListener('message', async event => {
    const data = event.data || {};

    if (data.action === 'open') {
        ComputerState.isOpen = true;
        ComputerState.citizenId = data.citizenId || '';

        document.getElementById('computer').classList.remove('hidden');

        await refreshBank();
    }

    if (data.action === 'close') {
        ComputerState.isOpen = false;
        document.getElementById('computer').classList.add('hidden');
    }
});

document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && ComputerState.isOpen) {
        ComputerState.isOpen = false;
        document.getElementById('computer').classList.add('hidden');
        postNui('escape');
    }
});
