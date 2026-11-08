document.addEventListener('DOMContentLoaded', () => {
    const dashboard = document.getElementById('report-dashboard');
    const reportList = document.getElementById('report-list');
    const pageLabel = document.getElementById('page-label');
    const openCount = document.getElementById('open-count');
    let currentPage = 1;
    let totalPages = 1;

    window.addEventListener('message', (event) => {
        const data = event.data;

        if (data.action === 'open') {
            dashboard.classList.remove('hidden');
        } else if (data.action === 'close') {
            dashboard.classList.add('hidden');
        } else if (data.action === 'refresh') {
            currentPage = data.page;
            totalPages = data.totalPages;
            openCount.textContent = `${data.openCount} open`;
            pageLabel.textContent = `Page ${currentPage}/${totalPages}`;
            renderReports(data.reports);
        } else if (data.action === 'newReport') {
            const audio = new Audio('report_alert.ogg');
            audio.volume = 0.8;
            audio.play().catch(() => {});
        }
    });

    function renderReports(reports) {
        reportList.innerHTML = '';

        if (!reports || reports.length === 0) {
            reportList.innerHTML = '<div class="report-card">No open reports.</div>';
            return;
        }

        reports.forEach((report) => {
            const card = document.createElement('div');
            card.className = 'report-card';

            card.innerHTML = `
                <div class="report-title">#${report.id} - ${report.title}</div>
                <div class="report-meta">${report.report_type} | Reporter: ${report.reporter_citizenid} | Target: ${report.target_citizenid || 'None'} | ${report.status}</div>
                <div class="report-description">${report.description}</div>
                <div class="report-actions">
                    <button class="claim" data-action="claim" data-id="${report.id}">Claim</button>
                    <button class="goto" data-action="goto" data-id="${report.id}">Go To</button>
                    <button class="close" data-action="close" data-id="${report.id}">Close</button>
                </div>
            `;

            reportList.appendChild(card);
        });

        reportList.querySelectorAll('button[data-action]').forEach((button) => {
            button.addEventListener('click', () => {
                const note = button.dataset.action === 'close' ? prompt('Resolution note:') || '' : '';

                fetch(`https://${GetParentResourceName()}/action`, {
                    method: 'POST',
                    body: JSON.stringify({
                        action: button.dataset.action,
                        reportId: button.dataset.id,
                        note
                    })
                }).then(() => refresh());
            });
        });
    }

    function refresh() {
        fetch(`https://${GetParentResourceName()}/refresh`, {
            method: 'POST',
            body: JSON.stringify({ page: currentPage })
        });
    }

    document.getElementById('refresh-dashboard').addEventListener('click', refresh);

    document.getElementById('previous-page').addEventListener('click', () => {
        if (currentPage > 1) {
            currentPage--;
            refresh();
        }
    });

    document.getElementById('next-page').addEventListener('click', () => {
        if (currentPage < totalPages) {
            currentPage++;
            refresh();
        }
    });

    document.getElementById('close-dashboard').addEventListener('click', () => {
        fetch(`https://${GetParentResourceName()}/close`, {
            method: 'POST',
            body: JSON.stringify({})
        });
    });
});