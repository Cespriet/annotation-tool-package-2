#!/bin/bash
# Startup script for the Annotation Enhanced Web App

# Color formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting Annotation Enhanced App Setup ===${NC}"

# 1. Detect Python command
PYTHON_CMD=""
if command -v python3 &> /dev/null && python3 --version &> /dev/null; then
    PYTHON_CMD="python3"
elif command -v python &> /dev/null && python --version &> /dev/null; then
    PYTHON_CMD="python"
elif command -v py &> /dev/null && py --version &> /dev/null; then
    PYTHON_CMD="py"
fi

if [ -z "$PYTHON_CMD" ]; then
    echo -e "${RED}Error: Python is not installed. Please install Python 3 before running this script.${NC}"
    exit 1
fi

# 2. Check Ollama
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: ollama is not installed. Please install Ollama from https://ollama.com/ before running this script.${NC}"
    exit 1
fi

# 3. Check and pull model
echo -e "${BLUE}Checking for Qwen2.5-7B model...${NC}"
ollama list | grep -q "qwen2.5:7b-instruct"
if [ $? -ne 0 ]; then
    echo -e "${BLUE}Model not found. Downloading qwen2.5:7b-instruct (this will take a while)...${NC}"
    ollama pull qwen2.5:7b-instruct
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to download model. Please ensure Ollama is running.${NC}"
        exit 1
    fi
fi

# 4. Create virtual env if not exists
if [ ! -d "venv" ]; then
    echo -e "${BLUE}Creating Python virtual environment (venv)...${NC}"
    "$PYTHON_CMD" -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create venv.${NC}"
        exit 1
    fi
fi

# 5. Set virtual env paths dynamically based on platform
if [ -d "venv/Scripts" ]; then
    VENV_ACTIVATE="venv/Scripts/activate"
    VENV_PYTHON="venv/Scripts/python"
else
    VENV_ACTIVATE="venv/bin/activate"
    VENV_PYTHON="venv/bin/python"
fi

# 6. Activate virtual env
echo -e "${BLUE}Activating virtual environment...${NC}"
source "$VENV_ACTIVATE"

# 7. Install requirements
echo -e "${BLUE}Installing/upgrading dependencies (this may take a few minutes)...${NC}"
python -m pip install --upgrade pip
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install requirements.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Environment setup complete!${NC}"

# 8. Start Flask App in background and open browser
echo -e "${BLUE}Launching Flask application...${NC}"

# Open browser automatically
if [[ "$OSTYPE" == "darwin"* ]]; then
    (sleep 2 && open "http://127.0.0.1:5000") &
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    (sleep 2 && xdg-open "http://127.0.0.1:5000") &
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    (sleep 2 && cmd.exe /c start "http://127.0.0.1:5000") &
fi

python app.py
