#!/bin/bash
set -e

echo "Creating MySQL database for Drupal..."

# Create database (assumes MySQL running locally)
mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" -e "DROP DATABASE IF EXISTS vulnerable_drupal;"
mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" -e "CREATE DATABASE vulnerable_drupal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" -e "CREATE USER 'drupal_user'@'localhost' IDENTIFIED BY 'drupal_password';"
mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" -e "GRANT ALL PRIVILEGES ON vulnerable_drupal.* TO 'drupal_user'@'localhost';"
mysql -u root -p"${MYSQL_ROOT_PASSWORD:-root}" -e "FLUSH PRIVILEGES;"

echo "Database created successfully"
