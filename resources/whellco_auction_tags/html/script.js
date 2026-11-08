const tagMenu = document.getElementById('auction-tags');
const tagList = document.getElementById('tag-list');
const auctionInput = document.getElementById('auction-input');
const tagInput = document.getElementById('tag-input');
const addButton = document.getElementById('add-button');
const closeButton = document.getElementById('close-button');

let currentTags = [];

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

function renderTags() {
    tagList.innerHTML = '';

    currentTags.forEach(function(tag) {
        const row = document.createElement('div');
        row.className = 'tag-item';

        const info = document.createElement('div');
        info.className = 'tag-info';
        info.textContent = `Auction ${tag.auction_id} — ${tag.tag}`;

        const removeButton = document.createElement('button');
        removeButton.textContent = 'Remove';

        removeButton.addEventListener('click', function() {
            post('removeTag', {
                tagId: tag.id
            });
        });

        row.appendChild(info);
        row.appendChild(removeButton);
        tagList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentTags = data.tags || [];
        renderTags();
        tagMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        tagMenu.classList.remove('visible');
    }
});

addButton.addEventListener('click', function() {
    post('addTag', {
        auctionId: auctionInput.value,
        tag: tagInput.value
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
