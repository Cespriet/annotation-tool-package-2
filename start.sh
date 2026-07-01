#!/bin/bash
# Startup script for the Annotation Enhanced Web App

# Color formatting
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Starting Annotation Enhanced App Setup ===${NC}"

# Check Python 3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Error: python3 is not installed. Please install Python 3 before running this script.${NC}"
    exit 1
fi

# Check Ollama
if ! command -v ollama &> /dev/null; then
    echo -e "${RED}Error: ollama is not installed. Please install Ollama from https://ollama.com/ before running this script.${NC}"
    exit 1
fi

# Check and pull model
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

# Create virtual env if not exists
if [ ! -d "venv" ]; then
    echo -e "${BLUE}Creating Python virtual environment (venv)...${NC}"
    python3 -m venv venv
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: Failed to create venv.${NC}"
        exit 1
    fi
fi

# Activate virtual env
echo -e "${BLUE}Activating virtual environment...${NC}"
source venv/bin/activate

# Install requirements
echo -e "${BLUE}Installing/upgrading dependencies (this may take a few minutes for ML packages)...${NC}"
pip install --upgrade pip
pip install -r requirements.txt
if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to install requirements.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Environment setup complete!${NC}"

# Start Flask App in background and open browser
echo -e "${BLUE}Launching Flask application...${NC}"

# Open browser automatically on macOS / Linux
if [[ "$OSTYPE" == "darwin"* ]]; then
    (sleep 2 && open "http://127.0.0.1:5000") &
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    (sleep 2 && xdg-open "http://127.0.0.1:5000") &
fi

python app.py
