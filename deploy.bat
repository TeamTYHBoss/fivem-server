@echo off

if not exist .env (
    echo Missing .env file. Copy .env.example to .env and fill in the values.
    exit /b 1
)

for /f "usebackq tokens=1,* delims==" %%A in (".env") do (
    if "%%A"=="DATABASE_URL" set "DATABASE_URL=%%B"
    if "%%A"=="FIVEM_LICENSE_KEY" set "FIVEM_LICENSE_KEY=%%B"
)

if not defined DATABASE_URL (
    echo Missing DATABASE_URL in .env.
    exit /b 1
)

if not defined FIVEM_LICENSE_KEY (
    echo Missing FIVEM_LICENSE_KEY in .env.
    exit /b 1
)

echo Deployment checks passed.
echo Start the FiveM server with run.bat or use your server control panel.
