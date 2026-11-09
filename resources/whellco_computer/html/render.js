function formatMoney(amount) {
    return `$${Math.floor(Number(amount) || 0)}`;
}

function escapeHtml(value) {
    const container = document.createElement('div');
    container.textContent = String(value ?? '');

    return container.innerHTML;
}

function showMessage(message, kind) {
    const messageElement = document.getElementById('message');

    if (!messageElement) {
        return;
    }

    messageElement.textContent = String(message || '');
    messageElement.className = kind || 'primary';
}

function renderBank() {
    const balanceElement = document.getElementById('balance');
    const transferList = document.getElementById('transfers');

    if (balanceElement) {
        balanceElement.textContent = formatMoney(ComputerState.bankBalance);
    }

    if (transferList) {
        transferList.innerHTML = ComputerState.transfers.map(transfer => `
            <div class="transfer-item">
                <span>${escapeHtml(transfer.request_id)}</span>
                <span>${formatMoney(transfer.amount)}</span>
                <span>${escapeHtml(transfer.status)}</span>
            </div>
        `).join('');
    }
}

function renderShop() {
    const shopList = document.getElementById('shop-items');

    if (!shopList) {
        return;
    }

    shopList.innerHTML = Object.entries(ComputerState.shopItems).map(([itemId, item]) => `
        <div class="shop-item">
            <span>${escapeHtml(item.label || itemId)}</span>
            <span>${formatMoney(item.price)}</span>
            <button data-item-id="${escapeHtml(itemId)}">Buy</button>
        </div>
    `).join('');
}

function renderMarketplace() {
    const marketplaceList = document.getElementById('listings');

    if (!marketplaceList) {
        return;
    }

    marketplaceList.innerHTML = ComputerState.listings.map(listing => `
        <div class="marketplace-item">
            <span>${escapeHtml(listing.item)}</span>
            <span>x${escapeHtml(listing.quantity)}</span>
            <span>${formatMoney(listing.price)}</span>
            ${
                listing.seller === ComputerState.citizenId
                    ? `<button data-cancel-id="${escapeHtml(listing.id)}">Cancel</button>`
                    : `<button data-buy-id="${escapeHtml(listing.id)}">Buy</button>`
            }
        </div>
    `).join('');
}

function renderSocial() {
    const postList = document.getElementById('posts');

    if (!postList) {
        return;
    }

    postList.innerHTML = ComputerState.posts.map(post => `
        <div class="social-post">
            <strong>${escapeHtml(post.author)}</strong>
            <p>${escapeHtml(post.content)}</p>
            <span>${escapeHtml(post.comment_count || 0)} comments</span>
            <div class="comment-form">
                <input
                    type="text"
                    class="comment-input"
                    data-comment-post-id="${escapeHtml(post.id)}"
                    placeholder="Write a comment..."
                >
                <button
                    class="comment-submit"
                    data-comment-post-id="${escapeHtml(post.id)}"
                >Comment</button>
            </div>
        </div>
    `).join('');
}

function renderNotifications() {
    const notificationList = document.getElementById('notifications-list');
    const notificationBadge = document.getElementById('unread-count');

    if (notificationList) {
        notificationList.innerHTML = ComputerState.notifications.map(notification => `
            <div class="notification-item">
                <span>${escapeHtml(notification.content)}</span>
                ${
                    notification.read_at
                        ? ''
                        : `<button data-notification-id="${escapeHtml(notification.id)}">Mark read</button>`
                }
            </div>
        `).join('');
    }

    if (notificationBadge) {
        notificationBadge.textContent = ComputerState.unreadCount;
    }
}

function renderActiveTab() {
    renderBank();
    renderShop();
    renderMarketplace();
    renderSocial();
    renderNotifications();
}
