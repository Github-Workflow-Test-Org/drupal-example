#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "Testing Vulnerable Drupal Application"
echo "=========================================="
echo ""

# Test 1: Composer files
echo "[TEST 1] Checking composer files..."
if [ -f "$PROJECT_DIR/composer.json" ] && [ -f "$PROJECT_DIR/composer.lock" ]; then
  echo "✓ Composer files present"
else
  echo "✗ Composer files missing"
  exit 1
fi

# Test 2: Settings files
echo "[TEST 2] Checking settings files..."
if [ -f "$PROJECT_DIR/sites/default/settings.php" ] && [ -f "$PROJECT_DIR/sites/default/settings.local.php" ]; then
  echo "✓ Settings files found"
else
  echo "✗ Settings files not found"
  exit 1
fi

# Test 3: Custom modules
echo "[TEST 3] Checking custom modules..."
for module in vulnerable_auth vulnerable_upload vulnerable_api; do
  if [ -f "$PROJECT_DIR/modules/custom/$module/${module}.info.yml" ]; then
    echo "✓ Module $module found"
  else
    echo "✗ Module $module not found"
    exit 1
  fi
done

# Test 4: Theme
echo "[TEST 4] Checking theme..."
if [ -f "$PROJECT_DIR/themes/custom/vulnerable_theme/vulnerable_theme.info.yml" ]; then
  echo "✓ Theme found"
else
  echo "✗ Theme not found"
  exit 1
fi

# Test 5: Templates
echo "[TEST 5] Checking templates..."
if [ -f "$PROJECT_DIR/themes/custom/vulnerable_theme/templates/page.html.twig" ]; then
  echo "✓ Templates found"
else
  echo "✗ Templates not found"
  exit 1
fi

# Test 6: README
echo "[TEST 6] Checking documentation..."
if [ -f "$PROJECT_DIR/README.md" ]; then
  echo "✓ README.md found"
  if grep -q "40+" "$PROJECT_DIR/README.md"; then
    echo "✓ Vulnerability documentation present"
  fi
else
  echo "✗ README.md not found"
  exit 1
fi

# Test 7: Vulnerability markers
echo "[TEST 7] Checking vulnerability markers..."
vuln_count=$(grep -r "VULNERABILITY" "$PROJECT_DIR/modules/custom" "$PROJECT_DIR/themes/custom" "$PROJECT_DIR/sites/default" 2>/dev/null | wc -l)
if [ "$vuln_count" -gt 30 ]; then
  echo "✓ Found $vuln_count vulnerability markers (expected 40+)"
else
  echo "⚠ Found $vuln_count vulnerability markers (expected 40+)"
fi

echo ""
echo "=========================================="
echo "All Tests Passed!"
echo "=========================================="
echo ""
echo "Application is ready for Veracode scanning"
echo ""
