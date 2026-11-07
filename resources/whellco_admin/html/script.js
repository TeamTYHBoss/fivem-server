const admin = document.getElementById('admin');
const resultsContainer = document.getElementById('results');
const searchInput = document.getElementById('search');
const searchButton = document.getElementById('search-button');
const closeButton = document.getElementById('close-button');

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

function renderResults(results) {
    resultsContainer.innerHTML = '';

    results.forEach(function(character) {
        const row = document.createElement('div');
        row.className = 'result';

        const info = document.createElement('div');
        info.className = 'result-info';

        const title = document.createElement('h2');
        title.textContent = `${character.first_name} ${character.last_name}`;

        const details = document.createElement('p');
        details.textContent = `ID: ${character.id} | Cash: £${character.cash || 0} | Bank: £${character.bank || 0} | Level: ${character.level || 1}`;

        info.appendChild(title);
        info.appendChild(details);

        const actions = document.createElement('div');
        actions.className = 'result-actions';

        const accountType = document.createElement('select');
        accountType.innerHTML = '<option value="cash">Cash</option><option value="bank">Bank</option>';

        const amount = document.createElement('input');
        amount.type = 'number';
        amount.min = 1;
        amount.placeholder = 'Amount';

        const giveButton = document.createElement('button');
        giveButton.textContent = 'Give';

        giveButton.addEventListener('click', function() {
            post('giveMoney', {
                characterId: character.id,
                amount: Number(amount.value),
                accountType: accountType.value
            });
        });

        const removeButton = document.createElement('button');
        removeButton.textContent = 'Remove';

        removeButton.addEventListener('click', function() {
            post('removeMoney', {
                characterId: character.id,
                amount: Number(amount.value),
                accountType: accountType.value
            });
        });

        actions.appendChild(accountType);
        actions.appendChild(amount);
        actions.appendChild(giveButton);
        actions.appendChild(removeButton);

        row.appendChild(info);
        row.appendChild(actions);
        resultsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        renderResults(data.results || []);
        admin.classList.add('visible');
    }

    if (data.action === 'close') {
        admin.classList.remove('visible');
    }
});

searchButton.addEventListener('click', function() {
    post('searchPlayers', {
        query: searchInput.value
    });
});

closeButton.addEventListener('click', function() {
    post('closeAdmin');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeAdmin');
    }
});
