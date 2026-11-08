@echo off

set "BACKUP_FILE=%~1"

if "%BACKUP_FILE%"=="" (
    echo Usage: restore.bat backups\database-YYYYMMDD-HHMMSS.sql
    exit /b 1
)

if not exist "%BACKUP_FILE%" (
    echo Backup file not found: %BACKUP_FILE%
    exit /b 1
)

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

set "DB_NAME=%DATABASE_URL:*/*=%"
set "DB_NAME=%DB_NAME:?=&%"

for /f "tokens=1 delims=&" %%A in ("%DB_NAME%") do set "DB_NAME=%%A"

echo Restoring %BACKUP_FILE% into database %DB_NAME%.
echo This will overwrite existing data.
set /p CONFIRM=Type RESTORE to continue: 

if /i not "%CONFIRM%"=="RESTORE" (
    echo Restore cancelled.
    exit /b 1
)

echo Note: Windows restore requires mysql.exe to be installed and available in PATH.
mysql "%DB_NAME%" < "%BACKUP_FILE%"

echo Restore complete.
