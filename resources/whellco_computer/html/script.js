let currentTab = 'bank';
let playerCitizenId = '';

function request(name, data = {}) {
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        body: JSON.stringify(data)
    }).then(response => response.json());
}

function setStatus(id, message, isError = false) {
    const element = document.getElementById(id);

    if (!element) {
        return;
    }

    element.textContent = message || '';
    element.classList.toggle('error', Boolean(isError));
}

function showTab(tab) {
    currentTab = tab;

    document.querySelectorAll('.tab').forEach(button => {
        button.classList.toggle('active', button.dataset.tab === tab);
    });

    document.querySelectorAll('.panel').forEach(panel => {
        panel.classList.toggle('active', panel.id === tab);
    });

    if (tab === 'bank') {
        refreshBalance();
        refreshTransfers();
    } else if (tab === 'shop') {
        loadShop();
    } else if (tab === 'marketplace') {
        refreshMarketplace();
    } else if (tab === 'social') {
        refreshPosts();
    } else if (tab === 'notifications') {
        refreshNotifications();
    }
}

function refreshBalance() {
    request('getBankBalance').then(balance => {
        document.getElementById('balance').textContent = `$${Number(balance || 0).toLocaleString()}`;
    });
}

function refreshTransfers() {
    request('getTransfers').then(transfers => {
        const container = document.getElementById('transfers');
        container.textContent = '';

        transfers.forEach(transfer => {
            const element = document.createElement('div');
            element.className = 'transfer';
            element.textContent = `#${transfer.id} - ${transfer.sender} to ${transfer.recipient}: $${transfer.amount} (${transfer.status})`;
            container.appendChild(element);
        });
    });
}

function loadShop() {
    request('getShop').then(items => {
        const container = document.getElementById('shop-items');
        container.textContent = '';

        Object.entries(items).forEach(([id, item]) => {
            const element = document.createElement('div');
            element.className = 'shop-item';

            const label = document.createElement('span');
            label.textContent = `${item.label} - $${item.price}`;

            const button = document.createElement('button');
            button.textContent = 'Buy';
            button.onclick = () => {
                button.disabled = true;
                setStatus('shop-status', '');

                request('buyItem', { itemId: id }).then(response => {
                    setStatus('shop-status', response.message || (response.success ? 'Purchase complete' : 'Purchase failed'), !response.success);
                    refreshBalance();
                }).finally(() => {
                    button.disabled = false;
                });
            };

            element.appendChild(label);
            element.appendChild(button);
            container.appendChild(element);
        });
    });
}

function refreshMarketplace() {
    request('getMarketplace').then(listings => {
        const container = document.getElementById('listings');
        container.textContent = '';

        listings.forEach(listing => {
            const element = document.createElement('div');
            element.className = 'listing';

            const label = document.createElement('span');
            label.textContent = `${listing.item} x${listing.quantity} - $${listing.price}`;

            element.appendChild(label);

            if (listing.seller !== playerCitizenId) {
                const buyButton = document.createElement('button');
                buyButton.textContent = 'Buy';
                buyButton.onclick = () => {
                    buyButton.disabled = true;
                    setStatus('marketplace-status', '');

                    request('buyListing', { listingId: listing.id }).then(response => {
                        setStatus('marketplace-status', response.message || (response.success ? 'Purchase complete' : 'Purchase failed'), !response.success);
                        refreshMarketplace();
                    }).finally(() => {
                        buyButton.disabled = false;
                    });
                };

                element.appendChild(buyButton);
            } else {
                const cancelButton = document.createElement('button');
                cancelButton.textContent = 'Cancel';
                cancelButton.onclick = () => {
                    cancelButton.disabled = true;
                    setStatus('marketplace-status', '');

                    request('cancelListing', { listingId: listing.id }).then(response => {
                        setStatus('marketplace-status', response.message || (response.success ? 'Listing cancelled' : 'Could not cancel listing'), !response.success);
                        refreshMarketplace();
                    }).finally(() => {
                        cancelButton.disabled = false;
                    });
                };

                element.appendChild(cancelButton);
            }

            container.appendChild(element);
        });
    });
}

function refreshNotifications() {
    request('getNotifications').then(notifications => {
        const container = document.getElementById('notifications-list');
        container.textContent = '';

        notifications.forEach(notification => {
            const element = document.createElement('div');
            element.className = notification.read_at ? 'notification read' : 'notification unread';
            element.textContent = notification.content;

            if (!notification.read_at) {
                const button = document.createElement('button');
                button.textContent = 'Mark read';
                button.onclick = () => {
                    button.disabled = true;

                    request('markNotificationRead', { notificationId: notification.id }).finally(() => {
                        refreshNotifications();
                    });
                };

                element.appendChild(button);
            }

            container.appendChild(element);
        });

        return request('getUnreadNotificationCount');
    }).then(count => {
        const badge = document.getElementById('unread-count');
        badge.textContent = count || 0;
        badge.classList.toggle('hidden', !count);
    });
}

function refreshPosts() {
    request('getPosts').then(posts => {
        const container = document.getElementById('posts');
        container.textContent = '';

        posts.forEach(postData => {
            const element = document.createElement('div');
            element.className = 'post';

            const author = document.createElement('strong');
            author.textContent = postData.author;

            const content = document.createElement('p');
            content.textContent = postData.content;

            element.appendChild(author);
            element.appendChild(content);

            const commentInput = document.createElement('input');
            commentInput.placeholder = 'Write a comment...';

            const commentButton = document.createElement('button');
            commentButton.textContent = 'Comment';
            commentButton.onclick = () => {
                commentButton.disabled = true;
                setStatus('social-status', '');

                request('addComment', {
                    postId: postData.id,
                    content: commentInput.value
                }).then(response => {
                    setStatus('social-status', response.message || (response.success ? 'Comment added' : 'Could not add comment'), !response.success);
                    return refreshPosts();
                }).finally(() => {
                    commentButton.disabled = false;
                });
            };

            element.appendChild(commentInput);
            element.appendChild(commentButton);

            (postData.comments || []).forEach(comment => {
                const commentElement = document.createElement('div');
                commentElement.className = 'comment';

                const commentAuthor = document.createElement('strong');
                commentAuthor.textContent = comment.author;

                const commentContent = document.createElement('p');
                commentContent.textContent = comment.content;

                commentElement.appendChild(commentAuthor);
                commentElement.appendChild(commentContent);
                element.appendChild(commentElement);
            });

            container.appendChild(element);
        });
    });
}

document.querySelectorAll('.tab').forEach(button => {
    button.onclick = () => showTab(button.dataset.tab);
});

document.getElementById('close').onclick = () => request('close');
document.getElementById('refresh-balance').onclick = refreshBalance;
document.getElementById('refresh-marketplace').onclick = refreshMarketplace;
document.getElementById('refresh-notifications').onclick = refreshNotifications;

document.getElementById('send-transfer').onclick = () => {
    const button = document.getElementById('send-transfer');
    const recipient = document.getElementById('transfer-recipient').value.trim();
    const amount = document.getElementById('transfer-amount').value;

    if (!recipient || !amount) {
        return;
    }

    button.disabled = true;
    setStatus('transfer-status', '');

    request('transferMoney', {
        recipient,
        amount
    }).then(response => {
        setStatus('transfer-status', response.message || (response.success ? 'Transfer sent' : 'Transfer failed'), !response.success);

        if (response.success) {
            document.getElementById('transfer-recipient').value = '';
            document.getElementById('transfer-amount').value = '';
        }

        refreshBalance();
        refreshTransfers();
    }).finally(() => {
        button.disabled = false;
    });
};

document.getElementById('create-listing').onclick = () => {
    const button = document.getElementById('create-listing');
    const item = document.getElementById('listing-item').value.trim();
    const quantity = document.getElementById('listing-quantity').value;
    const price = document.getElementById('listing-price').value;

    if (!item || !quantity || !price) {
        return;
    }

    button.disabled = true;
    setStatus('marketplace-status', '');

    request('createListing', {
        item,
        quantity,
        price
    }).then(response => {
        setStatus('marketplace-status', response.message || (response.success ? 'Listing created' : 'Could not create listing'), !response.success);

        if (response.success) {
            document.getElementById('listing-item').value = '';
            document.getElementById('listing-quantity').value = '';
            document.getElementById('listing-price').value = '';
        }

        refreshMarketplace();
    }).finally(() => {
        button.disabled = false;
    });
};

document.getElementById('create-post').onclick = () => {
    const button = document.getElementById('create-post');
    const content = document.getElementById('post-content').value;

    button.disabled = true;
    setStatus('social-status', '');

    request('createPost', { content }).then(response => {
        setStatus('social-status', response.message || (response.success ? 'Post created' : 'Could not create post'), !response.success);

        if (response.success) {
            document.getElementById('post-content').value = '';
        }

        return refreshPosts();
    }).finally(() => {
        button.disabled = false;
    });
};

window.addEventListener('message', event => {
    const data = event.data;

    if (data.action === 'open') {
        document.getElementById('computer').classList.remove('hidden');
        playerCitizenId = data.citizenId || '';
        showTab('bank');
        refreshNotifications();
    } else if (data.action === 'close') {
        document.getElementById('computer').classList.add('hidden');
    }
});

window.addEventListener('keydown', event => {
    if (event.key === 'Escape') {
        request('escape');
    }
});

setInterval(() => {
    if (!document.getElementById('computer').classList.contains('hidden')) {
        refreshNotifications();
    }
}, 30000);