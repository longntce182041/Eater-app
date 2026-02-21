#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Starting Eater App Services${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"

# Check if MongoDB is running
echo -e "\n${YELLOW}Checking MongoDB...${NC}"
if pgrep -x "mongod" > /dev/null; then
    echo -e "${GREEN}✓ MongoDB is running${NC}"
else
    echo -e "${RED}✗ MongoDB is not running${NC}"
    echo -e "${YELLOW}  Please start MongoDB first: mongod${NC}"
    exit 1
fi

# Start Python AI Service
echo -e "\n${YELLOW}Starting AI Meal Planning Service (Python)...${NC}"
cd ai_meal_planing_service
if [ ! -d "venv" ]; then
    echo -e "${YELLOW}  Creating virtual environment...${NC}"
    python -m venv venv
fi

source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null

echo -e "${YELLOW}  Installing dependencies...${NC}"
pip install -q fastapi uvicorn pydantic python-dotenv

echo -e "${GREEN}  Starting AI service on port 8000...${NC}"
nohup uvicorn app.main:app --reload --port 8000 > ../logs/ai-service.log 2>&1 &
AI_PID=$!
echo -e "${GREEN}  AI Service started (PID: $AI_PID)${NC}"

cd ..

# Wait for AI service to start
sleep 3

# Start Node.js Backend
echo -e "\n${YELLOW}Starting Node.js Backend...${NC}"
cd eater-backend

echo -e "${YELLOW}  Checking dependencies...${NC}"
if [ ! -d "node_modules" ]; then
    echo -e "${YELLOW}  Installing npm packages...${NC}"
    npm install
fi

echo -e "${GREEN}  Starting backend on port 3000...${NC}"
nohup npm run dev > ../logs/backend.log 2>&1 &
BACKEND_PID=$!
echo -e "${GREEN}  Backend started (PID: $BACKEND_PID)${NC}"

cd ..

# Wait for services to fully start
echo -e "\n${YELLOW}Waiting for services to start...${NC}"
sleep 5

# Test connections
echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  Testing Service Connections${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"

echo -e "\n${YELLOW}Running connection tests...${NC}"
node test-ai-connection.js

echo -e "\n${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Services are running!${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════${NC}"
echo -e "\n${GREEN}AI Service:${NC} http://localhost:8000"
echo -e "${GREEN}Backend:${NC}    http://localhost:3000"
echo -e "\n${YELLOW}Logs:${NC}"
echo -e "  AI Service: logs/ai-service.log"
echo -e "  Backend:    logs/backend.log"
echo -e "\n${YELLOW}To stop services:${NC}"
echo -e "  kill $AI_PID $BACKEND_PID"
echo -e "\n${YELLOW}Or use:${NC}"
echo -e "  ./stop-services.sh"
echo -e "\n"

# Save PIDs for later
mkdir -p .pids
echo $AI_PID > .pids/ai-service.pid
echo $BACKEND_PID > .pids/backend.pid
