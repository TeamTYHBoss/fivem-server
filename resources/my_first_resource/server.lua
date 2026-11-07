local welcomeMessage = 'Welcome to the server!'

RegisterNetEvent('playerSpawned')
AddEventHandler('playerSpawned', function()
    local src = source
    TriggerClientEvent('my_first_resource:clientWelcome', src, welcomeMessage)
end)
