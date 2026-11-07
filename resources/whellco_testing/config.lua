Config = {}

Config.TestSuites = {
    unit = {
        label = 'Unit Tests',
        tests = {
            'validate_input',
            'calculate_payout',
            'format_currency'
        }
    },
    integration = {
        label = 'Integration Tests',
        tests = {
            'banking_flow',
            'job_flow',
            'property_flow'
        }
    }
}

Config.TestingPanel = {
    coords = vector3(-1400.0, -500.0, 35.0)
}
