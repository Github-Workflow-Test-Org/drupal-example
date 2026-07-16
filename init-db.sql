-- Vulnerable Drupal Database Initialization
-- This script sets up a minimal but complete Drupal database

USE vulnerable_drupal;

-- Core Drupal 10 tables
CREATE TABLE IF NOT EXISTS users_field_data (
  uid INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  mail VARCHAR(254) UNIQUE NOT NULL,
  pass VARCHAR(255),
  created INT DEFAULT 0,
  changed INT DEFAULT 0,
  status INT DEFAULT 1,
  timezone VARCHAR(32),
  preferred_admin_langcode VARCHAR(12),
  INDEX idx_name (name),
  INDEX idx_mail (mail)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS key_value (
  collection VARCHAR(128) NOT NULL,
  name VARCHAR(128) NOT NULL,
  value LONGBLOB NOT NULL,
  PRIMARY KEY (collection, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS key_value_expire (
  collection VARCHAR(128) NOT NULL,
  name VARCHAR(128) NOT NULL,
  value LONGBLOB NOT NULL,
  expire INT NOT NULL,
  PRIMARY KEY (collection, name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS cache_default (
  cid VARCHAR(255) NOT NULL PRIMARY KEY,
  data LONGBLOB,
  expire INT,
  created DOUBLE,
  serialized INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS sessions (
  ssid VARCHAR(128) NOT NULL PRIMARY KEY,
  uid INT DEFAULT 0,
  hostname VARCHAR(128) DEFAULT '',
  timestamp INT NOT NULL DEFAULT 0,
  session LONGTEXT,
  INDEX idx_uid (uid),
  INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS node (
  nid INT AUTO_INCREMENT PRIMARY KEY,
  type VARCHAR(32) NOT NULL,
  title VARCHAR(255) NOT NULL,
  uid INT DEFAULT 0,
  created INT DEFAULT 0,
  changed INT DEFAULT 0,
  status INT DEFAULT 1,
  INDEX idx_type (type),
  INDEX idx_uid (uid),
  INDEX idx_created (created)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS comments (
  cid INT AUTO_INCREMENT PRIMARY KEY,
  nid INT DEFAULT 0,
  uid INT DEFAULT 0,
  author_name VARCHAR(60),
  body LONGTEXT,
  created INT DEFAULT 0,
  status INT DEFAULT 1,
  INDEX idx_nid (nid),
  INDEX idx_uid (uid),
  INDEX idx_created (created)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS files (
  fid INT AUTO_INCREMENT PRIMARY KEY,
  uid INT DEFAULT 0,
  filename VARCHAR(255) NOT NULL,
  uri VARCHAR(255) NOT NULL,
  filesize INT DEFAULT 0,
  status INT DEFAULT 1,
  created INT DEFAULT 0,
  INDEX idx_uid (uid),
  INDEX idx_uri (uri)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert test users (using MD5 as per vulnerability in settings)
INSERT INTO users_field_data (uid, name, mail, pass, created, status) VALUES
(0, 'Anonymous', '', NULL, 0, 0),
(1, 'admin', 'admin@example.com', '0192023a7bbd73250516f069df18b500', UNIX_TIMESTAMP(), 1),
(2, 'testuser', 'test@example.com', '202cb962ac59075b964b07152d234b70', UNIX_TIMESTAMP(), 1)
ON DUPLICATE KEY UPDATE uid=uid;

-- Insert sample nodes
INSERT INTO node (nid, type, title, uid, created, status) VALUES
(1, 'article', 'Welcome to Vulnerable Drupal', 1, UNIX_TIMESTAMP(), 1),
(2, 'article', 'Security Testing Guide', 1, UNIX_TIMESTAMP(), 1),
(3, 'page', 'About This Project', 1, UNIX_TIMESTAMP(), 1)
ON DUPLICATE KEY UPDATE nid=nid;

-- Insert sample comments with XSS payload
INSERT INTO comments (cid, nid, uid, author_name, body, created, status) VALUES
(1, 1, 2, 'Test User', 'Great article! <script>alert("XSS")</script>', UNIX_TIMESTAMP(), 1),
(2, 1, 0, 'Guest', 'Thanks for sharing this information.', UNIX_TIMESTAMP(), 1)
ON DUPLICATE KEY UPDATE cid=cid;
