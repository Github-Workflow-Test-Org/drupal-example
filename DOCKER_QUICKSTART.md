# Docker Quick Start - Vulnerable Drupal Example

## One-Command Setup

```bash
docker-compose up -d
```

That's it! The application will be available at **http://localhost:8080** in ~30 seconds.

---

## Access the Application

### Web Application
```
URL: http://localhost:8080
```

### Admin Login
```
URL: http://localhost:8080/user/login
Username: admin
Password: admin123
```

### MySQL Database (Optional)
```bash
docker-compose exec mysql mysql -u drupal_user -pdrupal_password vulnerable_drupal
```

---

## Common Commands

| Command | Purpose |
|---------|---------|
| `docker-compose up -d` | Start all services |
| `docker-compose down` | Stop all services |
| `docker-compose logs -f web` | View web server logs |
| `docker-compose ps` | Check service status |
| `docker-compose exec web bash` | Get shell in web container |
| `docker-compose down -v` | Stop and remove all data |

---

## Troubleshooting

**Services won't start?**
```bash
docker-compose logs
```

**Port 8080 in use?**
```bash
# Kill the process using port 8080
lsof -i :8080
kill -9 <PID>

# Or use different port in docker-compose.yml
```

**Want a fresh start?**
```bash
docker-compose down -v
docker-compose up -d
```

---

## Full Documentation

For detailed Docker information, see **DOCKER.md**

For local setup without Docker, see **SETUP_GUIDE.md**
