const economyMenu = document.getElementById('economy');
const balanceContainer = document.getElementById('balance');
const sectionsContainer = document.getElementById('sections');
const receiptsContainer = document.getElementById('receipts');
const closeButton = document.getElementById('close-button');

let currentBalance = 0;
let currentSections = [];
let currentReceipts = [];

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

function renderBalance() {
    balanceContainer.textContent = `Balance: £${currentBalance}`;
}

function renderSections() {
    sectionsContainer.innerHTML = '';

    currentSections.forEach(function(section) {
        const row = document.createElement('div');
        row.className = 'section';

        const info = document.createElement('div');
        info.className = 'section-info';
        info.textContent = section.label;

        const openButton = document.createElement('button');
        openButton.textContent = 'Open';

        openButton.addEventListener('click', function() {
            post('openSection', {
                section: section.id
            });
        });

        row.appendChild(info);
        row.appendChild(openButton);
        sectionsContainer.appendChild(row);
    });
}

function renderReceipts() {
    receiptsContainer.innerHTML = '';

    currentReceipts.forEach(function(receipt) {
        const row = document.createElement('div');
        row.className = 'receipt';
        row.textContent = `${receipt.category} — ${receipt.description} — £${receipt.amount}`;

        receiptsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentBalance = data.balance || 0;
        currentSections = data.sections || [];
        currentReceipts = data.receipts || [];

        renderBalance();
        renderSections();
        renderReceipts();

        economyMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        economyMenu.classList.remove('visible');
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
