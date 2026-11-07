const bankingMenu = document.getElementById('banking');
const balanceContainer = document.getElementById('balance');
const amountInput = document.getElementById('amount');
const transactionsContainer = document.getElementById('transactions');
const depositButton = document.getElementById('deposit-button');
const withdrawButton = document.getElementById('withdraw-button');
const transferButton = document.getElementById('transfer-button');
const closeButton = document.getElementById('close-button');

let currentBalance = 0;
let currentTransactions = [];

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

function renderTransactions() {
    transactionsContainer.innerHTML = '';

    currentTransactions.forEach(function(transaction) {
        const row = document.createElement('div');
        row.className = 'transaction';
        row.textContent = `${transaction.transaction_type} — £${transaction.amount} — Balance £${transaction.balance_after}`;

        transactionsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentBalance = data.balance || 0;
        currentTransactions = data.transactions || [];

        renderBalance();
        renderTransactions();

        bankingMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        bankingMenu.classList.remove('visible');
    }
});

depositButton.addEventListener('click', function() {
    post('deposit', {
        amount: Number(amountInput.value)
    });
});

withdrawButton.addEventListener('click', function() {
    post('withdraw', {
        amount: Number(amountInput.value)
    });
});

transferButton.addEventListener('click', function() {
    post('transfer', {
        targetId: 0,
        amount: Number(amountInput.value)
    });
});

closeButton.addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
