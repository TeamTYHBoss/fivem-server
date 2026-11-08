document.addEventListener('DOMContentLoaded', () => {
    const menu = document.getElementById('admin-menu');
    const targetInput = document.getElementById('target-id');
    const reasonInput = document.getElementById('action-reason');
    const tempBanHours = document.getElementById('tempban-hours');

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
            let value = reasonInput.value;

            if (action === 'godmode' || action === 'invisibility' || action === 'noclip' || action === 'freeze') {
                value = button.dataset.value === 'true';
            } elseif (action === 'tempban') {
                value = reasonInput.value;
                Config = { TempBanHours: parseInt(tempBanHours.value || '24', 10) };
            }

            fetch(`https://${GetParentResourceName()}/action`, {
                method: 'POST',
                body: JSON.stringify({ action, target: targetInput.value, value })
            });
        });
    });
});