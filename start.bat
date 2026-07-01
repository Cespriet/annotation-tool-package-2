@echo off
setlocal
echo === Starting Annotation Enhanced App Setup ===

:: Check Python
set "PYTHON_CMD="

python --version >nul 2>&1
if %errorlevel% equ 0 set "PYTHON_CMD=python" & goto :python_found

py --version >nul 2>&1
if %errorlevel% equ 0 set "PYTHON_CMD=py" & goto :python_found

python3 --version >nul 2>&1
if %errorlevel% equ 0 set "PYTHON_CMD=python3" & goto :python_found

:python_found
if not defined PYTHON_CMD (
    echo Error: Python is not installed. Please install Python 3.
    pause
    exit /b 1
)

:: Check Ollama
ollama --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Error: ollama is not installed. Please install Ollama from https://ollama.com/.
    pause
    exit /b 1
)

:: Check and pull model
echo Checking for Qwen2.5-7B model...
ollama list | findstr "qwen2.5:7b-instruct" >nul
if %errorlevel% neq 0 (
    echo Model not found. Downloading qwen2.5:7b-instruct (this will take a while)...
    ollama pull qwen2.5:7b-instruct
    if %errorlevel% neq 0 (
        echo Error: Failed to download model. Please ensure Ollama is running.
        pause
        exit /b 1
    )
)

:: Create virtual env
if not exist venv (
    echo Creating Python virtual environment (venv)...
    %PYTHON_CMD% -m venv venv
    if %errorlevel% neq 0 (
        echo Error: Failed to create venv.
        pause
        exit /b 1
    )
)

:: Activate virtual env
echo Activating virtual environment...
call venv\Scripts\activate

:: Install requirements
echo Installing/upgrading dependencies...
python -m pip install --upgrade pip
pip install -r requirements.txt
if %errorlevel% neq 0 (
    echo Error: Failed to install requirements.
    pause
    exit /b 1
)

echo ✓ Environment setup complete!
echo Launching Flask application...

:: Open browser
start http://127.0.0.1:5000

python app.py
pause
endlocal
