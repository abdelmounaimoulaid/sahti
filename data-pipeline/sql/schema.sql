-- Sahti product database schema
-- Portable: MySQL 8.0+ and MariaDB 10.5+ (utf8mb4 for Arabic/French text)

CREATE TABLE IF NOT EXISTS products (
  id                 INT UNSIGNED NOT NULL AUTO_INCREMENT,
  barcode            VARCHAR(32)  NOT NULL,
  name               VARCHAR(255) NULL,
  brand              VARCHAR(255) NULL,
  quantity           VARCHAR(100) NULL,
  categories         TEXT         NULL,
  countries          TEXT         NULL,
  ingredients_text   TEXT         NULL,
  ingredients_lang   VARCHAR(10)  NULL,
  additives          TEXT         NULL COMMENT 'Comma-separated E-numbers, e.g. en:e330,en:e211',
  allergens          TEXT         NULL,
  nutriscore_grade   CHAR(1)      NULL,
  nova_group         TINYINT UNSIGNED NULL,
  nutriments         LONGTEXT     NULL COMMENT 'JSON object from Open Food Facts',
  image_url          VARCHAR(500) NULL,
  status             ENUM('complete','incomplete','ai_to_verify','validated') NOT NULL DEFAULT 'incomplete',
  missing_fields     VARCHAR(255) NULL COMMENT 'e.g. ingredients,additives',
  off_last_modified  DATETIME     NULL,
  created_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at         DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  validated_at       DATETIME     NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_barcode (barcode),
  KEY idx_products_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- One row per piece of information found by the AI, with where it came from.
CREATE TABLE IF NOT EXISTS product_sources (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id      INT UNSIGNED NOT NULL,
  field           VARCHAR(50)  NOT NULL COMMENT 'ingredients_text, additives, allergens...',
  value           TEXT         NOT NULL,
  source_url      VARCHAR(1000) NOT NULL,
  source_type     ENUM('manufacturer','moroccan_retailer','foreign_retailer','packaging_photo','open_food_facts','other') NOT NULL DEFAULT 'other',
  source_country  CHAR(2)      NULL COMMENT 'ISO code, MA = Morocco',
  confidence      ENUM('high','medium','low') NOT NULL DEFAULT 'low',
  notes           TEXT         NULL,
  retrieved_at    DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_sources_product (product_id),
  CONSTRAINT fk_sources_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- One row per enrichment attempt, for the final report (time, outcome, pitfalls).
CREATE TABLE IF NOT EXISTS enrichment_runs (
  id              INT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id      INT UNSIGNED NOT NULL,
  started_at      DATETIME     NOT NULL,
  finished_at     DATETIME     NULL,
  duration_sec    INT UNSIGNED NULL,
  outcome         ENUM('found','partial','not_found','rejected_foreign','error') NOT NULL,
  review_result   ENUM('correct','corrected','rejected') NULL COMMENT 'Filled after human review',
  notes           TEXT         NULL,
  PRIMARY KEY (id),
  KEY idx_runs_product (product_id),
  CONSTRAINT fk_runs_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
