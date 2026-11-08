Config = {}

Config.Debug = false

Config.ReportCommand = 'report'
Config.ReportCooldownSeconds = 60
Config.MaxTitleLength = 100
Config.MaxDescriptionLength = 2000

Config.ReportTypes = {
    cheating = 'Cheating or Exploiting',
    harassment = 'Harassment or Toxic Behaviour',
    bug = 'Bug or Technical Issue',
    griefing = 'Griefing or Disruptive Behaviour',
    other = 'Other Staff Assistance'
}

Config.StaffJobs = {
    admin = true,
    manager = true
}

-- Store the Discord webhook in server.cfg using:
-- set whellco_report_webhook "https://discord.com/api/webhooks/..."
Config.WebhookURL = GetConvar('whellco_report_webhook', '')
Config.WebhookName = 'Player Reports'