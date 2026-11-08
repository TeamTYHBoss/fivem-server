document.addEventListener('DOMContentLoaded', () => {
    const menu = document.getElementById('admin-menu');
    const targetInput = document.getElementById('target-id');

    window.addEventListener('message', (event) => {
        const data = event.data;

        if (data.action === 'open') {
            menu.classList.remove('hidden');
        } else if (data.action === 'close') {
            menu.classList.add('hidden');
        }
    });

    document.getElementById('close-menu').addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    });

    document.querySelectorAll('button[data-action]').forEach((button) => {
        button.addEventListener('click', () => {
            const action = button.dataset.action;
            const value = button.dataset.value === 'true';
            const target = targetInput.value;

            fetch(`https://${GetParentResourceName()}/action`, {
                method: 'POST',
                body: JSON.stringify({ action, target, value })
            });
        });
    });
});