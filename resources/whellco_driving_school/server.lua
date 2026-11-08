local QBCore = exports['qb-core']:GetCoreObject()

local activeLessons = {}
local lessonCooldowns = {}

local function isInstructor(Player)
    local job = Player.PlayerData.job

    return job and job.name == Config.InstructorJob
end

local function isNear(coords, center)
    return #(coords - center.location) <= center.radius
end

RegisterNetEvent('whellco_driving_school:startLesson', function(lessonType, targetSource)
    local source = source
    local Instructor = QBCore.Functions.GetPlayer(source)
    local Student = QBCore.Functions.GetPlayer(tonumber(targetSource) or 0)
    local lesson = Config.LessonTypes[lessonType]

    if not Instructor or not Student or not lesson then
        TriggerClientEvent('QBCore:Notify', source, 'Invalid lesson or student.', 'error')
        return
    end

    if not isInstructor(Instructor) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not a driving instructor.', 'error')
        return
    end

    local now = os.time()

    if now - (lessonCooldowns[source] or 0) < Config.LessonCooldownMinutes * 60 then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before starting another lesson.', 'error')
        return
    end

    if activeLessons[Student.PlayerData.source] then
        TriggerClientEvent('QBCore:Notify', source, 'This student is already in a lesson.', 'error')
        return
    end

    if Student.Functions.GetMoney('cash') < lesson.price then
        TriggerClientEvent('QBCore:Notify', source, 'Student does not have enough cash.', 'error')
        return
    end

    Student.Functions.RemoveMoney('cash', lesson.price, ('Driving lesson: %s'):format(lessonType))
    Instructor.Functions.AddMoney('bank', math.floor(lesson.price * 0.7), ('Driving lesson payment: %s'):format(lessonType))

    activeLessons[Student.PlayerData.source] = {
        instructorSource = source,
        lessonType = lessonType,
        startedAt = now,
        endsAt = now + lesson.duration
    }

    lessonCooldowns[source] = now

    TriggerClientEvent('whellco_driving_school:lessonStarted', Student.PlayerData.source, {
        lessonType = lessonType,
        label = lesson.label,
        vehicle = Config.LessonVehicle,
        spawn = Config.School.vehicleSpawn,
        checkpoints = Config.Checkpoints,
        duration = lesson.duration
    })

    TriggerClientEvent('whellco_driving_school:lessonStarted', source, {
        studentSource = Student.PlayerData.source,
        lessonType = lessonType,
        label = lesson.label
    })
end)

RegisterNetEvent('whellco_driving_school:completeLesson', function()
    local source = source
    local lesson = activeLessons[source]

    if not lesson then
        return
    end

    local Student = QBCore.Functions.GetPlayer(source)
    local Instructor = QBCore.Functions.GetPlayer(lesson.instructorSource)

    activeLessons[source] = nil

    if Student then
        Student.Functions.AddMoney('bank', 0, 'Driving lesson completed')
        TriggerClientEvent('whellco_driving_school:lessonCompleted', source, {
            lessonType = lesson.lessonType,
            passed = true
        })
    end

    if Instructor then
        TriggerClientEvent('whellco_driving_school:lessonCompleted', Instructor.PlayerData.source, {
            studentSource = source,
            lessonType = lesson.lessonType,
            passed = true
        })
    end
end)

RegisterCommand('startlesson', function(source, args)
    local lessonType = args[1]
    local targetSource = args[2]

    if not lessonType or not targetSource then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /startlesson [lesson_type] [player_id]', 'error')
        return
    end

    TriggerEvent('whellco_driving_school:startLesson', lessonType, targetSource)
end, false)

RegisterCommand('completelesson', function()
    TriggerEvent('whellco_driving_school:completeLesson')
end, false)

RegisterCommand('lessoninfo', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for lessonType, lesson in pairs(Config.LessonTypes) do
        names[#names + 1] = ('%s - %s ($%d)'):format(lessonType, lesson.label, lesson.price)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)