@echo off
REM Windows batch script to start both services

echo ============================================================
echo   Starting Eater App Services
echo ============================================================

REM Create logs directory
if not exist logs mkdir logs

REM Check if MongoDB is running
echo.
echo Checking MongoDB...
tasklist /FI "IMAGENAME eq mongod.exe" 2>NUL | find /I /N "mongod.exe">NUL
if "%ERRORLEVEL%"=="0" (
    echo [OK] MongoDB is running
) else (
    echo [ERROR] MongoDB is not running
    echo Please start MongoDB first
    exit /b 1
)

REM Start Python AI Service
echo.
echo Starting AI Meal Planning Service (Python)...
cd ai_meal_planing_service

if not exist venv (
    echo Creating virtual environment...
    python -m venv venv
)

call venv\Scripts\activate.bat

echo Installing dependencies...
pip install -q fastapi uvicorn pydantic python-dotenv

echo Starting AI service on port 8000...
start /B cmd /c "uvicorn app.main:app --reload --port 8000 > ..\logs\ai-service.log 2>&1"

cd ..

REM Wait for AI service to start
timeout /t 5 /nobreak >nul

REM Start Node.js Backend
echo.
echo Starting Node.js Backend...
cd eater-backend

if not exist node_modules (
    echo Installing npm packages...
    call npm install
)

echo Starting backend on port 3000...
start /B cmd /c "npm run dev > ..\logs\backend.log 2>&1"

cd ..

REM Wait for services to fully start
echo.
echo Waiting for services to start...
timeout /t 5 /nobreak >nul

REM Test connections
echo.
echo ============================================================
echo   Testing Service Connections
echo ============================================================
echo.
node test-ai-connection.js

echo.
echo ============================================================
echo   Services are running!
echo ============================================================
echo.
echo AI Service: http://localhost:8000
echo Backend:    http://localhost:3000
echo.
echo Logs:
echo   AI Service: logs\ai-service.log
echo   Backend:    logs\backend.log
echo.
echo Press Ctrl+C to stop services
echo.

pause
