const docsMenu = document.getElementById('docs');
const sectionsContainer = document.getElementById('sections');
const closeButton = document.getElementById('close-button');

let currentSections = [];

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

function renderSections() {
    sectionsContainer.innerHTML = '';

    currentSections.forEach(function(section) {
        const row = document.createElement('div');
        row.className = 'section';

        const title = document.createElement('h2');
        title.textContent = section.label;

        const content = document.createElement('p');
        content.textContent = section.content;

        row.appendChild(title);
        row.appendChild(content);
        sectionsContainer.appendChild(row);

        row.addEventListener('click', function() {
            post('viewSection', {
                section: section.id
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
        currentSections = data.sections || [];

        renderSections();

        docsMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        docsMenu.classList.remove('visible');
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
