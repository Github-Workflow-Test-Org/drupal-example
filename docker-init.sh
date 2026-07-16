#!/bin/bash
set -e

echo "=== Vulnerable Drupal Docker Initialization ==="

# Wait for MySQL
echo "Waiting for MySQL to be ready..."
for i in $(seq 1 60); do
  if timeout 2 bash -c "echo > /dev/tcp/mysql/3306" 2>/dev/null; then
    echo "MySQL is ready!"
    break
  fi
  echo "  Attempt $i of 60..."
  sleep 2
done
sleep 2

cd /var/www/html

# Ensure directories exist and are writable
mkdir -p sites/default/files private config/sync
chmod 777 sites/default/files private
chmod 755 sites/default

# Check if Drupal is already installed
TABLE_COUNT=$(mysql -h mysql -u drupal_user -pdrupal_password vulnerable_drupal \
  -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='vulnerable_drupal';" \
  --skip-column-names 2>/dev/null || echo "0")

if [ "$TABLE_COUNT" -gt 10 ]; then
  echo "Drupal already installed ($TABLE_COUNT tables found), skipping install."
else
  echo "Installing Drupal (this takes ~60 seconds)..."

  # Create a minimal settings.php with DB credentials so drush can bootstrap
  chmod 777 sites/default
  cat > sites/default/settings.php << 'SETTINGS'
<?php
$databases['default']['default'] = [
  'driver' => 'mysql',
  'database' => 'vulnerable_drupal',
  'username' => 'drupal_user',
  'password' => 'drupal_password',
  'host' => 'mysql',
  'port' => '3306',
  'prefix' => '',
  'charset' => 'utf8mb4',
  'collation' => 'utf8mb4_unicode_ci',
  'namespace' => 'Drupal\\mysql\\Driver\\Database\\mysql',
  'autoload' => 'core/modules/mysql/src/Driver/Database/mysql/',
];
$settings['hash_salt'] = 'vulnerable-salt-string-for-testing-only';
$settings['config_sync_directory'] = '../config/sync';
SETTINGS
  chmod 666 sites/default/settings.php

  # Run drush site-install — it will expand settings.php and create all tables
  ./vendor/bin/drush site-install standard \
    --db-url="mysql://drupal_user:drupal_password@mysql/vulnerable_drupal" \
    --account-name=admin \
    --account-pass=admin123 \
    --site-name="Vulnerable Drupal - Security Testing" \
    --site-mail=admin@example.com \
    --locale=en \
    -y -vvv 2>&1

  echo "Drupal installed successfully!"

  # Append intentional vulnerability settings
  chmod 666 sites/default/settings.php
  cat >> sites/default/settings.php << 'VULN_SETTINGS'

// === INTENTIONAL SECURITY VULNERABILITIES FOR TESTING ===
// WARNING: Never use these settings in production

// VULN: Debug mode / verbose errors
$config['system.logging']['error_level'] = 'verbose';
error_reporting(E_ALL);
ini_set('display_errors', 1);

// VULN: Insecure session cookies
ini_set('session.cookie_secure', 0);
ini_set('session.cookie_httponly', 0);
ini_set('session.cookie_samesite', 'None');

// VULN: Allow all hosts (host-header injection)
$settings['trusted_host_patterns'] = ['^.+$'];

// VULN: Hardcoded weak encryption key
$settings['encrypt_key'] = 'weak-key-1234567890';

// VULN: Hardcoded credentials in source
define('VULNERABLE_API_KEY', 'sk-1234567890abcdefghijklmnop');
define('VULNERABLE_DB_PASS', 'admin_password_hardcoded_in_code');
VULN_SETTINGS

  chmod 444 sites/default/settings.php
  echo "Vulnerability settings applied!"
fi

echo ""
echo "=== Vulnerable Drupal is ready ==="
echo "  URL:   http://localhost:8080"
echo "  Login: admin / admin123"
echo ""
echo "Starting Apache..."
exec apache2-foreground
