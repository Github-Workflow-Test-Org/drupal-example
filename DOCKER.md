# Docker Setup Guide - Vulnerable Drupal Example

## Overview

This project includes Docker configuration for easy deployment and testing. The setup includes:
- **PHP 8.1 Apache** web server with all Drupal dependencies
- **MySQL 8.0** database server
- **Automatic database initialization** with test data
- **Health checks** for both services
- **Volume management** for persistent data

---

## Prerequisites

### Install Docker

**On macOS:**
```bash
# Using Homebrew
brew install docker docker-compose

# Or download Docker Desktop
# https://www.docker.com/products/docker-desktop
```

**On Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose

# Start Docker daemon
sudo systemctl start docker
```

**On Windows:**
- Download Docker Desktop from https://www.docker.com/products/docker-desktop
- Install and restart

### Verify Installation

```bash
docker --version
docker-compose --version
```

---

## Quick Start with Docker

### 1. Build and Start Services

```bash
docker-compose up -d
```

This will:
- Build the PHP/Apache image
- Start the web service on port 8080
- Start the MySQL service on port 3306
- Initialize the database with tables and test data
- Run health checks

### 2. Wait for Services to Be Ready

```bash
# Check service status
docker-compose ps

# Follow logs
docker-compose logs -f

# Or wait ~30 seconds and check
sleep 30 && docker-compose ps
```

Expected output when services are healthy:
```
STATUS: Up X seconds (healthy)
```

### 3. Access the Application

Open your browser and go to:
```
http://localhost:8080
```

### 4. Login to Admin Panel

**URL:** http://localhost:8080/user/login

**Credentials:**
- Username: `admin`
- Password: `admin123`

### 5. Stop Services

```bash
docker-compose down
```

---

## Docker Commands Reference

### Container Management

```bash
# Start services
docker-compose up -d

# Stop services (keep volumes)
docker-compose down

# Stop services and remove volumes (clean slate)
docker-compose down -v

# Rebuild and restart
docker-compose up -d --build

# View service status
docker-compose ps

# View running containers
docker ps
```

### Logs & Debugging

```bash
# View all logs
docker-compose logs

# Follow logs for web service
docker-compose logs -f web

# Follow logs for MySQL service
docker-compose logs -f mysql

# View logs from all services
docker-compose logs -f

# View last 50 lines
docker-compose logs --tail=50

# View logs from specific time
docker-compose logs --since 10m
```

### Service Access

```bash
# Open shell in web container
docker-compose exec web bash

# Open shell in MySQL container
docker-compose exec mysql bash

# Run command in web container
docker-compose exec web ls -la

# Execute PHP command
docker-compose exec web php -v

# Execute MySQL command
docker-compose exec mysql mysql -u drupal_user -pdrupal_password vulnerable_drupal
```

### Database Access

```bash
# Connect to MySQL database
docker-compose exec mysql mysql -u drupal_user -pdrupal_password vulnerable_drupal

# Inside MySQL, useful commands:
# SHOW TABLES;
# SELECT * FROM users_field_data;
# SELECT COUNT(*) FROM sessions;
```

### Volume & Data Management

```bash
# View volumes
docker volume ls

# Inspect volume
docker volume inspect vulnerable-drupal_mysql_data

# Check disk usage
docker system df

# Clean up unused resources
docker system prune
```

---

## Service Details

### Web Service (PHP Apache)

**Container Name:** `vulnerable-drupal-web`

**Configuration:**
- Image: PHP 8.1 with Apache
- Port: 8080 (mapped to 80 inside container)
- Volumes:
  - Project directory → `/var/www/html`
  - `sites/default/files` → `/var/www/html/sites/default/files`
- Working Directory: `/var/www/html`

**Environment Variables:**
```
DB_HOST=mysql
DB_USER=drupal_user
DB_PASSWORD=drupal_password
DB_NAME=vulnerable_drupal
```

**Health Check:**
- HTTP GET to `http://localhost/`
- Interval: 30 seconds
- Timeout: 10 seconds
- Retries: 3
- Start period: 30 seconds

### MySQL Service

**Container Name:** `vulnerable-drupal-mysql`

**Configuration:**
- Image: MySQL 8.0
- Port: 3306 (accessible externally)
- Volume: `mysql_data` (persistent storage)

**Credentials:**
- Root password: `root`
- Database: `vulnerable_drupal`
- User: `drupal_user`
- Password: `drupal_password`

**Health Check:**
- Command: `mysqladmin ping -h localhost`
- Interval: 30 seconds
- Timeout: 20 seconds
- Retries: 10

**Initialization:**
- Automatic via `init-db.sql`
- Creates all required tables
- Inserts test users and data

---

## Troubleshooting

### Services Won't Start

**Check Docker daemon:**
```bash
docker ps
# If error, restart Docker daemon
```

**Check logs:**
```bash
docker-compose logs
```

### Port Already in Use

If port 8080 or 3306 is already in use:

```bash
# Edit docker-compose.yml to use different ports
# Change "8080:80" to "8081:80"
# Change "3306:3306" to "3307:3306"

# Or kill existing process
# On macOS/Linux
lsof -i :8080
kill -9 <PID>
```

### Database Connection Failed

```bash
# Check MySQL is running
docker-compose ps mysql

# Check MySQL logs
docker-compose logs mysql

# Test connection
docker-compose exec mysql mysqladmin ping -h localhost

# Restart MySQL
docker-compose restart mysql
```

### Permission Denied Errors

```bash
# Fix file permissions
docker-compose exec web chown -R www-data:www-data /var/www/html
docker-compose exec web chmod -R 755 /var/www/html
docker-compose exec web chmod 644 /var/www/html/sites/default/settings.php
```

### Can't Access http://localhost:8080

```bash
# Verify web container is running
docker-compose ps web

# Check if port is mapped correctly
docker port vulnerable-drupal-web

# Try different port
# Edit docker-compose.yml ports section

# Check firewall
# macOS: System Preferences → Security & Privacy
# Windows: Windows Defender Firewall → Allow app through firewall
```

---

## Performance Tips

### Reduce Build Time

```bash
# Use existing images (don't rebuild)
docker-compose up -d

# Or rebuild if needed
docker-compose build --no-cache
```

### Speed Up Container Startup

```bash
# Pre-download images
docker pull php:8.1-apache
docker pull mysql:8.0

# Then start services
docker-compose up -d
```

### Optimize Database Performance

```bash
# Access MySQL and check queries
docker-compose exec mysql mysql -u root -proot

# Inside MySQL:
# SHOW PROCESSLIST;
# SHOW STATUS LIKE 'Queries';
```

---

## Development Workflow

### Edit Code Locally

Files are shared via volumes, so changes are reflected immediately:

```bash
# Edit file locally
vim modules/custom/vulnerable_auth/vulnerable_auth.module

# Changes visible in container immediately
docker-compose exec web cat /var/www/html/modules/custom/vulnerable_auth/vulnerable_auth.module
```

### Run Commands in Container

```bash
# Clear Drupal cache
docker-compose exec web drush cache:rebuild

# Run tests
docker-compose exec web bash test-application.sh

# View logs
docker-compose exec web tail -f /var/log/apache2/error.log
```

### Debug Inside Container

```bash
# Get shell access
docker-compose exec web bash

# Inside container:
# ls -la /var/www/html/
# php --version
# curl http://localhost/
# mysql -h mysql -u drupal_user -pdrupal_password -e "SELECT * FROM users_field_data;"
```

---

## Production Considerations

### Do NOT Use in Production

This configuration is for **development and testing only**:
- Debug mode is enabled
- Default credentials are used
- No HTTPS/SSL configured
- No resource limits set
- Logs are not rotated

### For Production Deployment

You would need:
- Multi-stage builds to reduce image size
- Environment-specific configurations
- SSL/TLS certificates
- Resource limits (CPU, memory)
- Log aggregation
- Backup strategies
- Security scanning
- Performance optimization

---

## Advanced Usage

### Custom MySQL Configuration

Edit `docker-compose.yml` to add custom MySQL options:

```yaml
mysql:
  command: --max_connections=1000 --log-error=/var/log/mysql/error.log
```

### Map Different Ports

```yaml
web:
  ports:
    - "8000:80"  # Now on 8000 instead of 8080

mysql:
  ports:
    - "3307:3306"  # Now on 3307 instead of 3306
```

### Add Environment Variables

```yaml
web:
  environment:
    - CUSTOM_VAR=value
    - ANOTHER_VAR=another_value
```

### Use .env File

Create `.env` file:
```
WEB_PORT=8080
DB_PORT=3306
DB_PASSWORD=drupal_password
```

Reference in `docker-compose.yml`:
```yaml
ports:
  - "${WEB_PORT}:80"
```

---

## Monitoring & Maintenance

### Check Resource Usage

```bash
# Overall Docker stats
docker stats

# Specific container
docker stats vulnerable-drupal-web

# Disk usage
docker system df

# Volume usage
du -sh /var/lib/docker/volumes/vulnerable-drupal_mysql_data/_data/
```

### Backup Database

```bash
# Backup MySQL database
docker-compose exec mysql mysqldump -u root -proot vulnerable_drupal > backup.sql

# Restore database
docker-compose exec -T mysql mysql -u root -proot vulnerable_drupal < backup.sql
```

### Clean Up

```bash
# Remove all stopped containers
docker container prune

# Remove unused volumes
docker volume prune

# Remove unused images
docker image prune

# Full cleanup (WARNING: removes all unused Docker data)
docker system prune -a
```

---

## Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Main project documentation |
| `DOCKER.md` | This file - Docker setup guide |
| `SETUP_GUIDE.md` | Local setup without Docker |
| `Dockerfile` | Docker image definition |
| `docker-compose.yml` | Multi-container orchestration |
| `init-db.sql` | Database initialization script |

---

## Support & References

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [PHP Docker Images](https://hub.docker.com/_/php)
- [MySQL Docker Images](https://hub.docker.com/_/mysql)
- [Drupal Security](https://www.drupal.org/security)

---

**Version**: 1.0  
**Last Updated**: June 12, 2026  
**Status**: Ready for Testing
