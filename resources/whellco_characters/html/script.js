const charactersMenu = document.getElementById('characters');
const characterCount = document.getElementById('character-count');
const charactersList = document.getElementById('characters-list');
const spawnPoint = document.getElementById('spawn-point');
const firstName = document.getElementById('first-name');
const lastName = document.getElementById('last-name');
const dateOfBirth = document.getElementById('date-of-birth');
const gender = document.getElementById('gender');
const createButton = document.getElementById('create-button');
const closeButton = document.getElementById('close-button');

let currentCharacters = [];
let currentSpawnPoints = [];
let maxCharacters = 3;

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

function renderCharacters() {
    charactersList.innerHTML = '';
    characterCount.textContent = `${currentCharacters.length} / ${maxCharacters} characters`;

    currentCharacters.forEach(function(character) {
        const row = document.createElement('div');
        row.className = 'character';

        const info = document.createElement('div');
        info.className = 'character-info';

        const title = document.createElement('h2');
        title.textContent = `${character.first_name} ${character.last_name}`;

        const details = document.createElement('p');
        details.textContent = `${character.date_of_birth} | ${character.gender}`;

        info.appendChild(title);
        info.appendChild(details);

        const actions = document.createElement('div');
        actions.className = 'character-actions';

        const selectButton = document.createElement('button');
        selectButton.textContent = 'Play';

        selectButton.addEventListener('click', function() {
            post('selectCharacter', {
                characterId: character.id
            });
        });

        const deleteButton = document.createElement('button');
        deleteButton.textContent = 'Delete';

        deleteButton.addEventListener('click', function() {
            post('deleteCharacter', {
                characterId: character.id
            });
        });

        actions.appendChild(selectButton);
        actions.appendChild(deleteButton);

        row.appendChild(info);
        row.appendChild(actions);
        charactersList.appendChild(row);
    });
}

function renderSpawnPoints() {
    spawnPoint.innerHTML = '';

    currentSpawnPoints.forEach(function(point) {
        const option = document.createElement('option');
        option.value = point.id;
        option.textContent = point.label;

        spawnPoint.appendChild(option);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentCharacters = data.characters || [];
        currentSpawnPoints = data.spawnPoints || [];
        maxCharacters = data.maxCharacters || 3;

        renderCharacters();
        renderSpawnPoints();
        charactersMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        charactersMenu.classList.remove('visible');
    }
});

createButton.addEventListener('click', function() {
    post('createCharacter', {
        firstName: firstName.value,
        lastName: lastName.value,
        dateOfBirth: dateOfBirth.value,
        gender: gender.value,
        spawnPoint: spawnPoint.value
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
