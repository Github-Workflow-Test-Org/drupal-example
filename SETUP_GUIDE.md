# Vulnerable Drupal Example - Setup & Usage Guide

## Project Overview

**vulnerable-drupal-example** is a fully functional Drupal 10 application with 40+ intentional security vulnerabilities designed for:
- ✅ Veracode vulnerability scanner testing and evaluation
- ✅ Security learning and awareness training  
- ✅ Demonstration of real-world security issues
- ✅ Penetration testing practice (in controlled environments)

**Location**: `/Users/himalayakumar/workspace/hworkspace/projects/php/drupal-example`

---

## Quick Setup

### 1. Prerequisites Check

```bash
# Verify installations
php --version          # Should be 8.1+
composer --version     # Should be 2.0+
mysql --version        # For database (optional)
```

### 2. Install Dependencies

```bash
cd /Users/himalayakumar/workspace/hworkspace/projects/php/drupal-example
composer install
```

Output should show:
- ✓ Drupal 10 core packages downloaded
- ✓ Custom modules detected
- ✓ All dependencies resolved
- ✓ Autoloader generated

### 3. Optional: Set Up Database

```bash
chmod +x install-drupal.sh
./install-drupal.sh
```

This creates:
- Database: `vulnerable_drupal`
- User: `drupal_user`
- Password: `drupal_password`

### 4. Start Web Server

```bash
php -S localhost:8080
```

Access the application at: **http://localhost:8080**

### 5. Admin Login

```
URL: http://localhost:8080/user/login
Username: admin
Password: admin123
```

---

## What's Included

### Core Files
| File | Purpose | Vulnerabilities |
|------|---------|-----------------|
| `sites/default/settings.php` | Drupal configuration | 9 |
| `sites/default/settings.local.php` | Local overrides | 2 |
| `install-drupal.sh` | Database setup script | Setup helper |
| `setup-drupal.sh` | Full Drupal setup | Setup helper |
| `test-application.sh` | Verification script | Testing helper |

### Custom Modules (3 modules, 27 vulnerabilities)

**1. vulnerable_auth** (10 vulnerabilities)
- Location: `modules/custom/vulnerable_auth/`
- Demonstrates: SQL injection, weak hashing, CSRF, session fixation, hardcoded credentials
- Key files:
  - `VulnerableLoginForm.php` - Login form with SQL injection
  - `AuthController.php` - Auth logic with weak validation
  - `vulnerable_auth.module` - IDOR vulnerability

**2. vulnerable_upload** (8 vulnerabilities)
- Location: `modules/custom/vulnerable_upload/`
- Demonstrates: Path traversal, XXE, insecure permissions, race conditions
- Key files:
  - `UploadController.php` - Upload handler with path traversal
  - `vulnerable_upload.module` - Insecure file operations

**3. vulnerable_api** (9 vulnerabilities)
- Location: `modules/custom/vulnerable_api/`
- Demonstrates: SQL injection, XXE, CORS issues, missing authentication
- Key files:
  - `ApiController.php` - REST endpoints with SQL injection
  - `vulnerable_api.routing.yml` - Route definitions

### Custom Theme (1 theme, 5 vulnerabilities)

**vulnerable_theme**
- Location: `themes/custom/vulnerable_theme/`
- Demonstrates: XSS (reflected & stored), missing CSRF tokens
- Key files:
  - `templates/page.html.twig` - Page template with XSS
  - `templates/comment.html.twig` - Comment template with stored XSS

---

## Vulnerability Categories

### By Type (40+ Total)

**Configuration & Credentials (9)**
- Hardcoded database passwords
- Exposed environment variables
- Debug mode enabled
- Weak encryption

**Injection Attacks (10)**
- SQL injection (multiple locations)
- XML External Entity (XXE) injection
- Path traversal
- HTML injection

**Cross-Site Scripting (5)**
- Unescaped output
- Reflected XSS
- Stored XSS
- Missing CSRF tokens

**Weak Cryptography (3)**
- MD5 password hashing
- Weak token validation
- Weak password validation

**Access Control (8)**
- Missing authentication
- No rate limiting
- CORS misconfiguration
- IDOR vulnerabilities

**File Upload Issues (5)**
- No file type validation
- Executable uploads
- Insecure permissions
- Race conditions

---

## Testing with Veracode

### Preparing for Scan

1. **Exclude External Code**
   ```
   vendor/       # Contains third-party packages
   web/core/     # Drupal core
   ```

2. **Include Custom Code**
   ```
   modules/custom/
   themes/custom/
   sites/default/
   ```

3. **Upload to Veracode**
   ```bash
   # Package the application
   zip -r vulnerable-drupal-example.zip \
     modules/custom/ \
     themes/custom/ \
     sites/default/ \
     composer.json \
     *.php
   
   # Upload to Veracode platform
   # https://www.veracode.com
   ```

### Expected Findings

Veracode should report findings across OWASP Top 10:

| OWASP | CWE | Expected Count |
|-------|-----|----------------|
| A01 - Broken Access Control | CWE-639 | 1+ |
| A02 - Cryptographic Failures | CWE-326 | 3+ |
| A03 - Injection | CWE-89, CWE-611 | 5+ |
| A04 - Insecure Design | CWE-434 | 2+ |
| A05 - Security Misconfiguration | CWE-798 | 3+ |
| A07 - Identification & Auth | CWE-352 | 2+ |
| A08 - Software & Data Integrity | CWE-502 | 1+ |
| A09 - Logging & Monitoring | CWE-532 | 2+ |

Total expected findings: **25-30 critical/high severity**

---

## Application Routes

| Route | Method | Purpose | Vulnerabilities |
|-------|--------|---------|-----------------|
| `/user/login` | GET/POST | Admin login | SQL injection |
| `/api/user/1` | GET | Get user | SQL injection |
| `/api/search?q=test` | GET | Search users | SQL injection |
| `/api/user/create` | POST | Create user | CORS, No validation |
| `/admin` | GET | Admin dashboard | IDOR |

---

## Troubleshooting

### Composer Install Fails
```bash
# Disable security advisories (safe for vulnerable project)
composer config policy.advisories.block false
composer install
```

### Database Connection Fails
```bash
# Verify MySQL is running
mysql -u root -proot -e "SELECT 1"

# Re-run setup script
./install-drupal.sh
```

### Permission Errors
```bash
# Make scripts executable
chmod +x install-drupal.sh setup-drupal.sh test-application.sh

# Fix file permissions
chmod -R 755 sites/default/
chmod 644 sites/default/settings.php
```

---

## Verification

Run the test script to verify all components:

```bash
bash test-application.sh
```

Expected output:
```
✓ Composer files present
✓ Settings files found
✓ Module vulnerable_auth found
✓ Module vulnerable_upload found
✓ Module vulnerable_api found
✓ Theme found
✓ Templates found
✓ README.md found
✓ Vulnerability documentation present
✓ Found 42 vulnerability markers (expected 40+)

All Tests Passed!
Application is ready for Veracode scanning
```

---

## Documentation Files

| File | Purpose |
|------|---------|
| `README.md` | Main project overview |
| `VULNERABILITIES.txt` | Quick vulnerability reference |
| `SETUP_GUIDE.md` | This file - setup & usage instructions |

---

## Security Notes

⚠️ **IMPORTANT**

- **DO NOT USE IN PRODUCTION** - This application intentionally contains security flaws
- **For testing only** - Use only in controlled, authorized environments
- **Legal disclaimer** - Unauthorized security testing is illegal. Use only on systems you own or have permission to test
- **Data safety** - Do not store sensitive data in this application

---

## References

- [OWASP Top 10 - 2021](https://owasp.org/www-project-top-ten/)
- [CWE/SANS Top 25](https://cwe.mitre.org/top25/)
- [Drupal Security](https://www.drupal.org/security)
- [Veracode Documentation](https://www.veracode.com/documentation)
- [PHP Security Best Practices](https://www.php.net/manual/en/security.php)

---

**Version**: 1.0  
**Created**: June 12, 2026  
**Status**: Ready for Testing  
**Project Path**: `/Users/himalayakumar/workspace/hworkspace/projects/php/drupal-example`
