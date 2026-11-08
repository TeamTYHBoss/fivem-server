document.addEventListener('DOMContentLoaded', () => {
    const menu = document.getElementById('report-menu');

    window.addEventListener('message', (event) => {
        const data = event.data;

        if (data.action === 'open') {
            menu.classList.remove('hidden');
        } else if (data.action === 'close') {
            menu.classList.add('hidden');
        }
    });

    document.getElementById('close-report').addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    });

    document.getElementById('submit-report').addEventListener('click', () => {
        const payload = {
            reportType: document.getElementById('report-type').value,
            targetSource: document.getElementById('target-source').value,
            title: document.getElementById('report-title').value,
            description: document.getElementById('report-description').value
        };

        fetch(`https://${GetParentResourceName()}/submit`, {
            method: 'POST',
            body: JSON.stringify(payload)
        });

        menu.classList.add('hidden');
    });
});