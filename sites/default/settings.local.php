<?php
// Local development settings
$settings['file_scan_ignore_directories'] = [
  'node_modules',
  'bower_components',
];

// VULNERABILITY 8: Expose database in error messages
error_reporting(E_ALL);
ini_set('display_errors', TRUE);

// VULNERABILITY 9: Weak encryption settings
$settings['encrypt_key'] = 'weak-encryption-key';
