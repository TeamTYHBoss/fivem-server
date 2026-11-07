Config = {}

Config.SecurityRules = {
    inputValidation = 'Validate all user input on the server.',
    permissionChecks = 'Check permissions before allowing actions.',
    rateLimiting = 'Limit repeated requests to prevent abuse.',
    logging = 'Log security-relevant actions for review.'
}

Config.RateLimits = {
    default = {
        maxRequests = 10,
        windowMs = 60000
    }
}

Config.SecurityPanel = {
    coords = vector3(-1200.0, -400.0, 35.0)
}
