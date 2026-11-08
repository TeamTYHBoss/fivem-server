document.addEventListener('click', async event => {
    const target = event.target;

    if (ComputerState.pendingRequest) {
        return;
    }

    if (target.dataset.itemId) {
        setPendingRequest(true);

        const result = await buyItem(target.dataset.itemId);

        setPendingRequest(false);
        showMessage(result.message, result.success ? 'success' : 'error');
        await refreshBank();
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

    setNotifications(notifications);
    renderNotifications();
}

window.addEventListener('message', async event => {
    const data = event.data || {};

    if (data.action === 'open') {
        ComputerState.isOpen = true;
        ComputerState.citizenId = data.citizenId || '';

        document.getElementById('computer').classList.remove('hidden');

        await refreshBank();
        await refreshShop();
        await refreshMarketplace();
        await refreshSocial();
        await refreshNotifications();
    }

    if (data.action === 'close') {
        ComputerState.isOpen = false;
        document.getElementById('computer').classList.add('hidden');
    }
});

document.addEventListener('keydown', event => {
    if (event.key === 'Escape' && ComputerState.isOpen) {
        postNui('escape');
    }
});
