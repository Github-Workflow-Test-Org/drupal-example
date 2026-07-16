<?php

// Docker-specific Drupal settings

// Database configuration for Docker
$databases['default']['default'] = array(
  'driver' => 'mysql',
  'database' => getenv('DB_NAME') ?: 'vulnerable_drupal',
  'username' => getenv('DB_USER') ?: 'drupal_user',
  'password' => getenv('DB_PASSWORD') ?: 'drupal_password',
  'host' => getenv('DB_HOST') ?: 'mysql',
  'port' => getenv('DB_PORT') ?: 3306,
  'prefix' => '',
  'charset' => 'utf8mb4',
  'collation' => 'utf8mb4_unicode_ci',
);

// VULNERABILITY 1: Debug mode enabled in production
$settings['debug'] = TRUE;
$config['system.logging']['error_level'] = 'verbose';

// VULNERABILITY 2: Hardcoded database credentials in source code
// (already documented in docker-compose.yml)

// VULNERABILITY 3: Default Drupal admin credentials documented
// Admin user: admin, Password: admin123 (DO NOT USE IN PRODUCTION)

// VULNERABILITY 4: Exposed environment variables
putenv('DB_HOST=mysql');
putenv('DB_USER=drupal_user');
putenv('DB_PASS=drupal_password');

// VULNERABILITY 5: Overpermissive file permissions
$settings['file_public_path'] = 'sites/default/files';
$settings['file_private_path'] = '../private';
$settings['file_temporary_path'] = '/tmp';

// VULNERABILITY 6: Disabled security updates
$settings['update_free_access'] = FALSE;

// VULNERABILITY 7: Insecure hash settings
$settings['hash_algorithm'] = 'md5';

// Basic Drupal settings
$settings['hash_salt'] = 'vulnerable-salt-string-12345';
$settings['config_sync_directory'] = '../config/sync';

// VULNERABILITY 8: Allow all hosts
$settings['trusted_host_patterns'] = array('^.+$');

// Session settings with vulnerabilities
ini_set('session.cookie_secure', 0);
ini_set('session.cookie_httponly', 0);
ini_set('session.cookie_samesite', 'None');

// VULNERABILITY 9: Weak encryption settings
$settings['encrypt_key'] = 'weak-encryption-key';

// VULNERABILITY 10: Expose database in error messages
error_reporting(E_ALL);
ini_set('display_errors', TRUE);

// Include local settings if exists
if (file_exists(__DIR__ . '/settings.local.php')) {
  include __DIR__ . '/settings.local.php';
}
