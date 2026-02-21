@echo off
setlocal enabledelayedexpansion

REM Quick connection test for Windows

echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║  AI Service Connection Quick Test                      ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM Test 1: AI Service
echo [1/4] Testing AI Service...
curl -s http://localhost:8000/api/v1/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] AI Service is running on port 8000
) else (
    echo [ERROR] AI Service is NOT running
    echo        Start it with: cd ai_meal_planing_service ^&^& uvicorn app.main:app --reload --port 8000
    set "FAILURE=1"
)

REM Test 2: Backend
echo [2/4] Testing Backend...
curl -s http://localhost:3000/api/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Backend is running on port 3000
) else (
    echo [ERROR] Backend is NOT running
    echo        Start it with: cd eater-backend ^&^& npm run dev
    set "FAILURE=1"
)

REM Test 3: Backend to AI connection
echo [3/4] Testing Backend to AI Service connection...
curl -s http://localhost:3000/api/ai/health >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    echo [OK] Backend can connect to AI Service
) else (
    echo [ERROR] Backend cannot connect to AI Service
    set "FAILURE=1"
)

REM Test 4: Full test
echo [4/4] Running full test suite...
node test-ai-connection.js

if defined FAILURE (
    echo.
    echo ╔════════════════════════════════════════════════════════╗
    echo ║  Some tests failed                                     ║
    echo ╚════════════════════════════════════════════════════════╝
    echo.
    echo Please make sure both services are running:
    echo.
    echo Terminal 1: cd ai_meal_planing_service
    echo            uvicorn app.main:app --reload --port 8000
    echo.
    echo Terminal 2: cd eater-backend
    echo            npm run dev
    echo.
) else (
    echo.
    echo ╔════════════════════════════════════════════════════════╗
    echo ║  All tests passed! Connection is working!             ║
    echo ╚════════════════════════════════════════════════════════╝
    echo.
)

pause
