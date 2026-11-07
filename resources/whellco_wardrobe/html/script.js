const wardrobe = document.getElementById('wardrobe');
const confirmButton = document.getElementById('confirm-button');
const modelButtons = document.querySelectorAll('.model-buttons button');

const sliders = [
    'face-shape',
    'skin-tone',
    'hair-style',
    'hair-colour',
    'torso',
    'undershirt',
    'legs',
    'shoes'
];

let selectedModel = 'male';

function post(callbackName, data) {
    return fetch(`https://${GetParentResourceName()}/${callbackName}`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json; charset=UTF-8'
        },
        body: JSON.stringify(data || {})
    });
}

function currentAppearance() {
    const appearance = {
        model: selectedModel,
        faceShape: Number(document.getElementById('face-shape').value),
        skinTone: Number(document.getElementById('skin-tone').value),
        hairStyle: Number(document.getElementById('hair-style').value),
        hairColour: Number(document.getElementById('hair-colour').value),
        torso: Number(document.getElementById('torso').value),
        undershirt: Number(document.getElementById('undershirt').value),
        legs: Number(document.getElementById('legs').value),
        shoes: Number(document.getElementById('shoes').value)
    };

    return appearance;
}

modelButtons.forEach(function(button) {
    button.addEventListener('click', function() {
        modelButtons.forEach(function(item) {
            item.classList.remove('active');
        });

        button.classList.add('active');
        selectedModel = button.dataset.model;

        post('changeModel', { model: selectedModel });
        post('updateAppearance', currentAppearance());
    });
});

sliders.forEach(function(id) {
    document.getElementById(id).addEventListener('input', function() {
        post('updateAppearance', currentAppearance());
    });
});

confirmButton.addEventListener('click', function() {
    post('confirm', currentAppearance());
});

window.addEventListener('message', function(event) {
    const data = event.data;

    if (!data) {
        return;
    }

    if (data.action === 'open') {
        wardrobe.classList.add('visible');
    }

    if (data.action === 'close') {
        wardrobe.classList.remove('visible');
    }
});
