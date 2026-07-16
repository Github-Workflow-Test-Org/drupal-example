# Vulnerable Drupal Example

A comprehensive Drupal 10 application intentionally built with **40+ security vulnerabilities** for Veracode scanning and security learning.

⚠️ **WARNING: NOT FOR PRODUCTION** - This application contains intentional security flaws for testing purposes only.

## Quick Start

### Option A: Using Docker (Recommended)

**Prerequisites:**
- Docker
- Docker Compose

**Installation & Start:**

```bash
# 1. Build and start containers
docker-compose up -d

# 2. Wait for services to be healthy (30-60 seconds)
docker-compose logs -f

# 3. Access the application
# URL: http://localhost:8080

# 4. Login
# URL: http://localhost:8080/user/login
# Username: admin
# Password: admin123
```

**Useful Docker Commands:**

```bash
# View logs
docker-compose logs -f web

# Stop services
docker-compose down

# Stop and remove volumes (clean slate)
docker-compose down -v

# Rebuild after code changes
docker-compose up -d --build

# Access MySQL database
docker-compose exec mysql mysql -u drupal_user -pdrupal_password vulnerable_drupal

# Access web container shell
docker-compose exec web bash
```

### Option B: Local Installation

**Prerequisites:**
- PHP 8.1+
- MySQL/MariaDB
- Composer
- Git

**Installation & Start:**

```bash
# 1. Install dependencies
composer install

# 2. Set up database
chmod +x install-drupal.sh
./install-drupal.sh

# 3. Start web server
php -S localhost:8080

# 4. Access admin
# URL: http://localhost:8080/user/login
# Username: admin
# Password: admin123
```

## Complete Vulnerability Map (40+ Items)

### Configuration & Settings Issues (9)
- Debug mode enabled in production
- Hardcoded database credentials
- Exposed environment variables  
- Overpermissive file permissions
- Insecure session cookie settings
- Weak encryption key
- Default admin credentials documented
- Allow all hosts pattern
- Error messages expose database

### Authentication & Access Control (8)
- MD5 password hashing (weak)
- Weak API token validation
- Session fixation vulnerability
- Insecure direct object reference (IDOR)
- Missing authentication on endpoints
- No rate limiting
- Weak password validation
- Insecure deserialization

### Injection Vulnerabilities (10)
- SQL injection in login form (3 instances)
- XXE in file upload
- XXE in API XML processing
- Path traversal in upload
- HTML injection in theme

### Cross-Site Scripting (5)
- Unescaped output in templates (2)
- Reflected XSS in search
- Stored XSS in comments
- Missing CSRF tokens (2)

### File Upload Issues (5)
- No file type validation
- Executable file upload allowed
- Insecure file permissions (0777)
- Race condition in deletion
- Temp files world-readable

### API & Data Issues (5)
- CORS misconfiguration
- No input validation
- Sensitive data logging
- Sensitive data in API response
- Hardcoded API keys

## Docker Configuration

### Files Included

| File | Purpose |
|------|---------|
| `Dockerfile` | Builds PHP 8.1 Apache image with all dependencies |
| `docker-compose.yml` | Orchestrates web and MySQL services |
| `init-db.sql` | Initializes database with tables and test data |

### Services

**Web Service (vulnerable-drupal-web)**
- PHP 8.1 with Apache
- Runs on port 8080
- Volume: `/var/www/html` mapped to project root
- Depends on MySQL being healthy

**MySQL Service (vulnerable-drupal-mysql)**
- MySQL 8.0
- Port 3306 exposed (for external access)
- Database: `vulnerable_drupal`
- User: `drupal_user` / `drupal_password`
- Volume: `mysql_data` for persistent storage

### Environment Variables

Both services use environment variables for configuration:
- `DB_HOST`: mysql
- `DB_USER`: drupal_user
- `DB_PASSWORD`: drupal_password
- `DB_NAME`: vulnerable_drupal

### Health Checks

Both services have health checks configured:
- **Web**: HTTP GET to `/` every 30 seconds
- **MySQL**: `mysqladmin ping` every 30 seconds

### Volumes

- `mysql_data`: Persists MySQL database between container restarts
- `.:/var/www/html`: Project files mounted in web container
- `./sites/default/files:/var/www/html/sites/default/files`: Drupal files directory

### Networking

Services communicate via `vulnerable-drupal-network` bridge network. Both containers can reach each other by service name (e.g., `mysql` for database host).

## Testing with Veracode

### What to Include in the Scan

Only upload **your custom code** — not Drupal framework files. The entire application lives at `/var/www/html` inside the container, but the vast majority is Drupal core and third-party packages that are not your code.

**Directory layout inside the container:**

```
/var/www/html/
├── core/                        ← SKIP  Drupal framework (~100 MB)
├── vendor/                      ← SKIP  Composer packages (~150 MB)
├── modules/
│   ├── contrib/                 ← SKIP  Downloaded Drupal modules
│   └── custom/                  ← INCLUDE  Your custom code
│       ├── vulnerable_api/
│       ├── vulnerable_auth/
│       └── vulnerable_upload/
├── themes/
│   ├── contrib/                 ← SKIP  Downloaded themes
│   └── custom/                  ← INCLUDE  Your custom code
│       └── vulnerable_theme/
├── sites/
│   └── default/
│       ├── settings.php         ← SKIP  Generated at runtime by Drush
│       ├── docker-settings.php  ← INCLUDE  Your intentional vulnerability settings
│       ├── settings.local.php   ← INCLUDE  Your intentional vulnerability settings
│       └── files/               ← SKIP  User-uploaded files
├── index.php                    ← SKIP  Drupal scaffolded entry point
├── autoload.php                 ← SKIP  Drupal scaffolded
└── ...                          ← SKIP  All other root files are Drupal scaffolding
```

**Summary — only these paths contain your code:**

| Path | What it is |
|------|-----------|
| `modules/custom/vulnerable_api/` | REST API with SQL injection, CORS, hardcoded credentials |
| `modules/custom/vulnerable_auth/` | Login with SQL injection, weak hashing, session fixation |
| `modules/custom/vulnerable_upload/` | File upload with path traversal, XXE, insecure permissions |
| `themes/custom/vulnerable_theme/` | Templates with XSS and missing CSRF tokens |
| `sites/default/docker-settings.php` | Intentional config vulnerabilities (debug mode, weak crypto, etc.) |
| `sites/default/settings.local.php` | Additional intentional config vulnerabilities |

### Preparing the Scan Package

Run this from the project root to create a clean ZIP containing only your custom code:

```bash
zip -r veracode-scan.zip \
  modules/custom/ \
  themes/custom/ \
  sites/default/docker-settings.php \
  sites/default/settings.local.php
```

Or from inside the container:

```bash
docker-compose exec web bash -c "cd /var/www/html && zip -r /tmp/veracode-scan.zip modules/custom/ themes/custom/ sites/default/docker-settings.php sites/default/settings.local.php"
docker cp vulnerable-drupal-web:/tmp/veracode-scan.zip ./veracode-scan.zip
```

Upload `veracode-scan.zip` to Veracode and configure the scan for **PHP**.

### Frequently Asked Questions About Packaging

#### Does every Drupal project have this same structure?

Yes. The directory layout is standard across all Drupal 8/9/10 projects and is enforced by Drupal itself:

```
core/              ← always Drupal's own framework code
vendor/            ← always Composer-managed third-party packages
modules/
  contrib/         ← always where downloaded community modules go
  custom/          ← always where YOUR application modules go
themes/
  contrib/         ← always where downloaded community themes go
  custom/          ← always where YOUR application themes go
sites/default/     ← always where settings.php lives
```

Custom modules must follow a strict layout too — Drupal won't recognize a module that deviates from it:

```
modules/custom/my_module/
  my_module.info.yml        ← required: module metadata
  my_module.routing.yml     ← defines URL routes
  src/Controller/           ← request handlers
  src/Form/                 ← form definitions
```

This means **the same packaging rule applies to any Drupal 10 project**: include only `modules/custom/`, `themes/custom/`, and any custom settings files. Skip everything else.

#### What about Drupal 7 projects?

Drupal 7 uses a different structure — if you ever scan a Drupal 7 project, the custom code lives at:

```
sites/all/modules/custom/   ← custom modules (not modules/custom/)
sites/all/themes/custom/    ← custom themes (not themes/custom/)
```

Drupal 7 also does not use Composer or the `src/Controller/` object-oriented pattern. Our project is **Drupal 10** — the modern standard.

#### What varies between Drupal projects?

| Thing | How it varies |
|---|---|
| Drupal version | 7, 8, 9, or 10 — affects directory layout (see above) |
| Web root location | Some projects put everything under a `web/` subfolder |
| Contributed modules | Each project picks different community modules |
| Number of custom modules | Could be 1 or 100 depending on the application |
| Hosting/deploy tooling | Acquia, Pantheon, self-hosted all use different tools |

Regardless of these differences, **your custom code is always in `modules/custom/` and `themes/custom/`** — that never changes in Drupal 8/9/10.

#### How can I tell if an unknown project is Drupal?

These are the strongest indicators to look for when examining an unfamiliar codebase:

**1. `index.php` contains `DrupalKernel`**

The single biggest indicator. No other framework uses this:
```php
use Drupal\Core\DrupalKernel;
$kernel = new DrupalKernel('prod', $autoloader);
```

**2. `.info.yml` files inside modules or themes**

Every Drupal module and theme has one with this exact format:
```yaml
type: module
core_version_requirement: ^10.0
```
The `core_version_requirement` field is Drupal-specific.

**3. `sites/default/settings.php` with `$databases` array**

The `sites/` directory with this exact PHP array syntax is unique to Drupal:
```php
$databases['default']['default'] = [
  'driver' => 'mysql',
  ...
];
```

**4. `modules/`, `themes/`, `profiles/` directories at project root**

This exact trio at the root level is Drupal's signature layout.

**5. `autoload.php` generated by `drupal-scaffold`**

The comment inside says:
```php
// This file was generated by drupal-scaffold.
```

**6. `composer.json` references Drupal packages**

```json
"drupal/core-recommended": "^10.0",
"drupal/core-composer-scaffold": "^10.0"
```

**Quick identification checklist:**

| File / Pattern | Confidence |
|---|---|
| `use Drupal\Core\DrupalKernel` in `index.php` | 100% Drupal |
| `*.info.yml` with `core_version_requirement` | 100% Drupal |
| `sites/default/settings.php` with `$databases[][]` | 99% Drupal |
| `modules/` + `themes/` + `profiles/` at project root | 95% Drupal |
| `drupal/core-*` in `composer.json` | 100% Drupal |

If you see **any one** of these it is a Drupal project. If you see all five, it is definitely Drupal 8/9/10.

### Expected Findings

Veracode should detect vulnerabilities in:
- CWE-79 (XSS) - 5+ findings
- CWE-89 (SQL Injection) - 3+ findings
- CWE-798 (Hardcoded Credentials) - 3+ findings
- CWE-611 (XXE) - 2+ findings
- CWE-352 (CSRF) - 2+ findings
- CWE-502 (Deserialization) - 1+ finding
- CWE-326 (Weak Crypto) - 3+ findings
- CWE-434 (File Upload) - 2+ findings
- And more OWASP Top 10 categories

## Module Overview

| Module | Vulnerabilities | Files |
|--------|-----------------|-------|
| **vulnerable_auth** | SQL injection, weak hashing, CSRF, session fixation | 4 files |
| **vulnerable_upload** | Path traversal, XXE, insecure permissions | 3 files |
| **vulnerable_api** | SQL injection, XXE, CORS misconfiguration | 3 files |
| **vulnerable_theme** | XSS (reflected/stored), missing CSRF | 2 templates |

## OWASP Top 10 Coverage

- ✓ A01:2021 - Broken Access Control
- ✓ A02:2021 - Cryptographic Failures
- ✓ A03:2021 - Injection
- ✓ A04:2021 - Insecure Design
- ✓ A05:2021 - Security Misconfiguration
- ✓ A07:2021 - Identification & Authentication
- ✓ A08:2021 - Software & Data Integrity
- ✓ A09:2021 - Logging & Monitoring

## Files & Structure

```
vulnerable-drupal-example/
├── composer.json
├── composer.lock
├── Dockerfile                      # Docker image definition
├── docker-compose.yml              # Multi-container setup
├── init-db.sql                     # Database initialization
├── README.md
├── SETUP_GUIDE.md
├── VULNERABILITIES.txt
├── install-drupal.sh
├── setup-drupal.sh
├── test-application.sh
├── sites/default/
│   ├── settings.php (9 vulnerabilities)
│   ├── settings.local.php (2 vulnerabilities)
│   └── files/ (upload directory)
├── modules/custom/
│   ├── vulnerable_auth/ (10 vulnerabilities)
│   ├── vulnerable_upload/ (8 vulnerabilities)
│   └── vulnerable_api/ (9 vulnerabilities)
└── themes/custom/
    └── vulnerable_theme/ (5 vulnerabilities)
```

## References

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
- [Drupal Security](https://www.drupal.org/security)
- [Veracode Documentation](https://www.veracode.com)

---

**Version**: 1.0  
**Status**: Ready for Veracode Testing  
**Created**: June 12, 2026
