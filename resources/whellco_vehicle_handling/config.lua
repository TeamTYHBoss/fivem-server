Config = {}

Config.Debug = false

Config.TuningCosts = {
    engine = 2500,
    brakes = 1500,
    transmission = 2000,
    suspension = 1200,
    turbo = 3500,
    tires = 800,
    armor = 4000
}

Config.PerformanceLevels = {
    engine = 5,
    brakes = 3,
    transmission = 4,
    suspension = 4,
    turbo = 4,
    tires = 5,
    armor = 5
}

Config.HandlingProfiles = {
    street = {
        label = 'Street',
        fInitialDriveForce = 0.24,
        fInitialDragCoeff = 8.5,
        fBrakeForce = 0.55,
        fBrakeBiasFront = 0.62,
        fTractionCurveMax = 2.35,
        fTractionCurveMin = 0.85,
        fTractionCurveLateral = 22.0,
        fSuspensionForce = 22.0,
        fSuspensionCompDamp = 1.15,
        fSuspensionReboundDamp = 1.55
    },
    sport = {
        label = 'Sport',
        fInitialDriveForce = 0.31,
        fInitialDragCoeff = 7.2,
        fBrakeForce = 0.68,
        fBrakeBiasFront = 0.60,
        fTractionCurveMax = 2.65,
        fTractionCurveMin = 0.95,
        fTractionCurveLateral = 24.0,
        fSuspensionForce = 26.0,
        fSuspensionCompDamp = 1.35,
        fSuspensionReboundDamp = 1.75
    },
    race = {
        label = 'Race',
        fInitialDriveForce = 0.38,
        fInitialDragCoeff = 6.0,
        fBrakeForce = 0.82,
        fBrakeBiasFront = 0.58,
        fTractionCurveMax = 2.95,
        fTractionCurveMin = 1.05,
        fTractionCurveLateral = 27.0,
        fSuspensionForce = 31.0,
        fSuspensionCompDamp = 1.55,
        fSuspensionReboundDamp = 2.05
    }
}

Config.AllowedJobs = {
    'mechanic'
}