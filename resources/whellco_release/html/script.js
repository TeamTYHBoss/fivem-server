const releaseMenu = document.getElementById('release');
const versionContainer = document.getElementById('version');
const releasesContainer = document.getElementById('releases');
const closeButton = document.getElementById('close-button');

let currentVersion = '';
let currentReleases = [];

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

function renderReleases() {
    releasesContainer.innerHTML = '';

    currentReleases.forEach(function(release) {
        const item = document.createElement('div');
        item.className = 'release-item';

        const title = document.createElement('h2');
        title.textContent = `${release.version} — ${release.date}`;

        const list = document.createElement('ul');

        release.changes.forEach(function(change) {
            const listItem = document.createElement('li');
            listItem.textContent = change;

            list.appendChild(listItem);
        });

        item.appendChild(title);
        item.appendChild(list);
        releasesContainer.appendChild(item);

        item.addEventListener('click', function() {
            post('viewRelease', {
                version: release.version
            });
        });
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentVersion = data.version || '';
        currentReleases = data.releases || [];

        versionContainer.textContent = `Current version: ${currentVersion}`;
        renderReleases();

        releaseMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        releaseMenu.classList.remove('visible');
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
