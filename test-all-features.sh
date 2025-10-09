#!/bin/bash

# Telegram Manager - Comprehensive Feature Test Script
# This script tests all major features of the application

set -e  # Exit on error

echo "=================================="
echo "Telegram Manager Feature Test"
echo "=================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
PASSED=0
FAILED=0

# Function to test endpoint
test_endpoint() {
    local name=$1
    local method=$2
    local url=$3
    local data=$4
    
    echo -n "Testing: $name ... "
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" "$url")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "200" ] || [ "$http_code" = "201" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $http_code)"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (HTTP $http_code)"
        echo "Response: $body" | head -n 3
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Test health endpoints
echo "=== Health Checks ==="
test_endpoint "Backend Health" "GET" "http://localhost:3000/health"
test_endpoint "Python Service Health" "GET" "http://localhost:8000/health"
test_endpoint "Frontend" "GET" "http://localhost:3001"
echo ""

# Test backend API endpoints
echo "=== Backend API Endpoints ==="
test_endpoint "List Sessions" "GET" "http://localhost:3000/api/sessions"
test_endpoint "List Projects" "GET" "http://localhost:3000/api/projects"
test_endpoint "List Channels" "GET" "http://localhost:3000/api/channels"
test_endpoint "List Categories" "GET" "http://localhost:3000/api/categories"
test_endpoint "List Files" "GET" "http://localhost:3000/api/files"
test_endpoint "List Credentials" "GET" "http://localhost:3000/api/credentials"
echo ""

# Test dashboard endpoints
echo "=== Dashboard Endpoints ==="
test_endpoint "Dashboard Stats" "GET" "http://localhost:3000/api/dashboard/stats"
test_endpoint "Recent Activity" "GET" "http://localhost:3000/api/dashboard/recent-activity?limit=10"
test_endpoint "Running Projects" "GET" "http://localhost:3000/api/dashboard/running-projects"
test_endpoint "Recent Runs" "GET" "http://localhost:3000/api/dashboard/recent-runs?limit=5"
echo ""

# Test project detail endpoints
echo "=== Project Detail Endpoints ==="
PROJECT_ID="cef240b9-6490-4ec2-8a15-8fb97141210b"
test_endpoint "Project Details" "GET" "http://localhost:3000/api/projects/$PROJECT_ID"
test_endpoint "Project Status" "GET" "http://localhost:3000/api/projects/$PROJECT_ID/status"
test_endpoint "Project Sessions" "GET" "http://localhost:3000/api/projects/$PROJECT_ID/sessions"
test_endpoint "Project Targets" "GET" "http://localhost:3000/api/projects/$PROJECT_ID/targets"
test_endpoint "Project Messages" "GET" "http://localhost:3000/api/projects/$PROJECT_ID/messages"
echo ""

# Test channel details
echo "=== Channel Endpoints ==="
CHANNEL_ID="4080a63c-d0fa-41bc-a765-4dbfb50c44b1"
test_endpoint "Channel Details" "GET" "http://localhost:3000/api/channels/$CHANNEL_ID"
echo ""

# Test file endpoints
echo "=== File Endpoints ==="
FILE_ID="3a89a9c2-6aea-4dbf-b4b4-e0e9e108d545"
test_endpoint "File Info" "GET" "http://localhost:3000/api/files/$FILE_ID/info"
test_endpoint "File Preview" "GET" "http://localhost:3000/api/files/$FILE_ID/preview"
echo ""

# Test category endpoints
echo "=== Category Endpoints ==="
CATEGORY_ID="a8289c2e-255d-4fae-a38b-3703b4ebb467"
test_endpoint "Category Details" "GET" "http://localhost:3000/api/categories/$CATEGORY_ID"
test_endpoint "Category Channels" "GET" "http://localhost:3000/api/categories/$CATEGORY_ID/channels"
echo ""

# Redis check
echo "=== Redis Connection ==="
echo -n "Testing: Redis Connection ... "
if redis-cli ping > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${RED}✗ FAIL${NC}"
    FAILED=$((FAILED + 1))
fi
echo ""

# Database check
echo "=== Database Status ==="
if [ -f "db/telegram_app.db" ]; then
    SIZE=$(du -h db/telegram_app.db | cut -f1)
    echo -e "Database file: ${GREEN}✓ EXISTS${NC} (Size: $SIZE)"
    PASSED=$((PASSED + 1))
else
    echo -e "Database file: ${RED}✗ NOT FOUND${NC}"
    FAILED=$((FAILED + 1))
fi
echo ""

# Summary
echo "=================================="
echo "Test Summary"
echo "=================================="
echo -e "Total Tests: $((PASSED + FAILED))"
echo -e "${GREEN}Passed: $PASSED${NC}"
echo -e "${RED}Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED!${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Some tests failed. Check the output above.${NC}"
    exit 1
fi
