local QBCore = exports['qb-core']:GetCoreObject()

local activeExams = {}
local examCooldowns = {}

local function isNear(coords, center)
    return #(coords - center.location) <= center.radius
end

local function hasPassedExam(Player, examType)
    local count = MySQL.scalar.await(
        [[
            SELECT COUNT(*)
            FROM whellco_driver_exams
            WHERE citizenid = ?
              AND exam_type = ?
              AND passed = 1
        ]],
        { Player.PlayerData.citizenid, examType }
    )

    return count and count > 0
end

RegisterNetEvent('whellco_driver_exam:start', function(examType)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local exam = Config.Exams[examType]

    if not Player or not exam then
        TriggerClientEvent('QBCore:Notify', source, 'Exam type not found.', 'error')
        return
    end

    local playerPed = GetPlayerPed(source)
    local coords = GetEntityCoords(playerPed)

    if not isNear(coords, Config.ExamCenter) then
        TriggerClientEvent('QBCore:Notify', source, 'You are not at the DMV exam center.', 'error')
        return
    end

    if hasPassedExam(Player, examType) then
        TriggerClientEvent('QBCore:Notify', source, 'You have already passed this exam.', 'error')
        return
    end

    local now = os.time()

    if now - (examCooldowns[source] or 0) < Config.ExamCooldownMinutes * 60 then
        TriggerClientEvent('QBCore:Notify', source, 'Please wait before taking another exam.', 'error')
        return
    end

    if Player.Functions.GetMoney('cash') < exam.price then
        TriggerClientEvent('QBCore:Notify', source, 'Not enough cash.', 'error')
        return
    end

    Player.Functions.RemoveMoney('cash', exam.price, ('Driver exam: %s'):format(examType))

    activeExams[source] = {
        examType = examType,
        startedAt = now
    }

    TriggerClientEvent('whellco_driver_exam:start', source, {
        examType = examType,
        label = exam.label,
        questions = exam.questions,
        passMark = Config.PassMark
    })
end)

RegisterNetEvent('whellco_driver_exam:submit', function(examType, answers)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local exam = Config.Exams[examType]
    local active = activeExams[source]

    if not Player or not exam or not active or active.examType ~= examType then
        return
    end

    if type(answers) ~= 'table' then
        return
    end

    local correct = 0

    for index, question in ipairs(exam.questions) do
        if answers[index] == question.answer then
            correct = correct + 1
        end
    end

    local total = #exam.questions
    local score = math.floor((correct / total) * 100)
    local passed = score >= Config.PassMark

    activeExams[source] = nil
    examCooldowns[source] = os.time()

    MySQL.query.await(
        [[
            INSERT INTO whellco_driver_exams
                (citizenid, exam_type, score, passed)
            VALUES (?, ?, ?, ?)
        ]],
        { Player.PlayerData.citizenid, examType, score, passed and 1 or 0 }
    )

    TriggerClientEvent('whellco_driver_exam:result', source, {
        examType = examType,
        score = score,
        passed = passed
    })

    if passed then
        TriggerClientEvent('QBCore:Notify', source, ('Passed %s with %d%%.'):format(exam.label, score), 'success')
    else
        TriggerClientEvent('QBCore:Notify', source, ('Failed %s with %d%%.'):format(exam.label, score), 'error')
    end
end)

RegisterCommand('exams', function(source)
    local Player = QBCore.Functions.GetPlayer(source)

    if not Player then
        return
    end

    local names = {}

    for examType, exam in pairs(Config.Exams) do
        names[#names + 1] = ('%s - %s ($%d)'):format(examType, exam.label, exam.price)
    end

    TriggerClientEvent('QBCore:Notify', source, table.concat(names, ', '), 'primary')
end, false)

RegisterCommand('takeexam', function(source, args)
    local examType = args[1]

    if not examType then
        TriggerClientEvent('QBCore:Notify', source, 'Usage: /takeexam [exam_type]', 'error')
        return
    end

    TriggerEvent('whellco_driver_exam:start', examType)
end, false)