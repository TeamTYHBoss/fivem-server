const casino = document.getElementById('casino');
const membershipLabel = document.getElementById('membership-label');
const cashLabel = document.getElementById('cash-label');
const slotBet = document.getElementById('slot-bet');
const slotResult = document.getElementById('slot-result');
const wheelCost = document.getElementById('wheel-cost');
const wheelResult = document.getElementById('wheel-result');
const membershipList = document.getElementById('membership-list');
const penthouseOptions = document.getElementById('penthouse-options');
const garageList = document.getElementById('garage-list');

let casinoData = null;

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

function formatMoney(amount) {
    return `£${Number(amount || 0).toLocaleString()}`;
}

function renderCasino() {
    if (!casinoData) {
        return;
    }

    membershipLabel.textContent = casinoData.membership.label;
    cashLabel.textContent = `Cash: ${formatMoney(casinoData.cash)} | Bank: ${formatMoney(casinoData.bank)}`;

    slotBet.innerHTML = '';

    casinoData.slotBetOptions.forEach(function(bet) {
        const option = document.createElement('option');
        option.value = bet;
        option.textContent = formatMoney(bet);
        slotBet.appendChild(option);
    });

    wheelCost.textContent = `Wheel spin cost: ${formatMoney(casinoData.wheelSpinCost)}`;

    membershipList.innerHTML = '';

    Object.keys(casinoData.memberships).forEach(function(tier) {
        const membership = casinoData.memberships[tier];
        const card = document.createElement('div');
        card.className = 'card';

        card.innerHTML = `
            <strong>${membership.label}</strong>
            <p>Price: ${formatMoney(membership.price)}</p>
            <p>Win-rate multiplier: ${membership.winRateMultiplier}x</p>
            <p>Casino discount: ${Math.round(membership.discount * 100)}%</p>
            <p>Included garage spaces: ${membership.garageSpaces}</p>
        `;

        if (tier !== 'free' && casinoData.membership.tier !== tier) {
            const button = document.createElement('button');
            button.textContent = 'Purchase';

            button.addEventListener('click', function() {
                post('purchaseMembership', { tier: tier });
            });

            card.appendChild(button);
        }

        membershipList.appendChild(card);
    });

    penthouseOptions.innerHTML = '';

    Object.keys(casinoData.penthouseOptions).forEach(function(optionType) {
        const group = casinoData.penthouseOptions[optionType];
        const card = document.createElement('div');
        card.className = 'card';
        card.innerHTML = `<strong>${group.label}</strong>`;

        Object.keys(group.options).forEach(function(optionId) {
            const option = group.options[optionId];
            const button = document.createElement('button');
            button.textContent = `${option.label} — ${formatMoney(option.price)}`;

            button.addEventListener('click', function() {
                post('customisePenthouse', {
                    optionType: optionType,
                    optionId: optionId
                });
            });

            card.appendChild(button);
        });

        penthouseOptions.appendChild(card);
    });

    garageList.innerHTML = '';

    Object.keys(casinoData.garageSpaces).forEach(function(spaceType) {
        const space = casinoData.garageSpaces[spaceType];
        const card = document.createElement('div');
        card.className = 'card';
        card.innerHTML = `
            <strong>${space.label}</strong>
            <p>Price: ${formatMoney(space.price)}</p>
            <p>Vehicle limit: ${space.vehicleLimit}</p>
        `;

        const button = document.createElement('button');
        button.textContent = 'Purchase Space';

        button.addEventListener('click', function() {
            post('purchaseGarageSpace', { spaceType: spaceType });
        });

        card.appendChild(button);
        garageList.appendChild(card);
    });
}

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        casinoData = data.data;
        renderCasino();
        casino.classList.add('visible');
    }

    if (data.action === 'close') {
        casino.classList.remove('visible');
    }

    if (data.action === 'slotResult') {
        document.getElementById('reel-1').textContent = data.reels[0];
        document.getElementById('reel-2').textContent = data.reels[1];
        document.getElementById('reel-3').textContent = data.reels[2];

        slotResult.textContent = data.payout > 0
            ? `${data.result} — Payout: ${formatMoney(data.payout)}`
            : data.result;
    }

    if (data.action === 'wheelResult') {
        wheelResult.textContent = `${data.label} — Payout: ${formatMoney(data.amount)}`;
    }
});

document.querySelectorAll('.tab').forEach(function(tab) {
    tab.addEventListener('click', function() {
        document.querySelectorAll('.tab').forEach(function(item) {
            item.classList.remove('active');
        });

        document.querySelectorAll('.panel').forEach(function(panel) {
            panel.classList.remove('active');
        });

        tab.classList.add('active');
        document.getElementById(tab.dataset.tab).classList.add('active');
    });
});

document.getElementById('spin-slots').addEventListener('click', function() {
    post('spinSlots', { bet: Number(slotBet.value) });
});

document.getElementById('spin-wheel').addEventListener('click', function() {
    post('spinWheel');
});

document.getElementById('buy-penthouse').addEventListener('click', function() {
    post('purchasePenthouse');
});

document.getElementById('close-button').addEventListener('click', function() {
    post('closeMenu');
});

document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        post('closeMenu');
    }
});
