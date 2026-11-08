const ComputerState = {
    isOpen: false,
    activeTab: 'bank',
    citizenId: '',
    bankBalance: 0,
    shopItems: {},
    listings: [],
    transfers: [],
    posts: [],
    notifications: [],
    unreadCount: 0,
    pendingRequest: false
};

function setActiveTab(tab) {
    ComputerState.activeTab = tab;
}

function setBankBalance(balance) {
    ComputerState.bankBalance = Number(balance) || 0;
}

function setShopItems(items) {
    ComputerState.shopItems = items || {};
}

function setListings(listings) {
    ComputerState.listings = Array.isArray(listings) ? listings : [];
}

function setTransfers(transfers) {
    ComputerState.transfers = Array.isArray(transfers) ? transfers : [];
}

function setPosts(posts) {
    ComputerState.posts = Array.isArray(posts) ? posts : [];
}

function setNotifications(notifications) {
    ComputerState.notifications = Array.isArray(notifications) ? notifications : [];
}

function setUnreadCount(count) {
    ComputerState.unreadCount = Number(count) || 0;
}

function setPendingRequest(value) {
    ComputerState.pendingRequest = Boolean(value);
}
