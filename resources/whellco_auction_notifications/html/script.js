const notificationMenu = document.getElementById('auction-notifications');
const notificationsContainer = document.getElementById('notifications');
const closeButton = document.getElementById('close-button');

let currentNotifications = [];

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

function renderNotifications() {
    notificationsContainer.innerHTML = '';

    currentNotifications.forEach(function(notification) {
        const row = document.createElement('div');
        row.className = 'notification-item';
        row.textContent = `${notification.notification_type} — ${notification.message} — ${notification.created_at}`;

        notificationsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentNotifications = data.notifications || [];
        renderNotifications();
        notificationMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        notificationMenu.classList.remove('visible');
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
