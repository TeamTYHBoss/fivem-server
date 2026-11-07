# Setup Guide

## Requirements

- FiveM server
- MySQL or MariaDB
- oxmysql

## Database

1. Create a MySQL database.
2. Create a database user with access to that database.
3. Run the SQL files in each resource's `sql` folder.
4. Update `server.cfg` with your database connection string.

Example:

```cfg
set mysql_connection_string "mysql://username:password@localhost/database?charset=utf8mb4"
```

## Server configuration

1. Open `server.cfg`.
2. Replace `CHANGE_ME` with your FiveM license key.
3. Replace `REPLACE_WITH_YOUR_LICENSE` with your own FiveM license identifier.
4. Start the server.

## Resource load order

The recommended load order is:

1. `oxmysql`
2. `whellco_server_info`
3. `whellco_loadscreen`
4. `whellco_characters`
5. `whellco_spawn_selector`
6. `whellco_wardrobe`
7. `whellco_housing`
8. `whellco_economy`
9. `whellco_immersion`
10. `whellco_vehicles`
11. `whellco_phone`
12. `whellco_jobcenter`
13. `whellco_police`
14. `whellco_medical`
15. `whellco_mechanic`
16. `whellco_realestate`
17. `whellco_banking`
18. `whellco_admin`
19. `whellco_discord`
20. `whellco_economy_hub`
21. `whellco_performance`
22. `whellco_security`
23. `whellco_testing`
24. `my_first_resource`

## Testing

1. Start the server.
2. Join the server.
3. Create a character.
4. Test the spawn selector.
5. Test the wardrobe.
6. Test the housing system.
7. Test the economy system.
8. Test the phone system.
9. Test the job center.
10. Test the police system.
11. Test the medical system.
12. Test the mechanic system.
13. Test the real-estate system.
14. Test the banking system.
15. Test the admin system.
16. Test the Discord integration.
17. Test the performance system.
18. Test the security system.
19. Test the testing system.
20. Test the documentation system.
