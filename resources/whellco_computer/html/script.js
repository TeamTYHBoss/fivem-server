let currentTab = 'bank';

function showTab(tab) {
    currentTab = tab;

    document.querySelectorAll('.tab').forEach(button => {
        button.classList.toggle('active', button.dataset.tab === tab);
    });

    document.querySelectorAll('.panel').forEach(panel => {
        panel.classList.toggle('active', panel.id === tab);
    });

    if (tab === 'bank') {
        refreshBalance();
    }

    if (tab === 'social') {
        refreshPosts();
    }
}

function refreshBalance() {
    fetch(`https://${GetParentResourceName()}/getBankBalance`, {
        method: 'POST',
        body: JSON.stringify({})
    }).then(response => response.json()).then(balance => {
        document.getElementById('balance').textContent = `$${balance.toLocaleString()}`;
    });
}

function refreshPosts() {
    fetch(`https://${GetParentResourceName()}/getPosts`, {
        method: 'POST',
        body: JSON.stringify({})
    }).then(response => response.json()).then(posts => {
        const container = document.getElementById('posts');
        container.innerHTML = '';

        posts.forEach(post => {
            const element = document.createElement('div');
            element.className = 'post';
            element.innerHTML = `<strong>${post.author}</strong><p>${post.content}</p>`;

            const commentInput = document.createElement('input');
            commentInput.placeholder = 'Write a comment...';

            const commentButton = document.createElement('button');
            commentButton.textContent = 'Comment';
            commentButton.onclick = () => {
                fetch(`https://${GetParentResourceName()}/addComment`, {
                    method: 'POST',
                    body: JSON.stringify({
                        postId: post.id,
                        content: commentInput.value
                    })
                }).then(() => refreshPosts());
            };

            element.appendChild(commentInput);
            element.appendChild(commentButton);

            post.comments.forEach(comment => {
                const commentElement = document.createElement('div');
                commentElement.className = 'comment';
                commentElement.innerHTML = `<strong>${comment.author}</strong><p>${comment.content}</p>`;
                element.appendChild(commentElement);
            });

            container.appendChild(element);
        });
    });
}

function loadShop() {
    fetch(`https://${GetParentResourceName()}/getShop`, {
        method: 'POST',
        body: JSON.stringify({})
    }).then(response => response.json()).then(items => {
        const container = document.getElementById('shop-items');
        container.innerHTML = '';

        Object.entries(items).forEach(([id, item]) => {
            const element = document.createElement('div');
            element.className = 'shop-item';
            element.innerHTML = `<span>${item.label} - $${item.price}</span>`;

            const button = document.createElement('button');
            button.textContent = 'Buy';
            button.onclick = () => {
                fetch(`https://${GetParentResourceName()}/buyItem`, {
                    method: 'POST',
                    body: JSON.stringify({
                        itemId: id
                    })
                }).then(() => refreshBalance());
            };

            element.appendChild(button);
            container.appendChild(element);
        });
    });
}

document.querySelectorAll('.tab').forEach(button => {
    button.onclick = () => showTab(button.dataset.tab);
});

document.getElementById('close').onclick = () => {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST',
        body: JSON.stringify({})
    });
};

document.getElementById('refresh-balance').onclick = refreshBalance;

document.getElementById('create-post').onclick = () => {
    const content = document.getElementById('post-content').value;

    fetch(`https://${GetParentResourceName()}/createPost`, {
        method: 'POST',
        body: JSON.stringify({ content })
    }).then(() => {
        document.getElementById('post-content').value = '';
        refreshPosts();
    });
};

window.addEventListener('message', event => {
    const data = event.data;

    if (data.action === 'open') {
        document.getElementById('computer').classList.remove('hidden');
        loadShop();
        showTab('bank');
    }

    if (data.action === 'close') {
        document.getElementById('computer').classList.add('hidden');
    }
});