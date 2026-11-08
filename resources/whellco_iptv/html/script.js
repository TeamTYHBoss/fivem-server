let channels = [];
let currentChannel = 1;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'open') {
        channels = data.channels || [];
        currentChannel = data.currentChannel || 1;
        document.getElementById('tv-container').style.display = 'block';
        renderChannelList();
        setChannel(currentChannel);
    }

    if (data.action === 'close') {
        document.getElementById('tv-container').style.display = 'none';
        document.getElementById('tv-video').pause();
    }

    if (data.action === 'setChannel') {
        setChannel(data.channel);
    }
});

function renderChannelList() {
    const list = document.getElementById('channel-items');
    list.innerHTML = '';

    channels.forEach(function(channel, index) {
        const item = document.createElement('li');
        item.textContent = channel.name || ('Channel ' + (index + 1));
        item.dataset.index = index + 1;

        if (index + 1 === currentChannel) {
            item.classList.add('active');
        }

        item.addEventListener('click', function() {
            currentChannel = index + 1;
            setChannel(channel);
            renderChannelList();
        });

        list.appendChild(item);
    });
}

function setChannel(channel) {
    if (!channel) {
        return;
    }

    const video = document.getElementById('tv-video');
    const name = document.getElementById('channel-name');

    video.src = channel.url;
    video.play();
    name.textContent = channel.name || 'Unknown channel';
}

document.getElementById('next-channel').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/nextChannel`, {
        method: 'POST'
    });
});

document.getElementById('previous-channel').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/previousChannel`, {
        method: 'POST'
    });
});

document.getElementById('close-tv').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/close`, {
        method: 'POST'
    });
});