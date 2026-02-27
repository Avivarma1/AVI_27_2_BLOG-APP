# Quick Commands to Run on EC2

## Copy this entire section and paste into your EC2 terminal one at a time:

### Step 1: Download and Run Setup Script
```bash
curl -O https://raw.githubusercontent.com/Avivarma1/AVI_27_2_BLOG-APP/main/ec2-setup.sh
chmod +x ec2-setup.sh
bash ec2-setup.sh
```

### Step 2: Generate SSH Key for GitHub
```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/github_deploy_key -N ""
cat ~/.ssh/github_deploy_key
```
**👆 Copy the entire output above to use as GitHub Secret `EC2_SSH_KEY`**

### Step 3: Add Public Key to Authorized Keys
```bash
cat ~/.ssh/github_deploy_key.pub >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
chmod 700 ~/.ssh
```

### Step 4: Create Application Directory
```bash
mkdir -p /home/ec2-user/blog-app
cd /home/ec2-user
git clone https://github.com/Avivarma1/AVI_27_2_BLOG-APP.git blog-app
cd blog-app
```

### Step 5: Verify All Tools Are Installed
```bash
echo "=== Node.js ===" && node --version
echo "=== NPM ===" && npm --version
echo "=== Docker ===" && docker --version
echo "=== Docker Compose ===" && docker-compose --version
echo "=== Git ===" && git --version
echo "=== PM2 ===" && pm2 --version
```

---

## GitHub Secrets to Configure (go to: https://github.com/Avivarma1/AVI_27_2_BLOG-APP/settings/secrets/actions)

Add these 7 secrets:

1. **EC2_IP**: `13.220.246.205`
2. **EC2_USER**: `ec2-user`
3. **EC2_SSH_KEY**: (Paste the private key from Step 2 above)
4. **DB_USER**: `postgres`
5. **DB_PASSWORD**: (Use a strong password, e.g., `PostgresPass123!@#`)
6. **DB_NAME**: `content_db`
7. **JWT_SECRET**: (Use a strong secret, e.g., `jwt-secret-key-2024-change-this`)

---

## Test After Deployment

Once GitHub Actions successfully deploys:

```bash
# SSH into EC2
ssh -i your-key-pair.pem ec2-user@13.220.246.205

# Check running containers
docker ps

# View logs of all services
docker-compose logs -f

# Test backend API
curl http://localhost:5000
```

---

## If Something Goes Wrong

### Check Logs
```bash
cd /home/ec2-user/blog-app
docker-compose logs -f
docker-compose logs backend
docker-compose logs db
```

### Restart Services
```bash
docker-compose down
docker-compose up -d
docker-compose ps
```

### Check Disk Space
```bash
df -h
```

### Check Permissions
```bash
ls -la ~/.ssh/
chmod 600 ~/.ssh/github_deploy_key
chmod 700 ~/.ssh
```

---

## Access Your App

- **Frontend**: http://13.220.246.205
- **Backend API**: http://13.220.246.205:5000
- **Database**: localhost:5432 (from within containers)

---

## For Windows Users (Using PowerShell or WSL)

If you're on Windows without SSH installed, use WSL:

```bash
# In WSL or Git Bash
ssh -i path/to/your-key-pair.pem ec2-user@13.220.246.205
```

Or use PuTTY if you prefer GUI.
