# Quick Start Guide - Docker Deployment

## 🚀 Quick Setup (5 minutes)

### On Your EC2 Instance:

1. **SSH into your EC2 instance:**
   ```bash
   ssh -i your-key.pem ec2-user@100.52.231.27
   ```

2. **Clone or upload your code:**
   ```bash
   git clone your-repo
   cd Blog-app
   ```

3. **Configure environment (edit .env.docker):**
   ```bash
   nano .env.docker
   ```
   Change these values:
   - `DB_PASSWORD` - Set a strong password
   - `JWT_SECRET` - Set a secret key
   - `EC2_PUBLIC_IP` - Keep as 100.52.231.27

4. **Build and run:**
   ```bash
   docker-compose build --no-cache
   docker-compose up -d
   ```

5. **Wait 30 seconds for services to start, then access:**
   - Frontend: `http://100.52.231.27:3000`
   - Backend API: `http://100.52.231.27:5000/api/health`

---

## 🔧 Essential Commands

```bash
# View logs in real-time
docker-compose logs -f

# Check service status
docker-compose ps

# Stop everything
docker-compose down

# Restart all services
docker-compose restart

# View specific service logs
docker-compose logs -f backend
docker-compose logs -f frontend
docker-compose logs -f db
```

---

## 🐛 Common Issues & Solutions

### Issue: Services not starting
```bash
# Check full logs
docker-compose logs

# Rebuild images
docker-compose build --no-cache

# Start fresh
docker-compose down -v
docker-compose up -d
```

### Issue: Database not connecting
```bash
# Check database logs
docker-compose logs db

# Verify database is running
docker-compose ps db

# Check .env.docker credentials
cat .env.docker | grep DB_
```

### Issue: Frontend/Backend not communicating
```bash
# Check nginx logs
docker-compose logs frontend

# Test backend health
curl http://localhost:5000/api/health

# Check API calls in browser console
```

---

## 📝 Security Checklist

- [ ] Change `DB_PASSWORD` in `.env.docker`
- [ ] Change `JWT_SECRET` in `.env.docker`
- [ ] Configure AWS Security Groups for ports 3000 and 5000
- [ ] Enable HTTPS (see DOCKER_DEPLOYMENT.md)
- [ ] Don't commit `.env.docker` with real secrets

---

## 🔌 Check Connectivity

```bash
# Test backend API
curl http://100.52.231.27:5000/api/health

# Test frontend
curl http://100.52.231.27:3000

# Check if ports are open
sudo netstat -tulnp | grep -E '5000|3000'
```

---

## 📊 Monitoring

```bash
# View resource usage
docker stats

# View all containers
docker ps -a

# View images
docker images

# View volumes
docker volume ls
```

---

## 🚦 Deployment Status

After running `docker-compose up -d`, run this to verify all services are healthy:

```bash
docker-compose ps

# All services should show "Up" status
# Or use:
watch docker-compose ps
```

---

## 💾 Database Backup/Restore

```bash
# Backup database
docker-compose exec db pg_dump -U postgres content_db > backup_$(date +%Y%m%d_%H%M%S).sql

# Restore database
docker-compose exec -T db psql -U postgres content_db < backup.sql
```

---

## 🎯 Next Steps

1. ✅ Application deployed to EC2
2. 🔐 Set up proper secrets management
3. 🔒 Configure SSL/TLS certificate
4. 📊 Set up monitoring and logging
5. 🔄 Configure auto-restart on failure
6. 📈 Set up database backups
7. 🚀 Configure CI/CD pipeline

---

## 📚 Full Documentation

See [DOCKER_DEPLOYMENT.md](./DOCKER_DEPLOYMENT.md) for comprehensive guide.

---

## ✉️ Support

For issues, check:
1. Docker logs: `docker-compose logs`
2. Service health: `docker-compose ps`
3. Port availability: Check AWS Security Groups
4. Environment variables: Verify `.env.docker`
