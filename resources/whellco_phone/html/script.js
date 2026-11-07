const phone = document.getElementById('phone');
const phoneNumber = document.getElementById('phone-number');
const contactsPanel = document.getElementById('contacts');
const messagesPanel = document.getElementById('messages');
const callsPanel = document.getElementById('calls');
const closeButton = document.getElementById('close-button');

let currentContacts = [];
let currentMessages = [];
let currentCalls = [];

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

function renderContacts() {
    contactsPanel.innerHTML = '';

    currentContacts.forEach(function(contact) {
        const row = document.createElement('div');
        row.className = 'contact';
        row.textContent = `${contact.name} — ${contact.phone_number || 'Unknown'}`;

        contactsPanel.appendChild(row);
    });
}

function renderMessages() {
    messagesPanel.innerHTML = '';

    currentMessages.forEach(function(message) {
        const row = document.createElement('div');
        row.className = 'message';
        row.textContent = message.message;

        messagesPanel.appendChild(row);
    });
}

function renderCalls() {
    callsPanel.innerHTML = '';

    currentCalls.forEach(function(call) {
        const row = document.createElement('div');
        row.className = 'call';
        row.textContent = `Call ${call.id} — ${call.status}`;

        callsPanel.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentContacts = data.contacts || [];
        currentMessages = data.messages || [];
        currentCalls = data.calls || [];

        phoneNumber.textContent = `Number: ${data.phoneNumber || 'Unknown'}`;

        renderContacts();
        renderMessages();
        renderCalls();

        phone.classList.add('visible');
    }

    if (data.action === 'close') {
        phone.classList.remove('visible');
    }
});

document.querySelectorAll('.tab').forEach(function(tab) {
    tab.addEventListener('click', function() {
        document.querySelectorAll('.tab').forEach(function(other) {
            other.classList.remove('active');
        });

        tab.classList.add('active');

        contactsPanel.classList.add('hidden');
        messagesPanel.classList.add('hidden');
        callsPanel.classList.add('hidden');

        if (tab.dataset.tab === 'contacts') {
            contactsPanel.classList.remove('hidden');
        }

        if (tab.dataset.tab === 'messages') {
            messagesPanel.classList.remove('hidden');
        }

        if (tab.dataset.tab === 'calls') {
            callsPanel.classList.remove('hidden');
        }
    });
});

closeButton.addEventListener('click', function() {
    post('closePhone');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closePhone');
    }
});
