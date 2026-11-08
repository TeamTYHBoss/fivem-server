const insuranceMenu = document.getElementById('insurance');
const plansContainer = document.getElementById('plans');
const policiesContainer = document.getElementById('policies');
const claimsContainer = document.getElementById('claims');
const closeButton = document.getElementById('close-button');

let currentPlans = [];
let currentPolicies = [];
let currentClaims = [];

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

function renderPlans() {
    plansContainer.innerHTML = '';

    currentPlans.forEach(function(plan) {
        const row = document.createElement('div');
        row.className = 'plan';

        const info = document.createElement('div');
        info.className = 'plan-info';
        info.textContent = `${plan.label} — £${plan.monthlyPrice}/month — Limit £${plan.claimLimit} — Deductible £${plan.deductible}`;

        const buyButton = document.createElement('button');
        buyButton.textContent = 'Buy';

        buyButton.addEventListener('click', function() {
            post('buyPolicy', {
                vehicleId: 0,
                plan: plan.id
            });
        });

        row.appendChild(info);
        row.appendChild(buyButton);
        plansContainer.appendChild(row);
    });
}

function renderPolicies() {
    policiesContainer.innerHTML = '';

    currentPolicies.forEach(function(policy) {
        const row = document.createElement('div');
        row.className = 'policy';
        row.textContent = `Vehicle ${policy.vehicle_id} — ${policy.plan} — ${policy.active ? 'Active' : 'Cancelled'}`;

        policiesContainer.appendChild(row);
    });
}

function renderClaims() {
    claimsContainer.innerHTML = '';

    currentClaims.forEach(function(claim) {
        const row = document.createElement('div');
        row.className = 'claim';
        row.textContent = `Vehicle ${claim.vehicle_id} — £${claim.damage_amount} damage — £${claim.payout} payout — ${claim.status}`;

        claimsContainer.appendChild(row);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        currentPlans = data.plans || [];
        currentPolicies = data.policies || [];
        currentClaims = data.claims || [];

        renderPlans();
        renderPolicies();
        renderClaims();

        insuranceMenu.classList.add('visible');
    }

    if (data.action === 'close') {
        insuranceMenu.classList.remove('visible');
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
