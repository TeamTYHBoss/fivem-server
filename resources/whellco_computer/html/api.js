function postNui(name, data) {
    return fetch(`https://${GetParentResourceName()}/${name}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data || {})
    }).then(response => response.json());
}

function getBankBalance() {
    return postNui('getBankBalance');
}

function getShop() {
    return postNui('getShop');
}

function buyItem(itemId) {
    return postNui('buyItem', { itemId });
}

function createListing(data) {
    return postNui('createListing', data);
}

function getMarketplace() {
    return postNui('getMarketplace');
}

function cancelListing(listingId) {
    return postNui('cancelListing', { listingId });
}

function buyListing(listingId) {
    return postNui('buyListing', { listingId });
}

function transferMoney(data) {
    return postNui('transferMoney', data);
}

function getTransfers() {
    return postNui('getTransfers');
}

function getNotifications() {
    return postNui('getNotifications');
}

function markNotificationRead(notificationId) {
    return postNui('markNotificationRead', { notificationId });
}

function getPosts() {
    return postNui('getPosts');
}

function createPost(content) {
    return postNui('createPost', { content });
}

function addComment(postId, content) {
    return postNui('addComment', { postId, content });
}
