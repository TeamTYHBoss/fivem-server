let channels = [];
let currentChannel = 1;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.action === 'open') {
        channels = data.channels || [];
        currentChannel = data.currentChannel || 1;
        document.getElementById('tv-container').style.display = 'block';
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