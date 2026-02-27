# GitHub Actions CI/CD Pipeline - Complete Guide

## 📋 Pipeline Overview

Your GitHub Actions pipeline is now fully configured to run your Blog App on EC2 using the public IP address. Here's how it works:

---

## 🔄 Pipeline Architecture

```
GitHub Push (main branch)
    ↓
┌─────────────────────────────────────┐
│  1. Backend CI Job (Parallel)       │
│  - Checkout code                    │
│  - Setup Node.js 18                 │
│  - Install & Test                   │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│  2. Frontend CI Job (Parallel)      │
│  - Checkout code                    │
│  - Setup Node.js 18                 │
│  - Build React app                  │
│  - Store build artifacts            │
└─────────────────────────────────────┘
         ↓
┌─────────────────────────────────────┐
│  3. Deploy to EC2 Job               │
│  (Only runs after 1 & 2 pass)       │
│  - Setup SSH connection             │
│  - Clone/pull repository            │
│  - Setup .env with secrets          │
│  - Build Docker images              │
│  - Start containers                 │
│  - Verify health                    │
└─────────────────────────────────────┘
         ↓
    ✅ DEPLOYMENT COMPLETE
```

---

## 📦 What Gets Deployed

### Architecture on EC2:

```
Public Internet
    ↓
13.220.246.205:80 (Nginx/Frontend)
    ↓
    ├─→ Serves React app (frontend)
    │
    └─→ Proxies /api/* → Backend API
                ↓
        13.220.246.205:5000 (Node.js API)
                ↓
        PostgreSQL Database (Port 5432)
```

### Port Mapping:

| Service | Port | Access | Purpose |
|---------|------|--------|---------|
| Frontend (Nginx) | 80 | http://13.220.246.205 | Main web app |
| Frontend (Nginx) | 443 | https://13.220.246.205 | HTTPS (future) |
| Backend API | 5000 | Via Nginx proxy /api | Backend server |
| Database | 5432 | Internal only | PostgreSQL |

---

## 🚀 How to Trigger the Pipeline

### Method 1: Push to Main Branch
```bash
# Make changes locally
git add .
git commit -m "Your changes"
git push origin main
```

### Method 2: Create Pull Request
```bash
# Create a feature branch
git checkout -b feature/my-feature

# Make changes
git add .
git commit -m "Your changes"

# Push and create PR (pipeline runs but doesn't deploy)
git push origin feature/my-feature
```

**Note:** Deployment ONLY happens when pushing to `main` branch!

---

## 📊 Pipeline Jobs Explained

### Job 1: Backend CI (Runs on: ubuntu-latest)
```yaml
Steps:
1. Checkout - Get latest code from GitHub
2. Setup Node.js - Install Node.js v18
3. Install Dependencies - Run 'npm install' in backend/
4. Run Tests - Execute 'npm test' (if configured)

Status: ✅ PASS or ❌ FAIL
Duration: ~2-3 minutes
```

### Job 2: Frontend CI (Runs on: ubuntu-latest)
```yaml
Steps:
1. Checkout - Get latest code from GitHub
2. Setup Node.js - Install Node.js v18
3. Install Dependencies - Run 'npm install' in frontend/
4. Build App - Run 'npm run build' (creates dist/)
5. Upload Artifacts - Store dist/ for 1 day

Status: ✅ PASS or ❌ FAIL
Duration: ~3-5 minutes
```

### Job 3: Deploy to EC2 (Only if Job 1 & 2 pass)
```yaml
Runs on: ubuntu-latest
Condition: github.ref == 'refs/heads/main' && github.event_name == 'push'

Steps:
1. Checkout - Get latest code
2. Setup SSH Key - Configure GitHub Secret as SSH key
3. Connect to EC2 via SSH
4. Clone/Update Git Repository
5. Create .env file with secrets (from GitHub Secrets)
6. Build Docker Images:
   - PostgreSQL (db)
   - Node.js Backend (backend)
   - Nginx + React (frontend)
7. Start Containers: docker-compose up -d
8. Verify Services are Running

Status: ✅ PASS or ❌ FAIL
Duration: ~5-10 minutes
```

---

## 🔐 Environment Variables & Secrets

### GitHub Secrets Used:
```yaml
EC2_IP:          13.220.246.205        # Public IP address
EC2_USER:        ec2-user              # SSH username
EC2_SSH_KEY:     ${PRIVATE_KEY}        # SSH private key
DB_USER:         postgres              # Database username
DB_PASSWORD:     ${STRONG_PASSWORD}    # Database password
DB_NAME:         content_db            # Database name
JWT_SECRET:      ${JWT_SECRET_KEY}     # JWT signing key
```

### What Gets Set on EC2:
```bash
# Inside /home/ec2-user/blog-app/.env
NODE_ENV=production
PORT=5000
DB_HOST=db
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=<from GitHub Secret>
DB_NAME=content_db
JWT_SECRET=<from GitHub Secret>
API_URL=http://13.220.246.205:5000
EC2_PUBLIC_IP=13.220.246.205
VITE_API_URL=http://13.220.246.205
```

---

## 📱 Accessing Your Application After Deployment

### Frontend (React App via Nginx)
```
http://13.220.246.205
```
- Access your blog application
- Uses Nginx as reverse proxy
- Proxies API calls to backend

### Backend API (Direct)
```
http://13.220.246.205:5000

Available Endpoints:
- POST   http://13.220.246.205:5000/api/auth/register
- POST   http://13.220.246.205:5000/api/auth/login
- GET    http://13.220.246.205:5000/api/content
- POST   http://13.220.246.205:5000/api/content
- GET    http://13.220.246.205:5000/api/content/:id
- PUT    http://13.220.246.205:5000/api/content/:id
- DELETE http://13.220.246.205:5000/api/content/:id
```

---

## 🔍 Monitoring Pipeline Execution

### Watch Pipeline in Real-Time:
1. Go to: https://github.com/Avivarma1/AVI_27_2_BLOG-APP/actions
2. Click on the latest workflow run
3. View live logs for each job

### Pipeline Status Indicators:
- 🟡 Yellow = Running
- 🟢 Green = Success
- 🔴 Red = Failed

### View Individual Job Logs:
```
Actions → Workflow Run → Click Job → View Logs
```

---

## 🐛 Troubleshooting Pipeline

### Issue: "Deploy to EC2" job doesn't appear
**Cause:** Job 1 or Job 2 failed
**Solution:** 
1. Check Backend CI logs
2. Check Frontend CI logs
3. Fix errors and push again

### Issue: SSH connection fails
**Cause:** Invalid EC2_SSH_KEY or EC2_IP
**Solution:**
1. Verify GitHub Secrets are correct
2. Test SSH manually:
   ```bash
   ssh -i your-key ec2-user@13.220.246.205
   ```

### Issue: Containers fail to start
**Cause:** Port conflicts or missing .env variables
**Solution:**
1. SSH to EC2 and check:
   ```bash
   docker-compose logs -f
   docker ps
   ```

### Issue: Application returns 404 after deployment
**Cause:** Frontend build didn't complete
**Solution:**
1. Check Frontend CI job logs
2. Verify npm run build succeeds locally
3. Check dist/ folder exists

### Issue: Backend API unreachable from frontend
**Cause:** Nginx proxy not configured correctly
**Solution:**
1. Check nginx.conf location /api block
2. Verify backend container is running:
   ```bash
   docker ps | grep backend
   ```

---

## 📈 Performance & Optimization

### Build Cache
- GitHub Actions caches npm dependencies (node_modules)
- First build: ~5-7 minutes
- Subsequent builds: ~3-4 minutes (with cache)

### Docker Layer Caching
- EC2 caches Docker layers between deployments
- Rebuilds only changed layers

### Parallel Jobs
- Backend CI & Frontend CI run simultaneously (saves ~3 min)
- Deploy only starts after both CI jobs pass

---

## 🔄 Rollback / Manual Deployment

### If Pipeline Fails:
```bash
# SSH to EC2
ssh -i your-key ec2-user@13.220.246.205

# Stop all containers
cd /home/ec2-user/blog-app
docker-compose down

# Restore previous version
git log --oneline | head -5
git checkout <commit-hash>

# Redeploy
docker-compose build
docker-compose up -d
```

### Manual Deployment (without GitHub Actions):
```bash
# SSH to EC2
ssh -i your-key ec2-user@13.220.246.205

# Navigate to app
cd /home/ec2-user/blog-app

# Pull latest code
git pull origin main

# Update environment if needed
# (edit .env file)

# Rebuild and restart
docker-compose down
docker-compose build
docker-compose up -d

# Check status
docker-compose ps
```

---

## ✅ Verification Checklist After Deployment

```bash
# SSH to EC2
ssh -i your-key ec2-user@13.220.246.205

# Run these commands:
echo "1. Docker status:"
docker ps

echo "2. Service health:"
docker-compose ps

echo "3. Backend API test:"
curl http://localhost:5000

echo "4. Database connection:"
docker-compose exec db psql -U postgres -d content_db -c "SELECT 1;"

echo "5. Frontend status:"
curl http://localhost:3000 | head -20

echo "6. View logs:"
docker-compose logs -f --tail=50
```

---

## 📝 Workflow File Location

Pipeline configuration file:
```
.github/workflows/deploy.yml
```

To modify pipeline:
1. Edit `.github/workflows/deploy.yml`
2. Commit and push
3. Changes take effect on next push

---

## 🎯 Common Deployment Scenarios

### Scenario 1: Bug Fix on Main Branch
```bash
git checkout main
git pull origin main
# Fix the bug
git add .
git commit -m "Fix: [describe fix]"
git push origin main
# ✅ Pipeline runs automatically → Deploys to EC2
```

### Scenario 2: Feature Development (PR)
```bash
git checkout -b feature/new-feature
# Develop feature
git add .
git commit -m "Feature: [describe feature]"
git push origin feature/new-feature
# Create PR on GitHub
# ✅ Pipeline runs (CI only, no deployment)
# Review PR
# Merge to main
# ✅ Pipeline runs again → Deploys to EC2
```

### Scenario 3: Emergency Hotfix
```bash
git checkout main
git pull origin main
# Apply hotfix
git add .
git commit -m "Hotfix: [urgent fix]"
git push origin main
# ✅ Pipeline runs immediately → Deployed within 15 minutes
```

---

## 📞 Support & Resources

- **GitHub Actions Docs:** https://docs.github.com/en/actions
- **Docker Compose Docs:** https://docs.docker.com/compose
- **Node.js Docs:** https://nodejs.org/docs
- **Nginx Docs:** https://nginx.org/en/docs

---

## Summary

Your GitHub Actions pipeline:
- ✅ **Automatically runs** on every push to main
- ✅ **Tests backend** and **builds frontend** in parallel
- ✅ **Deploys via SSH** to your EC2 instance
- ✅ **Uses Docker Compose** for container orchestration
- ✅ **Accessible via public IP** (13.220.246.205)
- ✅ **No localhost needed** - fully production-ready

**Total deployment time:** ~10-15 minutes from push to live! 🚀
