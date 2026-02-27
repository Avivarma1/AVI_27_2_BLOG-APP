# 🚀 GitHub Actions Pipeline - Quick Start

## Your CI/CD Pipeline is Ready!

Your blog application now uses **GitHub Actions** for automated CI/CD deployment. No more CircleCI!

---

## 📊 Pipeline Flow (What Happens When You Push)

```
You Push Code to GitHub (main branch)
                ↓
        GitHub receives push
                ↓
    GitHub Actions triggers workflow
                ↓
    ┌─────────────────────────────────┐
    │ STAGE 1: Build & Test (Parallel)│
    ├─────────────────────────────────┤
    │ Backend CI: npm install & test  │
    │ Frontend CI: npm build          │
    └─────────────────────────────────┘
         ↓ (both must pass)
    ┌─────────────────────────────────┐
    │ STAGE 2: Deploy to EC2          │
    ├─────────────────────────────────┤
    │ • SSH to your EC2 instance      │
    │ • Pull latest code              │
    │ • Create .env file (from secrets)│
    │ • Build Docker images           │
    │ • Start containers              │
    │ • Verify services are running   │
    └─────────────────────────────────┘
              ↓
    ✅ YOUR APP IS LIVE!
    http://13.220.246.205
```

---

## 🎯 Key Points

### ✅ What the Pipeline Does
- Runs **backend tests** and **frontend build** together
- Only deploys if **both tests pass**
- Deploys automatically to EC2 via SSH
- Uses your **public IP** (13.220.246.205) - NOT localhost!
- Runs **Docker containers** for isolation
- Takes **10-15 minutes** from push to live

### ❌ What the Pipeline Does NOT Do
- Doesn't run on pull requests (CI only, no deployment)
- Doesn't deploy if tests fail
- Doesn't require manual approval

---

## 💻 3-Step Setup Process

### Step 1️⃣: Run Setup Script on EC2
```bash
# SSH to your EC2 instance
ssh -i your-key-pair.pem ec2-user@13.220.246.205

# Download and run setup script
curl -O https://raw.githubusercontent.com/Avivarma1/AVI_27_2_BLOG-APP/main/ec2-setup.sh
chmod +x ec2-setup.sh
bash ec2-setup.sh

# This installs Node.js, Docker, pm2, git, etc.
```

### Step 2️⃣: Generate SSH Keys
```bash
# Still on EC2 terminal
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_deploy_key -N ""

# Display the private key (copy entire output)
cat ~/.ssh/github_deploy_key

# Add public key to authorized_keys
cat ~/.ssh/github_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Step 3️⃣: Configure GitHub Secrets
Go to: **https://github.com/Avivarma1/AVI_27_2_BLOG-APP/settings/secrets/actions**

Add these 7 secrets:

| Secret Name | Value | Example |
|---|---|---|
| `EC2_IP` | Your public IP | `13.220.246.205` |
| `EC2_USER` | EC2 username | `ec2-user` |
| `EC2_SSH_KEY` | Private key (from step 2) | `-----BEGIN RSA PRIVATE KEY-----...` |
| `DB_USER` | Database user | `postgres` |
| `DB_PASSWORD` | Strong password ⚠️ | `MyPass123!@#Secure` |
| `DB_NAME` | Database name | `content_db` |
| `JWT_SECRET` | JWT secret key ⚠️ | `jwt-secret-key-change-this-2024` |

---

## 🚀 Test the Pipeline

### Push Code to Trigger Pipeline
```bash
# Clone your repository locally (if not already)
git clone https://github.com/Avivarma1/AVI_27_2_BLOG-APP.git
cd AVI_27_2_BLOG-APP

# Make a small change (e.g., update README)
echo "# Blog App - GitHub Actions Ready!" > README.md

# Commit and push
git add .
git commit -m "Update: GitHub Actions configuration ready"
git push origin main
```

### Watch Pipeline Run
1. Go to: **https://github.com/Avivarma1/AVI_27_2_BLOG-APP/actions**
2. You'll see your workflow running
3. Click on the workflow to view live logs
4. Wait for all jobs to complete (🟢 = pass, 🔴 = fail)

### Check Results
Once pipeline completes successfully:
- **Frontend:** http://13.220.246.205 ✅
- **Backend API:** http://13.220.246.205:5000 ✅
- **Database:** Running internally ✅

---

## 📝 How to Use This Pipeline

### Regular Development Workflow

**For feature development:**
```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes
git add .
git commit -m "Feature: description"

# Push to GitHub
git push origin feature/my-feature

# Create Pull Request on GitHub
# ℹ️ Pipeline runs (CI tests only, no deployment)
```

**Merge and deploy:**
```bash
# After code review, merge PR to main
# OR directly push to main:

git checkout main
git pull origin main
git commit -m "Updated code"
git push origin main

# ✅ Pipeline automatically deploys!
```

### Emergency Hotfix

```bash
# Quick hotfix directly to main
git checkout main
git pull origin main

# Fix the bug
git add .
git commit -m "Hotfix: urgent fix description"
git push origin main

# ✅ Deployed within 15 minutes!
```

---

## 🔍 Understanding the Workflow

### Job 1: Backend CI (Parallel)
```
✓ Checkout code
✓ Install Node.js 18
✓ npm install
✓ npm test (or skip if no tests)
Duration: 2-3 min
```

### Job 2: Frontend CI (Parallel)
```
✓ Checkout code
✓ Install Node.js 18
✓ npm install
✓ npm run build (creates dist/)
✓ Upload build artifacts
Duration: 3-5 min
```

### Job 3: Deploy to EC2 (Sequential - only after Job 1 & 2 pass)
```
✓ Connect via SSH to EC2
✓ Clone/pull repository
✓ Create .env with secrets
✓ docker-compose build
✓ docker-compose up -d
✓ Verify services running
Duration: 5-10 min
```

**Total Time:** 10-15 minutes ⏱️

---

## 🐛 Troubleshooting

### Pipeline shows ❌ FAILED

**Check Backend CI logs:**
- View Actions → Click workflow → Backend CI job
- Common issues: npm install failed, test errors

**Check Frontend CI logs:**
- View Actions → Click workflow → Frontend CI job
- Common issues: npm build failed, TypeScript errors

**Check Deploy logs:**
- View Actions → Click workflow → Deploy to EC2 job
- Common issues: SSH connection failed, Docker issues

### Application Won't Load

**SSH to EC2 and check:**
```bash
ssh -i your-key ec2-user@13.220.246.205

# See running containers
docker ps

# Check logs
docker-compose logs -f

# Test endpoints
curl http://localhost:3000   # Frontend
curl http://localhost:5000   # Backend
```

### SSH Connection Error

**Verify GitHub Secrets:**
- ✓ `EC2_IP`: Correct public IP?
- ✓ `EC2_SSH_KEY`: Full private key content?
- ✓ `EC2_USER`: Correct username (ec2-user for Amazon Linux)?

---

## 📱 Access Your Application

### After successful deployment:

**Frontend (Web App)**
```
http://13.220.246.205
```
- Your React blog application
- Served by Nginx
- Port 80 (standard HTTP)

**Backend API**
```
http://13.220.246.205:5000
or proxied through Nginx at:
http://13.220.246.205/api
```

**Available API Endpoints:**
```
POST   /api/auth/register        - Create account
POST   /api/auth/login           - Login
GET    /api/content              - Get all posts
POST   /api/content              - Create post
GET    /api/content/:id          - Get post
PUT    /api/content/:id          - Update post
DELETE /api/content/:id          - Delete post
```

---

## 🔐 Security Best Practices

✅ **Do:**
- Keep SSH keys secure
- Use strong database passwords
- Rotate JWT secrets periodically
- Restrict EC2 security group access
- Review code before merging

❌ **Don't:**
- Commit secrets to GitHub
- Share private keys
- Use weak passwords
- Leave SSH keys public
- Deploy untested code

---

## 📊 Monitoring & Logs

### View Pipeline Status
```
https://github.com/Avivarma1/AVI_27_2_BLOG-APP/actions
```

### View Live Deployment Logs
```bash
ssh -i your-key ec2-user@13.220.246.205
cd /home/ec2-user/blog-app

# See all container logs
docker-compose logs -f

# See specific service
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

---

## 🎯 Next Steps

1. ✅ Run EC2 setup script
2. ✅ Generate SSH keys
3. ✅ Configure 7 GitHub Secrets
4. ✅ Push code to trigger pipeline
5. ✅ Monitor Actions tab
6. ✅ Access app at http://13.220.246.205
7. ✅ Start developing! 🚀

---

## 📚 Documentation Files

- **[GITHUB_ACTIONS_PIPELINE.md](GITHUB_ACTIONS_PIPELINE.md)** - Complete pipeline documentation
- **[GITHUB_ACTIONS_SETUP.md](GITHUB_ACTIONS_SETUP.md)** - Detailed setup guide
- **[EC2_QUICK_COMMANDS.md](EC2_QUICK_COMMANDS.md)** - Quick commands reference
- **[.github/workflows/deploy.yml](.github/workflows/deploy.yml)** - Workflow configuration

---

## ✨ Summary

| Feature | Status |
|---------|--------|
| CircleCI | ❌ Removed |
| GitHub Actions | ✅ Active |
| Localhost | ❌ Not used |
| Public IP | ✅ 13.220.246.205 |
| Auto-deploy | ✅ On main push |
| Docker | ✅ compose up -d |
| CI tests | ✅ Backend & Frontend |
| Live monitoring | ✅ Via Actions tab |

**Your deployment is production-ready! 🎉**
