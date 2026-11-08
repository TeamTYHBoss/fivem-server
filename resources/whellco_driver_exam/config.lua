Config = {}

Config.Debug = false

Config.CurrencySymbol = '$'
Config.InteractionDistance = 3.0
Config.PassMark = 70
Config.ExamCooldownMinutes = 10

Config.ExamCenter = {
    label = 'DMV Exam Center',
    location = vector3(240.4, -1379.2, 33.7),
    radius = 10.0
}

Config.Exams = {
    car = {
        label = 'Car Theory Exam',
        price = 250,
        questions = {
            {
                question = 'What does a red traffic light mean?',
                options = { 'Stop', 'Go', 'Slow down', 'Reverse' },
                answer = 1
            },
            {
                question = 'What should you do at a stop sign?',
                options = { 'Slow down', 'Stop completely', 'Speed up', 'Ignore it' },
                answer = 2
            },
            {
                question = 'What does a yellow traffic light mean?',
                options = { 'Prepare to stop', 'Speed up', 'Reverse', 'Ignore it' },
                answer = 1
            },
            {
                question = 'What should you do before changing lanes?',
                options = { 'Check mirrors and signal', 'Close your eyes', 'Speed up', 'Honk only' },
                answer = 1
            },
            {
                question = 'What is the purpose of a seatbelt?',
                options = { 'Decoration', 'Safety', 'Speed boost', 'Fuel saving' },
                answer = 2
            }
        }
    },
    bike = {
        label = 'Bike Theory Exam',
        price = 150,
        questions = {
            {
                question = 'What should motorcyclists wear for safety?',
                options = { 'Helmet', 'Flip flops', 'No protection', 'Loose clothing only' },
                answer = 1
            },
            {
                question = 'What does a stop sign require?',
                options = { 'Slow down', 'Stop completely', 'Speed up', 'Ignore it' },
                answer = 2
            },
            {
                question = 'What should you do in wet conditions?',
                options = { 'Ride faster', 'Reduce speed', 'Close your eyes', 'Ignore traffic' },
                answer = 2
            }
        }
    }
}