const handoverMenu = document.getElementById('handover');
const sectionsContainer = document.getElementById('sections');
const signoffsContainer = document.getElementById('signoffs');
const closeButton = document.getElementById('close-button');

let currentSections = [];
let currentSignoffs = [];

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

        const signOffButton = document.createElement('button');
        signOffButton.textContent = 'Sign Off';

        signOffButton.addEventListener('click', function() {
            post('signOffSection', {
                section: section.id
            });
        });

        row.appendChild(title);
        row.appendChild(content);
        row.appendChild(signOffButton);
        sectionsContainer.appendChild(row);
    });
}

function renderSignoffs() {
    signoffsContainer.innerHTML = '';

    currentSignoffs.forEach(function(signoff) {
        const row = document.createElement('div');
        row.className = 'signoff';
        row.textContent = `${signoff.section} — ${signoff.signed_off ? 'Signed off' : 'Pending'}`;

        signoffsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentSections = data.sections || [];
        currentSignoffs = data.signoffs || [];

        renderSections();
        renderSignoffs();

        handoverMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        handoverMenu.classList.remove('visible');
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
