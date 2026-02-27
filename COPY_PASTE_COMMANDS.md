# 🔥 COPY-PASTE COMMANDS - Nothing Else Needed!

## This file has EXACT commands. Just copy and paste them!

---

## 🖥️ PART 1: On Your Windows Computer

### 1. Open PowerShell
Press: Windows Key + R
Type: `powershell`
Press: Enter

### 2. Navigate to Your Project
```powershell
cd "d:\hashtek\new cicd\blog app\Blog-app"
```

### 3. Add Files
```powershell
git add .
```

### 4. Commit
```powershell
git commit -m "Setup GitHub Actions for EC2 deployment"
```

### 5. Push to GitHub
```powershell
git push origin main
```

**After this, GitHub Actions starts automatically! ✅**

---

## 🌐 PART 2: On Your EC2 Instance

### Before: Get Your Key Path
Find your AWS .pem key file path (e.g., `C:\Users\YourName\Downloads\mykey.pem`)

### 1. Open PowerShell

### 2. Connect to EC2 (Replace with YOUR key path)
```powershell
ssh -i "C:\Users\YourName\Downloads\mykey.pem" ec2-user@13.220.246.205
```

**If that doesn't work, use PuTTY:**
- Download: https://www.putty.org
- Load your .pem key in PuTTY
- Connect to: 13.220.246.205
- Username: ec2-user

---

## 📦 PART 3: On EC2 Terminal (Copy ALL of this at once)

```bash
#!/bin/bash
set -e
echo "====== Starting EC2 Setup ======"
sudo yum update -y
echo "Installing Node.js..."
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo yum install -y nodejs
echo "Installing Docker..."
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -a -G docker ec2-user
echo "Installing Docker Compose..."
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
echo "Installing Git..."
sudo yum install -y git
echo "Creating app directory..."
mkdir -p /home/ec2-user/blog-app
cd /home/ec2-user
echo "Cloning repository..."
git clone https://github.com/Avivarma1/AVI_27_2_BLOG-APP.git blog-app
echo "====== ✅ Setup Complete! ======"
echo "Versions:"
node --version
npm --version
docker --version
docker-compose --version
git --version
```

**👆 Paste ALL of that at once into EC2 terminal**

**Wait for it to finish (5-10 minutes)**

---

## 🔑 PART 4: Generate SSH Keys (Still on EC2 terminal)

### Copy and paste this:
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_deploy_key -N ""
echo "========== COPY EVERYTHING BELOW =========="
cat ~/.ssh/github_deploy_key
echo "========== COPY EVERYTHING ABOVE =========="
cat ~/.ssh/github_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
echo "✅ SSH keys ready!"
```

**Copy everything between the equals signs to use later**

---

## 🔐 PART 5: Configure GitHub Secrets (On GitHub.com)

### 1. Open This Link:
https://github.com/Avivarma1/AVI_27_2_BLOG-APP/settings/secrets/actions

### 2. Click "New repository secret" 7 times

#### Secret 1:
```
Name: EC2_IP
Value: 13.220.246.205
```
Click "Add secret"

#### Secret 2:
```
Name: EC2_USER
Value: ec2-user
```
Click "Add secret"

#### Secret 3:
```
Name: EC2_SSH_KEY
Value: [PASTE the private key from PART 4]
```
Click "Add secret"

#### Secret 4:
```
Name: DB_USER
Value: postgres
```
Click "Add secret"

#### Secret 5:
```
Name: DB_PASSWORD
Value: PostgresSecure2024!@#
```
Click "Add secret"

#### Secret 6:
```
Name: DB_NAME
Value: content_db
```
Click "Add secret"

#### Secret 7:
```
Name: JWT_SECRET
Value: jwt-blog-secret-2024
```
Click "Add secret"

---

## ⏰ PART 6: Watch Deployment

### 1. Go to GitHub Actions
https://github.com/Avivarma1/AVI_27_2_BLOG-APP/actions

### 2. You'll see the workflow running
- 🟡 Yellow = Running
- 🟢 Green = Done
- 🔴 Red = Failed

### 3. Wait ~15 minutes for all 3 jobs to complete

---

## 🎉 PART 7: Access Your Application

### After all jobs are GREEN:

**Open your browser and go to:**
```
http://13.220.246.205
```

**You should see your React blog app! 🎉**

---

## ✅ Verify Everything Works

### 1. SSH to EC2 again
```powershell
ssh -i "C:\Users\YourName\Downloads\mykey.pem" ec2-user@13.220.246.205
```

### 2. Check containers (on EC2)
```bash
docker ps
```

You should see 3 containers running:
- blog_frontend
- blog_backend
- blog_db

### 3. Test backend (on EC2)
```bash
curl http://localhost:5000
```

### 4. Test from your computer
Open browser:
```
http://13.220.246.205
http://13.220.246.205:5000
```

Both should work! ✅

---

## 🔧 Common Issues & Quick Fixes

### Issue: SSH key not found
**Fix:** Check path to your .pem file
```powershell
# Example correct path:
ssh -i "C:\Users\YourName\Downloads\your-key.pem" ec2-user@13.220.246.205
```

### Issue: Can't connect to EC2
**Use PuTTY instead:**
1. Download: https://www.putty.org
2. Load your .pem key
3. Connect to: 13.220.246.205

### Issue: Deployment failed
**Check GitHub Actions logs:**
1. Go to Actions tab
2. Click the failed job
3. Read the error message
4. Most likely: wrong secret value

### Issue: Docker containers won't start
```bash
# SSH to EC2
docker-compose logs -f
# Read the error
```

### Issue: Frontend shows blank page
```bash
# SSH to EC2
docker-compose restart frontend
docker-compose logs frontend
```

---

## 📱 After Deployment - Your App URLs

| Component | URL |
|-----------|-----|
| Frontend App | http://13.220.246.205 |
| Backend API | http://13.220.246.205:5000 |
| API Proxy | http://13.220.246.205/api |

---

## 🎯 What's Running on EC2

Inside Docker containers:
1. **Nginx** (Port 80) - Serves React frontend
2. **Node.js** (Port 5000) - Runs backend API
3. **PostgreSQL** (Port 5432) - Database

All 3 work together to create your full application!

---

## ⏱️ Timeline

```
0 min   - You push to GitHub
0+ min  - GitHub Actions starts
0-3 min - Backend CI job
0-5 min - Frontend CI job (parallel)
5-15 min - Deploy to EC2
15 min  - ✅ YOUR APP IS LIVE!
```

---

## 📋 Quick Checklist

- [ ] Docker Desktop installed
- [ ] EC2 setup script ran
- [ ] SSH keys generated
- [ ] 7 GitHub Secrets added
- [ ] Code pushed to GitHub
- [ ] Deployment completed (all green)
- [ ] App accessible at http://13.220.246.205

---

## 🚀 That's It!

Your Blog App is now:
✅ Fully deployed on EC2
✅ Running on public IP: 13.220.246.205
✅ Frontend and backend together
✅ Database connected
✅ Automated CI/CD with GitHub Actions

**Access: http://13.220.246.205**

---

## 📞 Still Need Help?

Read these files:
- **FINAL_COMPLETE_SETUP.md** - Detailed guide
- **IMPLEMENTATION_CHECKLIST.md** - Step-by-step
- **REFERENCE_CARD.md** - Quick reference

---

**Everything is ready! You're done! 🎉**

Just follow the commands above and your app will be LIVE! 🚀
