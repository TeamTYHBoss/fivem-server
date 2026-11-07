local hasSpawned = false

RegisterNetEvent('my_first_resource:clientWelcome')
AddEventHandler('my_first_resource:clientWelcome', function(message)
    if not hasSpawned then
        hasSpawned = true
        BeginTextCommandThefeedPost('STRING')
        AddTextComponentSubstringPlayerName(message)
        EndTextCommandThefeedPostTicker(false, true)
    end
end)
