#!/bin/bash
set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "=========================================="
echo "Vulnerable Drupal Setup Script"
echo "=========================================="
echo ""

# Step 1: Install Composer Dependencies
echo "[1/5] Installing Composer dependencies..."
cd "$PROJECT_DIR"
composer install --no-interaction 2>&1 | tail -5

# Step 2: Set up database
echo "[2/5] Setting up database..."
if command -v mysql &> /dev/null; then
  mysql -u root -proot -e "DROP DATABASE IF EXISTS vulnerable_drupal;" 2>/dev/null || true
  mysql -u root -proot -e "CREATE DATABASE vulnerable_drupal CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" 2>/dev/null || true
  mysql -u root -proot -e "GRANT ALL ON vulnerable_drupal.* TO 'drupal_user'@'localhost' IDENTIFIED BY 'drupal_password';" 2>/dev/null || true
  mysql -u root -proot -e "FLUSH PRIVILEGES;" 2>/dev/null || true
  echo "✓ Database configured"
else
  echo "⚠ MySQL not available - skip database setup"
fi

# Step 3: Create necessary directories
echo "[3/5] Creating directories..."
mkdir -p sites/default/files
mkdir -p private
chmod 777 sites/default/files
echo "✓ Directories created"

# Step 4: Set up Drush (if available)
echo "[4/5] Setting up Drush..."
if command -v drush &> /dev/null; then
  drush cache:rebuild -y 2>&1 | grep -E "(✓|Clear)" || true
  echo "✓ Drush cache rebuilt"
else
  echo "⚠ Drush not available"
fi

# Step 5: Summary
echo "[5/5] Setup complete!"
echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Start server with:"
echo "  php -S localhost:8080"
echo ""
echo "Access at: http://localhost:8080"
echo "Admin: admin / admin123"
echo ""
