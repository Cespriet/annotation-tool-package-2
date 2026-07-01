# Startup script for the Annotation Enhanced Web App in PowerShell

Write-Host "=== Starting Annotation Enhanced App Setup ===" -ForegroundColor Cyan

# 1. Detect Python command
$PythonCmd = $null
if (Get-Command "python" -ErrorAction SilentlyContinue) {
    # Verify it is not the Windows store stub
    $null = & python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $PythonCmd = "python"
    }
}

if (-not $PythonCmd -and (Get-Command "py" -ErrorAction SilentlyContinue)) {
    $null = & py --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $PythonCmd = "py"
    }
}

if (-not $PythonCmd -and (Get-Command "python3" -ErrorAction SilentlyContinue)) {
    $null = & python3 --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        $PythonCmd = "python3"
    }
}

if (-not $PythonCmd) {
    Write-Host "Error: Python is not installed. Please install Python 3 before running this script." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "Using Python command: $PythonCmd" -ForegroundColor Green

# 2. Check Ollama
if (-not (Get-Command "ollama" -ErrorAction SilentlyContinue)) {
    Write-Host "Error: ollama is not installed. Please install Ollama from https://ollama.com/ before running this script." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

# 3. Check and pull model
Write-Host "Checking for Qwen2.5-7B model..." -ForegroundColor Cyan
$models = ollama list
if ($models -notmatch "qwen2.5:7b-instruct") {
    Write-Host "Model not found. Downloading qwen2.5:7b-instruct (this will take a while)..." -ForegroundColor Yellow
    ollama pull qwen2.5:7b-instruct
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to download model. Please ensure Ollama is running." -ForegroundColor Red
        Read-Host "Press Enter to continue..."
        exit 1
    }
}

# 4. Create virtual env if not exists
if (-not (Test-Path "venv")) {
    Write-Host "Creating Python virtual environment (venv)..." -ForegroundColor Cyan
    & $PythonCmd -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to create venv." -ForegroundColor Red
        Read-Host "Press Enter to continue..."
        exit 1
    }
}

# 5. Activate virtual env
Write-Host "Activating virtual environment..." -ForegroundColor Cyan
. venv\Scripts\Activate.ps1

# 6. Install requirements
Write-Host "Installing/upgrading dependencies..." -ForegroundColor Cyan
python -m pip install --upgrade pip
pip install -r requirements.txt
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to install requirements." -ForegroundColor Red
    Read-Host "Press Enter to continue..."
    exit 1
}

Write-Host "Environment setup complete!" -ForegroundColor Green
Write-Host "Launching Flask application..." -ForegroundColor Cyan

# 7. Open browser automatically in background
Start-Job -ScriptBlock {
    Start-Sleep -Seconds 2
    Start-Process "http://127.0.0.1:5000"
} | Out-Null

python app.py
Read-Host "Press Enter to continue..."
