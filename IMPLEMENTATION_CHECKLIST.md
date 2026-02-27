# ✅ GitHub Actions Migration - Implementation Checklist

## 📋 Your Pipeline is Ready! Follow This Checklist

---

## PHASE 1: EC2 Instance Setup (Run on EC2)

### Step 1: Connect to EC2
```bash
# From your local machine (Windows, Mac, or Linux)
ssh -i your-aws-key-pair.pem ec2-user@13.220.246.205
```

- [ ] Successfully connected to EC2

### Step 2: Download and Run Setup Script
```bash
# On EC2 terminal
curl -O https://raw.githubusercontent.com/Avivarma1/AVI_27_2_BLOG-APP/main/ec2-setup.sh
chmod +x ec2-setup.sh
bash ec2-setup.sh
```

This installs:
- [ ] Node.js 18
- [ ] npm
- [ ] Docker
- [ ] Docker Compose
- [ ] PM2
- [ ] Git

**Verify installations:**
```bash
node --version       # Should show v18.x.x
npm --version
docker --version
docker-compose --version
git --version
pm2 --version
```

- [ ] All tools installed successfully

### Step 3: Generate SSH Key for GitHub
```bash
# Still on EC2
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_deploy_key -N ""

# Display private key (COPY THE ENTIRE OUTPUT)
cat ~/.ssh/github_deploy_key

# Add public key to authorized_keys
cat ~/.ssh/github_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

- [ ] Private key copied (for GitHub Secret EC2_SSH_KEY)
- [ ] Public key added to authorized_keys
- [ ] Permissions set correctly

### Step 4: Create Application Directory
```bash
mkdir -p /home/ec2-user/blog-app
cd /home/ec2-user/blog-app
```

- [ ] Application directory created

---

## PHASE 2: GitHub Secrets Configuration (GitHub.com)

### Step 1: Navigate to GitHub Secrets
1. Go to: https://github.com/Avivarma1/AVI_27_2_BLOG-APP
2. Click: **Settings** → **Secrets and variables** → **Actions**
3. Click: **New repository secret**

### Step 2: Add 7 Required Secrets

#### Secret 1: EC2_IP
- [ ] Name: `EC2_IP`
- [ ] Value: `13.220.246.205`
- [ ] Click: **Add secret**

#### Secret 2: EC2_USER
- [ ] Name: `EC2_USER`
- [ ] Value: `ec2-user`
- [ ] Click: **Add secret**

#### Secret 3: EC2_SSH_KEY
- [ ] Name: `EC2_SSH_KEY`
- [ ] Value: (paste entire private key from Step 1.3 above)
  ```
  -----BEGIN RSA PRIVATE KEY-----
  MIIEpAIBAAKCAQEA...
  ...
  -----END RSA PRIVATE KEY-----
  ```
- [ ] Click: **Add secret**

#### Secret 4: DB_USER
- [ ] Name: `DB_USER`
- [ ] Value: `postgres`
- [ ] Click: **Add secret**

#### Secret 5: DB_PASSWORD
- [ ] Name: `DB_PASSWORD`
- [ ] Value: Create a strong password (e.g., `PostgresSecure2024!@#`)
- [ ] Click: **Add secret**
- [ ] 📝 Save this password somewhere safe!

#### Secret 6: DB_NAME
- [ ] Name: `DB_NAME`
- [ ] Value: `content_db`
- [ ] Click: **Add secret**

#### Secret 7: JWT_SECRET
- [ ] Name: `JWT_SECRET`
- [ ] Value: Create a strong secret (e.g., `jwt-blog-app-secret-2024-change-me`)
- [ ] Click: **Add secret**
- [ ] 📝 Save this secret somewhere safe!

### Verification
After adding all 7 secrets, verify:
- [ ] EC2_IP
- [ ] EC2_USER
- [ ] EC2_SSH_KEY
- [ ] DB_USER
- [ ] DB_PASSWORD
- [ ] DB_NAME
- [ ] JWT_SECRET

All should appear in the Secrets list at:
https://github.com/Avivarma1/AVI_27_2_BLOG-APP/settings/secrets/actions

---

## PHASE 3: Test the Pipeline

### Step 1: Make a Test Commit
```bash
# On your local machine
git clone https://github.com/Avivarma1/AVI_27_2_BLOG-APP.git blog-app
cd blog-app

# Make a test change
echo "# Blog App - GitHub Actions Active!" > README.md

# Commit and push
git add README.md
git commit -m "Test: GitHub Actions pipeline"
git push origin main
```

- [ ] Code pushed to GitHub

### Step 2: Monitor Pipeline
1. Go to: https://github.com/Avivarma1/AVI_27_2_BLOG-APP/actions
2. Watch the workflow run in real-time
3. Each job should show:
   - 🟡 Yellow = Running
   - 🟢 Green = Passed
   - 🔴 Red = Failed

Expected timeline:
```
00:00 - Backend CI starts
02:30 - Frontend CI starts (parallel)
05:00 - Both CI jobs complete
05:10 - Deploy to EC2 job starts
15:00 - Deployment complete ✅
```

- [ ] Backend CI: PASSED 🟢
- [ ] Frontend CI: PASSED 🟢
- [ ] Deploy to EC2: PASSED 🟢

### Step 3: Verify Application
```bash
# Test frontend
curl http://13.220.246.205
# Should return HTML with React app

# Test backend
curl http://13.220.246.205:5000
# Should return backend response

# SSH to EC2 and check containers
ssh -i your-key ec2-user@13.220.246.205
docker ps
# Should show 3 containers running
```

- [ ] Frontend accessible at http://13.220.246.205
- [ ] Backend API accessible at http://13.220.246.205:5000
- [ ] All 3 Docker containers running
- [ ] Database responding to queries

---

## PHASE 4: Verify Pipeline Components

### Check Pipeline Configuration
- [ ] `.github/workflows/deploy.yml` exists
- [ ] File contains 3 jobs: backend_ci, frontend_ci, deploy_to_ec2
- [ ] Deployment only runs on main branch push
- [ ] SSH key setup configured correctly

### Check Docker Configuration
- [ ] `docker-compose.yml` includes EC2_PUBLIC_IP variable
- [ ] Frontend Dockerfile builds correctly
- [ ] Backend Dockerfile builds correctly
- [ ] Database initialization script exists

### Check Nginx Configuration  
- [ ] `frontend/nginx.conf` listenns on port 3000 (inside container)
- [ ] Container port 3000 mapped to host port 80
- [ ] API proxy configured at `/api/` location
- [ ] Frontend serves React static files

### Check Environment Variables
```bash
ssh -i your-key ec2-user@13.220.246.205
cd /home/ec2-user/blog-app
cat .env
```

Should contain:
- [ ] EC2_PUBLIC_IP=13.220.246.205
- [ ] DB_USER=postgres
- [ ] DB_PASSWORD=(your password)
- [ ] DB_NAME=content_db
- [ ] JWT_SECRET=(your secret)
- [ ] NODE_ENV=production
- [ ] VITE_API_URL=http://13.220.246.205

---

## PHASE 5: Documentation Review

Review the following documentation files in your repository:

- [ ] **GITHUB_ACTIONS_SETUP.md** - Setup procedures
- [ ] **GITHUB_ACTIONS_PIPELINE.md** - Complete pipeline docs
- [ ] **GITHUB_ACTIONS_ARCHITECTURE.md** - System architecture
- [ ] **PIPELINE_QUICK_GUIDE.md** - Quick reference
- [ ] **EC2_QUICK_COMMANDS.md** - Command reference
- [ ] **MIGRATION_SUMMARY.md** - Before/after comparison
- [ ] **.github/workflows/deploy.yml** - Workflow config

---

## PHASE 6: Regular Workflow

### For Future Deployments

**Simple Development Workflow:**
```bash
# Make changes locally
git checkout -b feature/new-feature
# Work on feature
git add .
git commit -m "Feature: description"
git push origin feature/new-feature

# Create PR for review
# After approval, merge to main
git checkout main
git pull origin main
git merge feature/new-feature
git push origin main

# ✅ Pipeline automatically deploys!
```

- [ ] Understand deployment workflow
- [ ] Know how to create branches
- [ ] Know how to merge PRs
- [ ] Know to check Actions tab for deploy status

### Monitoring Deployments

For each deployment:
1. Go to Actions tab
2. Watch pipeline progress
3. Check all 3 jobs pass
4. Verify app works

- [ ] Can monitor deployments
- [ ] Know where to find logs
- [ ] Know how to troubleshoot

---

## ⚠️ Important Notes

### Security
- [ ] Never commit secrets to GitHub
- [ ] Never share SSH private key
- [ ] Use strong passwords (DB_PASSWORD)
- [ ] Rotate JWT_SECRET periodically
- [ ] Restrict EC2 security group access

### Networking
- [ ] EC2 security group allows ports 80, 443, 22
- [ ] Database port 5432 is internal only
- [ ] Public IP accessible globally
- [ ] Nginx handles frontend and proxies API

### Maintenance
- [ ] Review logs regularly
- [ ] Update dependencies monthly
- [ ] Monitor disk space on EC2
- [ ] Keep SSH keys safe and backed up
- [ ] Document any customizations

---

## 🚨 Troubleshooting Checklist

### If Pipeline Fails at Backend CI
- [ ] Check npm dependencies in backend/package.json
- [ ] Verify no syntax errors in backend code
- [ ] Check test configuration
- [ ] Review backend CI logs in Actions tab

### If Pipeline Fails at Frontend CI
- [ ] Check npm dependencies in frontend/package.json
- [ ] Verify TypeScript compilation
- [ ] Check build output
- [ ] Review frontend CI logs in Actions tab

### If Pipeline Fails at Deploy to EC2
- [ ] Verify all 7 GitHub Secrets are configured
- [ ] Verify SSH key content (no extra spaces)
- [ ] Test SSH manually: `ssh -i key ec2-user@13.220.246.205`
- [ ] Check EC2 has Docker and docker-compose installed
- [ ] Review deploy logs for specific error

### If Application Won't Load
- [ ] SSH to EC2 and check: `docker ps`
- [ ] View logs: `docker-compose logs -f`
- [ ] Check .env file: `cat /home/ec2-user/blog-app/.env`
- [ ] Test backend: `curl http://localhost:5000`
- [ ] Test frontend: `curl http://localhost:3000`

### If Database Won't Connect
- [ ] Check database container: `docker ps | grep db`
- [ ] View database logs: `docker-compose logs db`
- [ ] Test connection: `docker-compose exec db psql -U postgres`
- [ ] Check port 5432 is not blocked

---

## ✅ Final Verification Checklist

Before considering setup complete:

**Git & Repository**
- [ ] Repository is on GitHub
- [ ] Main branch is default branch
- [ ] No uncommitted changes

**EC2 Instance**
- [ ] EC2 running and accessible
- [ ] All tools installed (Node, Docker, etc.)
- [ ] SSH key generated and configured
- [ ] Application directory created

**GitHub Secrets**
- [ ] All 7 secrets configured
- [ ] No typos in secret names
- [ ] Private key properly formatted with newlines
- [ ] Secrets visible in GitHub UI

**Docker Configuration**
- [ ] docker-compose.yml syntax valid
- [ ] All Dockerfiles present and valid
- [ ] Environment variables properly set
- [ ] Port mappings correct

**GitHub Actions Workflow**
- [ ] .github/workflows/deploy.yml exists
- [ ] YAML syntax valid
- [ ] 3 jobs defined (backend_ci, frontend_ci, deploy_to_ec2)
- [ ] Deployment condition: main branch only

**Application Testing**
- [ ] Pushed code to main branch
- [ ] Pipeline ran successfully
- [ ] All 3 jobs passed
- [ ] Frontend accessible at http://13.220.246.205
- [ ] Backend accessible at http://13.220.246.205:5000
- [ ] Database responding

**Documentation**
- [ ] All markdown files reviewed
- [ ] Documentation files in repository
- [ ] Troubleshooting guide understood
- [ ] Command reference bookmarked

---

## 🎉 Success Criteria

Your setup is complete when:

- ✅ Pipeline runs automatically on every push to main
- ✅ All 3 jobs (Backend CI, Frontend CI, Deploy) pass
- ✅ Application is live at http://13.220.246.205
- ✅ Frontend and backend both responding
- ✅ Database is running and connected
- ✅ No more CircleCI configuration
- ✅ All documentation reviewed

---

## 📞 Quick Reference

| Item | Value |
|------|-------|
| **Repository** | https://github.com/Avivarma1/AVI_27_2_BLOG-APP |
| **Pipeline Status** | https://github.com/Avivarma1/AVI_27_2_BLOG-APP/actions |
| **Secrets Config** | https://github.com/Avivarma1/AVI_27_2_BLOG-APP/settings/secrets/actions |
| **Application URL** | http://13.220.246.205 |
| **API URL** | http://13.220.246.205:5000 |
| **EC2 IP** | 13.220.246.205 |
| **EC2 User** | ec2-user |
| **Workflow File** | .github/workflows/deploy.yml |

---

## 🚀 You're All Set!

Once you check off all items above, your GitHub Actions CI/CD pipeline is:

✅ **Fully Configured**
✅ **Running Automatically**
✅ **Deploying to EC2**
✅ **Accessible via Public IP**
✅ **Production Ready**

**Start pushing code and deploying! 🎊**

---

## 📝 Notes Section

Use this space to document any customizations or changes:

```
Personal Notes:
_______________________________________________
_______________________________________________
_______________________________________________
_______________________________________________
```

---

**Last Updated:** February 27, 2026  
**Status:** Ready for Production  
**Next Review:** After first successful deployment
