Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.PoliceJob = 'police'
Config.MaxFineAmount = 10000
Config.TicketCooldownSeconds = 10

Config.Fines = {
    speeding = {
        label = 'Speeding',
        amount = 500,
        points = 2
    },
    reckless = {
        label = 'Reckless Driving',
        amount = 1500,
        points = 4
    },
    red_light = {
        label = 'Running a Red Light',
        amount = 750,
        points = 3
    },
    no_license = {
        label = 'Driving Without a License',
        amount = 1000,
        points = 3
    },
    hit_and_run = {
        label = 'Hit and Run',
        amount = 5000,
        points = 6
    },
    dui = {
        label = 'Driving Under the Influence',
        amount = 3000,
        points = 5
    }
}