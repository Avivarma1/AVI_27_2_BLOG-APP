# 🚀 FINAL SETUP GUIDE - RUN YOUR APP ON PUBLIC IP

## Your App Will Be Live at: http://13.220.246.205

This is the **COMPLETE** step-by-step guide. Follow EXACTLY as written.

---

## ⚠️ IMPORTANT: You Have 2 Options

**Option A: Using GitHub Actions (Recommended - Fully Automated)**
- GitHub Actions automatically deploys everything
- You just push code
- Takes 15 minutes to deploy
- No manual Docker commands needed

**Option B: Manual Docker on EC2 (For Testing)**
- You control everything manually
- Faster initial testing
- More complex

**→ I recommend OPTION A (GitHub Actions)**

---

# 🎯 OPTION A: GitHub Actions Setup (RECOMMENDED)

## PART 1: Docker Desktop Setup (Windows)

### Step 1.1: Download Docker Desktop
1. Go to: https://www.docker.com/products/docker-desktop
2. Click "Download for Windows"
3. Run the installer
4. **IMPORTANT:** When asked, enable "WSL 2" (Windows Subsystem for Linux 2)
5. Restart your computer
6. Open Docker Desktop from Start menu
7. Wait for Docker to start (green icon bottom-left)

### Step 1.2: Verify Docker Works
Open PowerShell and run:
```powershell
docker --version
docker run hello-world
```

If both work, Docker is ready! ✅

---

## PART 2: EC2 Instance Setup

### Step 2.1: Connect to Your EC2

**Using PowerShell:**
```powershell
# Go to your AWS key pair location
cd C:\path\to\your\keys   # Change this to your key location

# Connect to EC2
ssh -i "your-key-pair.pem" ec2-user@13.220.246.205
```

**If SSH doesn't work:**
- Use PuTTY (Google "PuTTY SSH Windows")
- Load your .pem key in PuTTY
- Connect to: 13.220.246.205
- Login as: ec2-user

### Step 2.2: Run Setup Script on EC2

**Copy and paste this ENTIRE block into EC2 terminal:**

```bash
#!/bin/bash
set -e

echo "Setting up EC2 instance..."

# Update system
sudo yum update -y

# Install Node.js 18
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Install Git
sudo yum install -y git

# Create app directory
mkdir -p /home/ec2-user/blog-app
cd /home/ec2-user

# Clone repository
git clone https://github.com/Avivarma1/AVI_27_2_BLOG-APP.git blog-app

echo "✅ EC2 Setup Complete!"
node --version
docker --version
docker-compose --version
```

**👆 Paste that entire script at once**

This will:
- ✅ Install Node.js
- ✅ Install Docker
- ✅ Install Docker Compose
- ✅ Clone your repository
- ✅ Take about 10 minutes

### Step 2.3: Generate SSH Keys (Still on EC2)

**Copy and paste this:**

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_deploy_key -N ""

# Display the PRIVATE key
echo "========== COPY EVERYTHING BELOW =========="
cat ~/.ssh/github_deploy_key
echo "========== COPY EVERYTHING ABOVE =========="

# Add public key to authorized_keys
cat ~/.ssh/github_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

**📌 IMPORTANT:** 
- Select and copy EVERYTHING between the equals signs
- This is your EC2_SSH_KEY secret
- You'll paste it in GitHub next

---

## PART 3: GitHub Secrets Setup

### Step 3.1: Go to GitHub Secrets

1. Open browser: https://github.com/Avivarma1/AVI_27_2_BLOG-APP/settings/secrets/actions
2. Look for green button "New repository secret"

### Step 3.2: Create Each Secret (7 Total)

**Click "New repository secret" and add each one:**

#### Secret #1: EC2_IP
```
Name:  EC2_IP
Value: 13.220.246.205
```
Click "Add secret"

#### Secret #2: EC2_USER
```
Name:  EC2_USER
Value: ec2-user
```
Click "Add secret"

#### Secret #3: EC2_SSH_KEY
```
Name:  EC2_SSH_KEY
Value: [PASTE the private key from Step 2.3]
```
Should look like:
```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
...many lines...
-----END RSA PRIVATE KEY-----
```
Click "Add secret"

#### Secret #4: DB_USER
```
Name:  DB_USER
Value: postgres
```
Click "Add secret"

#### Secret #5: DB_PASSWORD
```
Name:  DB_PASSWORD
Value: PostgresSecure2024!@#
```
(Use this or create your own strong password)
Click "Add secret"

#### Secret #6: DB_NAME
```
Name:  DB_NAME
Value: content_db
```
Click "Add secret"

#### Secret #7: JWT_SECRET
```
Name:  JWT_SECRET
Value: jwt-blog-secret-2024-change-this
```
(Use this or create your own)
Click "Add secret"

**✅ After adding all 7, you should see them listed**

---

## PART 4: Test the Deployment

### Step 4.1: Commit and Push to GitHub

**On your local computer (NOT EC2), open Git Bash or PowerShell:**

```bash
# Navigate to your project
cd "d:\hashtek\new cicd\blog app\Blog-app"

# Add changes
git add .

# Commit
git commit -m "Initial GitHub Actions setup"

# Push to GitHub
git push origin main
```

### Step 4.2: Watch Deployment

1. Go to: https://github.com/Avivarma1/AVI_27_2_BLOG-APP/actions
2. You'll see a yellow dot = workflow running
3. Wait for all 3 jobs to turn green ✅

Expected timeline:
```
0:00 - Backend CI starts
2:30 - Frontend CI starts (parallel)
5:00 - Both CI jobs complete  
5:10 - Deploy to EC2 starts
15:00 - Deployment COMPLETE ✅
```

### Step 4.3: Access Your Application

After all jobs are green:

**Open browser and go to:**
```
http://13.220.246.205
```

You should see your React blog application! 🎉

**Test backend to confirm it's working:**
```
http://13.220.246.205:5000
```

---

## ✅ Verification Checklist

After deployment, verify these:

```bash
# SSH to EC2
ssh -i "your-key-pair.pem" ec2-user@13.220.246.205

# Check containers running
docker ps

# You should see 3 containers:
# - blog_frontend (Nginx)
# - blog_backend (Node.js)  
# - blog_db (PostgreSQL)

# View logs
docker-compose logs -f

# Test backend API
curl http://localhost:5000

# Test frontend
curl http://localhost:3000
```

---

# 📱 ACCESSING YOUR APPLICATION

### Frontend (React App)
```
http://13.220.246.205
- Your blog application
- Runs on Nginx
- Port 80
```

### Backend API
```
http://13.220.246.205:5000
- Or: http://13.220.246.205/api (through Nginx proxy)
- Node.js API server
- Port 5000
```

### API Endpoints (Test These)

**Register:**
```bash
curl -X POST http://13.220.246.205:5000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**Login:**
```bash
curl -X POST http://13.220.246.205:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"password123"}'
```

**Get Posts:**
```bash
curl http://13.220.246.205:5000/api/content
```

---

# 🐛 TROUBLESHOOTING

### Problem: "Can't connect to 13.220.246.205"
**Solution:**
- Check EC2 security group allows ports 80, 443, 22
- Verify EC2 instance is running
- Test ping: `ping 13.220.246.205`

### Problem: Pipeline shows RED X (Failed)
**Check logs:**
1. Go to Actions tab
2. Click the failed workflow
3. View which job failed
4. Read the error message

**Most common:**
- ❌ Invalid EC2_SSH_KEY → copy again carefully
- ❌ Wrong EC2_IP → verify it's exactly "13.220.246.205"
- ❌ SSH permissions → run setup script again

### Problem: "SSH connection refused"
**Solution:**
```bash
# SSH to EC2 manually first
ssh -i "your-key-pair.pem" ec2-user@13.220.246.205

# Then verify setup
ls -la ~/.ssh/
docker ps
```

### Problem: Containers won't start
**Check on EC2:**
```bash
docker-compose logs -f
docker ps -a
```

### Problem: Database error
**Check database:**
```bash
docker-compose logs db
docker-compose exec db psql -U postgres
```

---

# 📋 WHAT RUNS WHERE

```
Your Computer (Windows)
├─ Git repository
├─ Git push command
└─ Reads at: github.com

GitHub
├─ Receives your push
├─ Runs GitHub Actions workflow
└─ SSH connects to EC2

AWS EC2 (13.220.246.205)
├─ Receives deployment via SSH
├─ Pulls code from GitHub
├─ Builds Docker images
├─ Runs 3 containers:
│  ├─ PostgreSQL Database
│  ├─ Node.js Backend (port 5000)
│  └─ Nginx Frontend (port 80)
└─ Your app runs here!

Internet Users
└─ Access at: http://13.220.246.205
```

---

# 🎯 CURRENT STATUS

| Component | Status | Details |
|-----------|--------|---------|
| GitHub Actions Workflow | ✅ Ready | .github/workflows/deploy.yml |
| Docker on Windows | ⚠️ Install | Follow Step 1 above |
| EC2 Setup Script | ✅ Ready | Paste in Step 2.2 |
| SSH Keys | ⚠️ Generate | Generate in Step 2.3 |
| GitHub Secrets | ⚠️ Configure | Add 7 secrets in Step 3 |
| Git Push | ⚠️ Do | Step 4.1 |
| Deployment | ⚠️ Wait | 15 minutes (Step 4.2) |
| Application | ⚠️ Access | http://13.220.246.205 (Step 4.3) |

---

# ⚡ QUICK COMMAND REFERENCE

**SSH to EC2:**
```bash
ssh -i "your-key-pair.pem" ec2-user@13.220.246.205
```

**Check containers:**
```bash
docker ps
docker-compose ps
```

**View logs:**
```bash
docker-compose logs -f
docker-compose logs backend
docker-compose logs frontend
docker-compose logs db
```

**Restart services:**
```bash
docker-compose restart
docker-compose restart backend
```

**Stop all:**
```bash
docker-compose down
```

**Start again:**
```bash
docker-compose up -d
```

**Test API:**
```bash
curl http://13.220.246.205:5000
curl http://13.220.246.205
```

---

# 📝 SUMMARY

## What You Need to Do (In Order):

1. ✅ **Install Docker Desktop** on Windows (Step 1)
2. ✅ **SSH to EC2** and run setup script (Step 2.1-2.2)
3. ✅ **Generate SSH keys** on EC2 (Step 2.3)
4. ✅ **Add 7 GitHub Secrets** (Step 3)
5. ✅ **Push code to GitHub** (Step 4.1)
6. ✅ **Wait 15 minutes** for deployment (Step 4.2)
7. ✅ **Access your app** at http://13.220.246.205 (Step 4.3)

## Total Time:
- Docker install: 10 min
- EC2 setup: 10 min
- GitHub secrets: 5 min
- Deployment: 15 min
- **TOTAL: ~40 minutes**

## After That:
- Just run: `git push origin main`
- Wait 15 minutes
- Your app updates automatically! ✅

---

# 🎉 YOU'RE ALL SET!

Your blog app will be LIVE at:
## **http://13.220.246.205**

**Both Frontend AND Backend will run together in Docker containers!**

---

## ✅ Final Checklist

Before running:
- [ ] Docker Desktop installed
- [ ] EC2 instance ready (13.220.246.205)
- [ ] AWS key pair saved
- [ ] GitHub repository ready
- [ ] All 7 GitHub Secrets added

Then:
- [ ] SSH to EC2
- [ ] Run setup script
- [ ] Generate SSH keys
- [ ] Push code to GitHub
- [ ] Watch deployment
- [ ] Access your app!

---

**Everything is ready! Follow these steps and your app will be LIVE in ~40 minutes! 🚀**
