# 🚀 Quick Reference Guide

## Services Management

### Start All Services
```bash
./manage-services.sh start
```

### Stop All Services
```bash
./manage-services.sh stop
```

### Check Services Status
```bash
./manage-services.sh status
```

### Run All Tests
```bash
./test-all-features.sh
```

---

## Most Common API Calls

### 1. Update Channel (Add chat_id)
```bash
curl -X PUT http://localhost:3000/api/channels/CHANNEL_ID \
  -H "Content-Type: application/json" \
  -d '{"chat_id": "-1001234567890", "name": "Channel Name"}'
```

### 2. Register Session (Session String)
```bash
curl -X POST http://localhost:3000/api/sessions/register_string \
  -H "Content-Type: application/json" \
  -d '{
    "api_id": 12345,
    "api_hash": "your_api_hash",
    "session_string": "your_session_string"
  }'
```

### 3. Create Project
```bash
curl -X POST http://localhost:3000/api/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Project",
    "description": "Project description"
  }'
```

### 4. Run Project
```bash
curl -X POST http://localhost:3000/api/projects/PROJECT_ID/run \
  -H "Content-Type: application/json" \
  -d '{"started_by": "username"}'
```

### 5. Stop Project
```bash
curl -X POST http://localhost:3000/api/projects/PROJECT_ID/stop
```

### 6. Check Project Status
```bash
curl http://localhost:3000/api/projects/PROJECT_ID/status | jq '.'
```

### 7. View Dashboard Stats
```bash
curl http://localhost:3000/api/dashboard/stats | jq '.'
```

### 8. View Recent Activity
```bash
curl http://localhost:3000/api/dashboard/recent-activity?limit=20 | jq '.'
```

---

## Frontend URLs

- **Main Dashboard**: http://localhost:3001/
- **Projects**: http://localhost:3001/projects
- **Sessions**: http://localhost:3001/sessions
- **Channels**: http://localhost:3001/channels
- **Files**: http://localhost:3001/files

---

## Database Quick Access

### View Database
```bash
# Install sqlite3 browser
sqlite3 db/telegram_app.db

# List all tables
.tables

# View sessions
SELECT * FROM sessions;

# View projects
SELECT * FROM projects;

# View running projects with stats
SELECT p.name, p.status, pr.stats 
FROM projects p 
LEFT JOIN process_runs pr ON pr.project_id = p.id 
WHERE p.status = 'running';
```

---

## Logs & Debugging

### View Backend Logs
```bash
screen -r backend
# Press Ctrl+A then D to detach
```

### View Python Service Logs
```bash
screen -r python-service
# Press Ctrl+A then D to detach

# Or check the log file
tail -f python-service/telegram_service.log
```

### View Redis Logs
```bash
screen -r redis
```

### Check Queue Status
```bash
redis-cli
> KEYS *
> LLEN bull:send message:wait
> LLEN bull:send message:active
> LLEN bull:send message:completed
> LLEN bull:send message:failed
> exit
```

---

## Common Troubleshooting

### Reset Running Project
```bash
# If project stuck in running state
PROJECT_ID="your-project-id"
curl -X POST http://localhost:3000/api/projects/$PROJECT_ID/stop

# Wait 2 seconds
sleep 2

# Run again
curl -X POST http://localhost:3000/api/projects/$PROJECT_ID/run \
  -H "Content-Type: application/json" \
  -d '{"started_by": "user"}'
```

### Clear Redis Queue
```bash
redis-cli FLUSHALL
```

### Restart All Services
```bash
./manage-services.sh restart
```

### Check if Ports are Available
```bash
# Backend (should be 3000)
netstat -tuln | grep 3000

# Frontend (should be 3001)
netstat -tuln | grep 3001

# Python Service (should be 8000)
netstat -tuln | grep 8000

# Redis (should be 6379)
netstat -tuln | grep 6379
```

---

## Environment Variables

### Check .env File
```bash
cat .env
```

### Required Variables
- `PORT=3000` - Backend port
- `REDIS_HOST=localhost` - Redis host
- `REDIS_PORT=6379` - Redis port
- `PYTHON_SERVICE_URL=http://localhost:8000` - Python service URL

---

## File Locations

- **Backend**: `/home/ulul/telegramManagerSender/backend/`
- **Frontend**: `/home/ulul/telegramManagerSender/frontend/`
- **Python Service**: `/home/ulul/telegramManagerSender/python-service/`
- **Database**: `/home/ulul/telegramManagerSender/db/telegram_app.db`
- **Uploads**: `/home/ulul/telegramManagerSender/uploads/`
- **Logs**: `/home/ulul/telegramManagerSender/python-service/telegram_service.log`

---

## Quick Fixes

### Channel has no chat_id
```bash
# Use Telegram to get chat_id, then:
curl -X PUT http://localhost:3000/api/channels/CHANNEL_ID \
  -H "Content-Type: application/json" \
  -d '{"chat_id": "your_chat_id"}'
```

### Project shows 0 jobs
This means channels don't have chat_id set. Update channels first (see above).

### Backend not responding
```bash
./manage-services.sh restart backend
```

### Python service error
```bash
./manage-services.sh restart python-service
tail -f python-service/telegram_service.log
```

---

## Testing Endpoints

### Health Checks
```bash
# Backend
curl http://localhost:3000/health

# Python Service
curl http://localhost:8000/health

# Frontend
curl -I http://localhost:3001
```

### Test Session Validation
```bash
curl -X POST http://localhost:8000/validate_session \
  -H "Content-Type: application/json" \
  -d '{"session_string": "your_session_string"}'
```

---

## Useful jq Commands

```bash
# Pretty print JSON
curl http://localhost:3000/api/sessions | jq '.'

# Get only session names
curl http://localhost:3000/api/sessions | jq '.data[].name'

# Filter running projects
curl http://localhost:3000/api/projects | jq '.data[] | select(.status == "running")'

# Count total jobs
curl http://localhost:3000/api/dashboard/stats | jq '.data.runs'
```

---

**For detailed information, see:**
- `TEST_RESULTS.md` - Complete test results
- `FINAL_STATUS.md` - Full status report
- `README.md` - Project documentation
