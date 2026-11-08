local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('whellco_driver_exam:start', function(data)
    if not data or not data.questions then
        return
    end

    QBCore.Functions.Notify(
        ('Started %s. Answer %d question(s). Pass mark: %d%%.'):format(
            data.label,
            #data.questions,
            data.passMark
        ),
        'primary'
    )
end)

RegisterNetEvent('whellco_driver_exam:result', function(data)
    if not data then
        return
    end

    QBCore.Functions.Notify(
        ('%s result: %d%%. %s'):format(
            data.examType,
            data.score,
            data.passed and 'Passed.' or 'Failed.'
        ),
        data.passed and 'success' or 'error'
    )
end)

RegisterCommand('examinstructions', function()
    QBCore.Functions.Notify(
        'Use /takeexam car or /takeexam bike at the DMV. Answer questions and submit your answers.',
        'primary'
    )
end, false)