const reportMenu = document.getElementById('auction-reports');
const reportList = document.getElementById('report-list');
const auctionInput = document.getElementById('auction-input');
const reasonSelect = document.getElementById('reason-select');
const detailsInput = document.getElementById('details-input');
const submitButton = document.getElementById('submit-button');
const closeButton = document.getElementById('close-button');

let currentReports = [];
let currentReasons = [];

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

function renderReasons() {
    reasonSelect.innerHTML = '';

    currentReasons.forEach(function(reason) {
        const option = document.createElement('option');
        option.value = reason;
        option.textContent = reason;
        reasonSelect.appendChild(option);
    });
}

function renderReports() {
    reportList.innerHTML = '';

    currentReports.forEach(function(report) {
        const row = document.createElement('div');
        row.className = 'report-item';
        row.textContent = `Auction ${report.auction_id} — ${report.reason} — ${report.status}`;

        reportList.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentReports = data.reports || [];
        currentReasons = data.reasons || [];

        renderReasons();
        renderReports();

        reportMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        reportMenu.classList.remove('visible');
    }
});

submitButton.addEventListener('click', function() {
    post('submitReport', {
        auctionId: auctionInput.value,
        reason: reasonSelect.value,
        details: detailsInput.value
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
