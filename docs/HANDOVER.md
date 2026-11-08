# Handover Guide

## Project overview

This FiveM server includes custom resources for characters, housing, economy, jobs, vehicles, phone, police, medical, mechanic, real estate, banking, admin, Discord, performance, security, testing, documentation, release, deployment, monitoring, backup, restore and final polish.

## Server requirements

- FiveM server
- MySQL or MariaDB
- oxmysql

## Setup checklist

1. Clone the repository.
2. Install the required resources.
3. Create a MySQL database.
4. Copy `.env.example` to `.env`.
5. Fill in `FIVEM_LICENSE_KEY` and `DATABASE_URL`.
6. Update `server.cfg` with your database connection string.
7. Run every SQL migration in each resource's `sql` folder.
8. Run `./deploy.sh` on Linux/macOS or `deploy.bat` on Windows.
9. Start the server.

## Final testing checklist

1. Create a character.
2. Select a spawn point.
3. Change clothing in the wardrobe.
4. Buy or rent a property.
5. Use the economy hub.
6. Use the phone.
7. Apply for and complete a job.
8. Use the police system.
9. Use the medical system.
10. Use the mechanic system.
11. Use the banking system.
12. Use the admin panel.
13. Link a Discord account.
14. Run performance checks.
15. Run security checks.
16. Run testing suites.
17. View documentation.
18. View release notes.
19. Run deployment checks.
20. Run monitoring checks.
21. Create a backup.
22. Restore a backup.
23. Run the final polish review.

## Important operational notes

- Keep `.env`, database credentials, and license keys private.
- Do not commit real credentials or API keys.
- Run database migrations before starting the server for the first time.
- Use the backup and restore scripts only from a trusted server host.
- Review admin permissions before granting access.
- Monitor server metrics and alerts regularly.
- Keep the changelog and documentation up to date after future changes.
