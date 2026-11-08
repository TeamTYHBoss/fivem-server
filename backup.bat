@echo off

if not exist .env (
    echo Missing .env file. Copy .env.example to .env and fill in the values.
    exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
    if "%%A"=="DATABASE_URL" set "DATABASE_URL=%%B"
)

if not defined DATABASE_URL (
    echo Missing DATABASE_URL in .env.
    exit /b 1
)

if not exist backups mkdir backups

for /f "tokens=1-5 delims=/: " %%a in ("%date% %time%") do set "TIMESTAMP=%%c%%a%%b-%%d%%e"

set "DB_NAME=%DATABASE_URL:*/*=%"
set "DB_NAME=%DB_NAME:?=&%"

for /f "tokens=1 delims=&" %%A in ("%DB_NAME%") do set "DB_NAME=%%A"

echo Database backup would be created for: %DB_NAME%
echo File backup would be created in: backups

echo Note: Windows batch backup requires mysqldump and tar to be installed and available in PATH.
