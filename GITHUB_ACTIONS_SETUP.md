# GitHub Actions Setup Guide

## Overview
This guide will help you set up automated CI/CD deployment from GitHub to your EC2 instance for the Blog App.

---

## Step 1: Prepare Your EC2 Instance

### 1.1 Connect to Your EC2 Instance
```bash
# Using SSH from your local machine (or WSL on Windows)
ssh -i your-key-pair.pem ec2-user@13.220.246.205
```

### 1.2 Run the Setup Script
Once connected to EC2, download and run the setup script:

```bash
# Download the setup script
curl -O https://raw.githubusercontent.com/Avivarma1/AVI_27_2_BLOG-APP/main/ec2-setup.sh

# Make it executable
chmod +x ec2-setup.sh

# Run the setup script
bash ec2-setup.sh
```

This will install:
- ✅ Node.js v18
- ✅ npm
- ✅ PM2 (process manager)
- ✅ Git
- ✅ Docker & Docker Compose
- ✅ PostgreSQL client

### 1.3 Verify Installation
```bash
# Test installed tools
node --version      # Should show v18.x.x
npm --version
docker --version
docker-compose --version
pm2 --version
```

---

## Step 2: Generate SSH Key for GitHub Actions

### 2.1 Create an SSH Key Pair (if you don't have one)
```bash
# On your EC2 instance
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_deploy_key -N ""

# Display the private key (you'll need this for GitHub)
cat ~/.ssh/github_deploy_key

# Add public key to authorized_keys
cat ~/.ssh/github_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### 2.2 Copy the Private Key
Copy the entire output from `cat ~/.ssh/github_deploy_key` to use in the next step.

---

## Step 3: Configure GitHub Secrets

### 3.1 Go to GitHub Repository Settings
1. Navigate to your repository: https://github.com/Avivarma1/AVI_27_2_BLOG-APP
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**

### 3.2 Add the Following Secrets

Create these secrets one by one:

| Secret Name | Value | Example |
|------------|-------|---------|
| `EC2_IP` | Your EC2 public IPv4 | `13.220.246.205` |
| `EC2_USER` | EC2 instance user | `ec2-user` (for Amazon Linux) |
| `EC2_SSH_KEY` | Private SSH key (entire content) | (paste your private key) |
| `DB_USER` | Database user | `postgres` |
| `DB_PASSWORD` | Database password (secure!) | `MySecurePassword123!` |
| `DB_NAME` | Database name | `content_db` |
| `JWT_SECRET` | JWT secret for authentication | `your-super-secret-jwt-key-change-this` |

**⚠️ Important: Keep all secrets secure. Never share them!**

---

## Step 4: Push Code to Trigger Deployment

### 4.1 Make a Commit and Push
```bash
# In your local repository
git add .
git commit -m "Setup GitHub Actions workflow"
git push origin main
```

### 4.2 Monitor the Deployment
1. Go to your GitHub repository
2. Click **Actions** tab
3. You'll see your workflow running
4. Wait for all jobs to complete (Backend CI → Frontend CI → Deploy to EC2)

---

## Step 5: Verify Deployment on EC2

### 5.1 SSH into EC2 and Check Containers
```bash
# SSH into your EC2 instance
ssh -i your-key-pair.pem ec2-user@13.220.246.205

# Check running containers
docker ps

# View logs
docker-compose logs -f

# Check specific service logs
docker-compose logs backend
docker-compose logs frontend
docker-compose logs db
```

### 5.2 Test the Application
```bash
# Test backend API
curl http://localhost:5000

# Test database connection
docker-compose exec db psql -U postgres -d content_db -c "SELECT version();"

# Check PM2 processes (if running with PM2 instead)
pm2 list
```

---

## Step 6: Access Your Application

### Frontend (Nginx)
```
http://13.220.246.205
```

### Backend API
```
http://13.220.246.205:5000
```

### API Endpoints
```
POST   /api/auth/register
POST   /api/auth/login
GET    /api/content
POST   /api/content
GET    /api/content/:id
PUT    /api/content/:id
DELETE /api/content/:id
```

---

## Troubleshooting

### Issue: Deployment fails with "Permission denied"
**Solution:** Make sure the SSH key is added correctly to authorized_keys on EC2:
```bash
cat ~/.ssh/github_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
```

### Issue: Database won't start
**Solution:** Check PostgreSQL logs:
```bash
docker-compose logs db
```

### Issue: Backend can't connect to database
**Solution:** Verify the .env file was created correctly:
```bash
cat /home/ec2-user/blog-app/.env
```

### Issue: Docker compose command not found
**Solution:** Reinstall Docker Compose:
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

### Issue: Port 5000 already in use
**Solution:** Kill the process using the port:
```bash
sudo lsof -i :5000
sudo kill -9 <PID>
```

---

## Re-deployment After Code Changes

Just push to main branch:
```bash
git add .
git commit -m "Your changes"
git push origin main
```

The GitHub Actions workflow will automatically:
1. ✅ Build backend and run tests
2. ✅ Build frontend
3. ✅ Deploy to EC2
4. ✅ Start containers
5. ✅ Run database migrations (if any)

---

## Manual Deployment (if GitHub Actions fails)

If you need to deploy manually:

```bash
# SSH to EC2
ssh -i your-key-pair.pem ec2-user@13.220.246.205

# Go to application directory
cd /home/ec2-user/blog-app

# Pull latest code
git pull origin main

# Update containers
docker-compose down
docker-compose up -d

# Check status
docker-compose ps
```

---

## Useful Command Reference

```bash
# View logs
docker-compose logs -f

# Restart a service
docker-compose restart backend

# Rebuild containers
docker-compose build --no-cache

# Stop all containers
docker-compose down

# Remove everything (database data too!)
docker-compose down -v

# SSH key permissions (if needed)
chmod 600 ~/.ssh/github_deploy_key
```

---

## Security Best Practices

1. ✅ Never commit secrets to GitHub
2. ✅ Use strong database passwords
3. ✅ Rotate JWT secrets regularly
4. ✅ Limit SSH key permissions (chmod 600)
5. ✅ Use Security Groups to restrict EC2 access
6. ✅ Enable GitHub branch protection rules
7. ✅ Regularly update dependencies: `npm audit fix`

---

## Next Steps

1. ✅ Run `ec2-setup.sh` on your EC2 instance
2. ✅ Generate and add SSH keys
3. ✅ Configure GitHub Secrets
4. ✅ Push code to trigger deployment
5. ✅ Monitor deployment in GitHub Actions
6. ✅ Verify services on EC2
7. ✅ Test your application

Need help? Check the GitHub Actions logs or EC2 container logs!
