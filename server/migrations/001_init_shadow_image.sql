CREATE DATABASE IF NOT EXISTS `shadow_image`
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE `shadow_image`;

CREATE TABLE IF NOT EXISTS `schema_migrations` (
  `version` VARCHAR(64) NOT NULL,
  `name` VARCHAR(255) NOT NULL,
  `applied_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `teams` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(120) NOT NULL,
  `owner_user_id` BIGINT UNSIGNED NULL,
  `plan_code` VARCHAR(64) NOT NULL DEFAULT 'free',
  `status` VARCHAR(32) NOT NULL DEFAULT 'active',
  `settings` JSON NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `deleted_at` TIMESTAMP(3) NULL,
  PRIMARY KEY (`id`),
  KEY `idx_teams_owner_user_id` (`owner_user_id`),
  KEY `idx_teams_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `current_team_id` BIGINT UNSIGNED NULL,
  `email` VARCHAR(255) NULL,
  `phone` VARCHAR(32) NULL,
  `password_hash` VARCHAR(255) NOT NULL,
  `display_name` VARCHAR(120) NULL,
  `avatar_url` VARCHAR(1024) NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'active',
  `email_verified_at` TIMESTAMP(3) NULL,
  `phone_verified_at` TIMESTAMP(3) NULL,
  `last_login_at` TIMESTAMP(3) NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `deleted_at` TIMESTAMP(3) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_users_email` (`email`),
  UNIQUE KEY `uk_users_phone` (`phone`),
  KEY `idx_users_current_team_id` (`current_team_id`),
  KEY `idx_users_status` (`status`),
  CONSTRAINT `fk_users_current_team` FOREIGN KEY (`current_team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `team_members` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `role` VARCHAR(32) NOT NULL DEFAULT 'member',
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_team_members_team_user` (`team_id`, `user_id`),
  KEY `idx_team_members_user_id` (`user_id`),
  CONSTRAINT `fk_team_members_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_team_members_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `subscriptions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NULL,
  `user_id` BIGINT UNSIGNED NULL,
  `provider` VARCHAR(32) NOT NULL DEFAULT 'manual',
  `provider_subscription_id` VARCHAR(191) NULL,
  `plan_code` VARCHAR(64) NOT NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'active',
  `current_period_start` TIMESTAMP(3) NULL,
  `current_period_end` TIMESTAMP(3) NULL,
  `cancel_at` TIMESTAMP(3) NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_subscriptions_provider_id` (`provider`, `provider_subscription_id`),
  KEY `idx_subscriptions_team_id` (`team_id`),
  KEY `idx_subscriptions_user_id` (`user_id`),
  KEY `idx_subscriptions_status` (`status`),
  CONSTRAINT `fk_subscriptions_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_subscriptions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `credit_accounts` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NULL,
  `user_id` BIGINT UNSIGNED NULL,
  `balance` BIGINT NOT NULL DEFAULT 0,
  `reserved_balance` BIGINT NOT NULL DEFAULT 0,
  `total_earned` BIGINT NOT NULL DEFAULT 0,
  `total_spent` BIGINT NOT NULL DEFAULT 0,
  `currency` VARCHAR(16) NOT NULL DEFAULT 'credit',
  `version` BIGINT UNSIGNED NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_credit_accounts_team` (`team_id`),
  UNIQUE KEY `uk_credit_accounts_user` (`user_id`),
  CONSTRAINT `fk_credit_accounts_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_credit_accounts_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_credit_accounts_owner` CHECK (`team_id` IS NOT NULL OR `user_id` IS NOT NULL)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `projects` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `sku` VARCHAR(128) NULL,
  `description` TEXT NULL,
  `metadata` JSON NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `deleted_at` TIMESTAMP(3) NULL,
  PRIMARY KEY (`id`),
  KEY `idx_projects_team_id` (`team_id`),
  KEY `idx_projects_user_id` (`user_id`),
  KEY `idx_projects_sku` (`sku`),
  CONSTRAINT `fk_projects_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_projects_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `assets` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `project_id` BIGINT UNSIGNED NULL,
  `asset_type` VARCHAR(32) NOT NULL,
  `source` VARCHAR(32) NOT NULL DEFAULT 'upload',
  `storage_key` VARCHAR(512) NOT NULL,
  `url` VARCHAR(1024) NULL,
  `thumbnail_url` VARCHAR(1024) NULL,
  `mime_type` VARCHAR(128) NOT NULL,
  `format` VARCHAR(16) NULL,
  `width` INT UNSIGNED NULL,
  `height` INT UNSIGNED NULL,
  `file_size` BIGINT UNSIGNED NULL,
  `sha256` CHAR(64) NULL,
  `bbox` JSON NULL,
  `metadata` JSON NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'ready',
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `deleted_at` TIMESTAMP(3) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_assets_storage_key` (`storage_key`),
  KEY `idx_assets_team_id` (`team_id`),
  KEY `idx_assets_user_id` (`user_id`),
  KEY `idx_assets_project_id` (`project_id`),
  KEY `idx_assets_type_status` (`asset_type`, `status`),
  KEY `idx_assets_sha256` (`sha256`),
  CONSTRAINT `fk_assets_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_assets_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_assets_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `templates` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `code` VARCHAR(128) NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `platform` VARCHAR(64) NOT NULL,
  `image_type` VARCHAR(64) NOT NULL,
  `style` VARCHAR(64) NULL,
  `aspect_ratio` VARCHAR(16) NULL,
  `prompt_template` TEXT NOT NULL,
  `negative_rules` JSON NULL,
  `output_config` JSON NULL,
  `sort_order` INT NOT NULL DEFAULT 0,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_templates_code` (`code`),
  KEY `idx_templates_platform_type` (`platform`, `image_type`),
  KEY `idx_templates_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `prompt_versions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `template_id` BIGINT UNSIGNED NULL,
  `version` VARCHAR(64) NOT NULL,
  `model` VARCHAR(64) NOT NULL DEFAULT 'gpt-image-2',
  `prompt_text` TEXT NOT NULL,
  `negative_prompt` TEXT NULL,
  `parameters` JSON NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_by` BIGINT UNSIGNED NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_prompt_versions_template_version` (`template_id`, `version`),
  KEY `idx_prompt_versions_active` (`is_active`),
  CONSTRAINT `fk_prompt_versions_template` FOREIGN KEY (`template_id`) REFERENCES `templates` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_prompt_versions_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `generation_jobs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `project_id` BIGINT UNSIGNED NULL,
  `input_asset_id` BIGINT UNSIGNED NOT NULL,
  `template_id` BIGINT UNSIGNED NULL,
  `prompt_version_id` BIGINT UNSIGNED NULL,
  `job_type` VARCHAR(64) NOT NULL,
  `platform` VARCHAR(64) NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'pending',
  `model` VARCHAR(64) NOT NULL DEFAULT 'gpt-image-2',
  `quality` VARCHAR(32) NOT NULL DEFAULT 'standard',
  `size` VARCHAR(32) NULL,
  `output_count` INT UNSIGNED NOT NULL DEFAULT 1,
  `cost_estimate` DECIMAL(18,6) NULL,
  `actual_cost` DECIMAL(18,6) NULL,
  `credit_charged` BIGINT NOT NULL DEFAULT 0,
  `idempotency_key` VARCHAR(191) NULL,
  `payload` JSON NULL,
  `retry_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `error_code` VARCHAR(128) NULL,
  `error_message` TEXT NULL,
  `queued_at` TIMESTAMP(3) NULL,
  `started_at` TIMESTAMP(3) NULL,
  `finished_at` TIMESTAMP(3) NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_generation_jobs_idempotency` (`idempotency_key`),
  KEY `idx_generation_jobs_team_status` (`team_id`, `status`, `created_at`),
  KEY `idx_generation_jobs_user_status` (`user_id`, `status`, `created_at`),
  KEY `idx_generation_jobs_project_id` (`project_id`),
  KEY `idx_generation_jobs_input_asset_id` (`input_asset_id`),
  KEY `idx_generation_jobs_status` (`status`, `created_at`),
  CONSTRAINT `fk_generation_jobs_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_generation_jobs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_generation_jobs_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_generation_jobs_input_asset` FOREIGN KEY (`input_asset_id`) REFERENCES `assets` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_generation_jobs_template` FOREIGN KEY (`template_id`) REFERENCES `templates` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_generation_jobs_prompt_version` FOREIGN KEY (`prompt_version_id`) REFERENCES `prompt_versions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chk_generation_jobs_status` CHECK (`status` IN ('pending','queued','processing','succeeded','failed','cancelled','refunded'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `generation_outputs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `job_id` BIGINT UNSIGNED NOT NULL,
  `asset_id` BIGINT UNSIGNED NOT NULL,
  `output_type` VARCHAR(64) NOT NULL,
  `platform` VARCHAR(64) NULL,
  `width` INT UNSIGNED NULL,
  `height` INT UNSIGNED NULL,
  `format` VARCHAR(16) NULL,
  `quality_scores` JSON NULL,
  `metadata` JSON NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_generation_outputs_job_id` (`job_id`),
  KEY `idx_generation_outputs_asset_id` (`asset_id`),
  CONSTRAINT `fk_generation_outputs_job` FOREIGN KEY (`job_id`) REFERENCES `generation_jobs` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_generation_outputs_asset` FOREIGN KEY (`asset_id`) REFERENCES `assets` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `credit_transactions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` BIGINT UNSIGNED NOT NULL,
  `user_id` BIGINT UNSIGNED NULL,
  `generation_job_id` BIGINT UNSIGNED NULL,
  `direction` VARCHAR(16) NOT NULL,
  `transaction_type` VARCHAR(64) NOT NULL,
  `amount` BIGINT NOT NULL,
  `balance_after` BIGINT NOT NULL,
  `idempotency_key` VARCHAR(191) NOT NULL,
  `description` VARCHAR(255) NULL,
  `metadata` JSON NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_credit_transactions_idempotency` (`idempotency_key`),
  KEY `idx_credit_transactions_account_id` (`account_id`, `created_at`),
  KEY `idx_credit_transactions_user_id` (`user_id`),
  KEY `idx_credit_transactions_generation_job_id` (`generation_job_id`),
  CONSTRAINT `fk_credit_transactions_account` FOREIGN KEY (`account_id`) REFERENCES `credit_accounts` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_credit_transactions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_credit_transactions_generation_job` FOREIGN KEY (`generation_job_id`) REFERENCES `generation_jobs` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chk_credit_transactions_direction` CHECK (`direction` IN ('credit','debit','reserve','release','refund'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `platform_rules` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `platform` VARCHAR(64) NOT NULL,
  `image_type` VARCHAR(64) NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `rules` JSON NOT NULL,
  `is_active` TINYINT(1) NOT NULL DEFAULT 1,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_platform_rules_platform_type` (`platform`, `image_type`),
  KEY `idx_platform_rules_active` (`is_active`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `brand_kits` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(160) NOT NULL,
  `logo_asset_id` BIGINT UNSIGNED NULL,
  `colors` JSON NULL,
  `fonts` JSON NULL,
  `tone` VARCHAR(128) NULL,
  `metadata` JSON NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `deleted_at` TIMESTAMP(3) NULL,
  PRIMARY KEY (`id`),
  KEY `idx_brand_kits_team_id` (`team_id`),
  KEY `idx_brand_kits_user_id` (`user_id`),
  CONSTRAINT `fk_brand_kits_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_brand_kits_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_brand_kits_logo_asset` FOREIGN KEY (`logo_asset_id`) REFERENCES `assets` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `export_jobs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `project_id` BIGINT UNSIGNED NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'pending',
  `export_type` VARCHAR(64) NOT NULL DEFAULT 'zip',
  `platform` VARCHAR(64) NULL,
  `storage_key` VARCHAR(512) NULL,
  `download_url` VARCHAR(1024) NULL,
  `payload` JSON NULL,
  `retry_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `error_code` VARCHAR(128) NULL,
  `error_message` TEXT NULL,
  `started_at` TIMESTAMP(3) NULL,
  `finished_at` TIMESTAMP(3) NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_export_jobs_team_status` (`team_id`, `status`, `created_at`),
  KEY `idx_export_jobs_user_status` (`user_id`, `status`, `created_at`),
  KEY `idx_export_jobs_project_id` (`project_id`),
  CONSTRAINT `fk_export_jobs_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_export_jobs_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_export_jobs_project` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `api_keys` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `team_id` BIGINT UNSIGNED NULL,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `name` VARCHAR(120) NOT NULL,
  `key_prefix` VARCHAR(32) NOT NULL,
  `key_hash` CHAR(64) NOT NULL,
  `scopes` JSON NULL,
  `last_used_at` TIMESTAMP(3) NULL,
  `expires_at` TIMESTAMP(3) NULL,
  `revoked_at` TIMESTAMP(3) NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_api_keys_hash` (`key_hash`),
  KEY `idx_api_keys_team_id` (`team_id`),
  KEY `idx_api_keys_user_id` (`user_id`),
  KEY `idx_api_keys_prefix` (`key_prefix`),
  CONSTRAINT `fk_api_keys_team` FOREIGN KEY (`team_id`) REFERENCES `teams` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_api_keys_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `webhook_events` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `source` VARCHAR(64) NOT NULL,
  `event_type` VARCHAR(128) NOT NULL,
  `external_event_id` VARCHAR(191) NULL,
  `status` VARCHAR(32) NOT NULL DEFAULT 'received',
  `payload` JSON NOT NULL,
  `attempt_count` INT UNSIGNED NOT NULL DEFAULT 0,
  `last_error` TEXT NULL,
  `received_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `processed_at` TIMESTAMP(3) NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_webhook_events_external` (`source`, `external_event_id`),
  KEY `idx_webhook_events_status` (`status`, `received_at`),
  KEY `idx_webhook_events_type` (`source`, `event_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `admin_audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `actor_user_id` BIGINT UNSIGNED NULL,
  `action` VARCHAR(128) NOT NULL,
  `target_type` VARCHAR(128) NULL,
  `target_id` VARCHAR(128) NULL,
  `ip_address` VARCHAR(64) NULL,
  `user_agent` VARCHAR(512) NULL,
  `metadata` JSON NULL,
  `created_at` TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_admin_audit_logs_actor` (`actor_user_id`, `created_at`),
  KEY `idx_admin_audit_logs_target` (`target_type`, `target_id`),
  KEY `idx_admin_audit_logs_action` (`action`, `created_at`),
  CONSTRAINT `fk_admin_audit_logs_actor` FOREIGN KEY (`actor_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO `platform_rules` (`platform`, `image_type`, `name`, `rules`)
VALUES
  ('amazon', 'main_image', 'Amazon main image', JSON_OBJECT(
    'background', 'pure_white',
    'aspect_ratio', '1:1',
    'min_long_side', 1000,
    'recommended_size', JSON_OBJECT('width', 2000, 'height', 2000),
    'allow_text', false,
    'allow_watermark', false
  )),
  ('shopify', 'product_image', 'Shopify product image', JSON_OBJECT(
    'recommended_size', JSON_OBJECT('width', 2048, 'height', 2048),
    'max_size', JSON_OBJECT('width', 5000, 'height', 5000),
    'max_file_mb', 20,
    'formats', JSON_ARRAY('jpg', 'png', 'webp')
  )),
  ('tiktok', 'ad_vertical', 'TikTok vertical ad', JSON_OBJECT(
    'aspect_ratio', '9:16',
    'recommended_size', JSON_OBJECT('width', 1080, 'height', 1920),
    'mobile_first', true
  )),
  ('xiaohongshu', 'cover', 'Xiaohongshu cover', JSON_OBJECT(
    'aspect_ratios', JSON_ARRAY('3:4', '4:5'),
    'recommended_size', JSON_OBJECT('width', 1080, 'height', 1440)
  ))
ON DUPLICATE KEY UPDATE
  `rules` = VALUES(`rules`),
  `updated_at` = CURRENT_TIMESTAMP(3);

INSERT INTO `templates` (`code`, `name`, `platform`, `image_type`, `style`, `aspect_ratio`, `prompt_template`, `negative_rules`, `output_config`, `sort_order`)
VALUES
  (
    'amazon_main_white_001',
    'Amazon main white background',
    'amazon',
    'main_image',
    'clean',
    '1:1',
    'Create a clean ecommerce main product image. Preserve the exact product shape, color, material, logo, package text, proportions, and visible details. Use a pure white background, centered composition, natural shadow, no text, no watermark, no extra props.',
    JSON_ARRAY('Do not change the product', 'Do not add text', 'Do not add props', 'Do not alter logo or package text'),
    JSON_OBJECT('width', 2000, 'height', 2000, 'format', 'jpg', 'background', 'white'),
    10
  ),
  (
    'shopify_lifestyle_kitchen_001',
    'Shopify modern kitchen lifestyle',
    'shopify',
    'lifestyle',
    'modern',
    '1:1',
    'Create a realistic lifestyle ecommerce product photo in a modern kitchen setting. Strictly preserve the input product appearance, shape, color, logo, package text, and proportions. Only change background, lighting, shadow, composition, and environment mood.',
    JSON_ARRAY('Do not redesign the product', 'Do not change product text', 'Do not add unrelated accessories'),
    JSON_OBJECT('width', 2048, 'height', 2048, 'format', 'jpg'),
    20
  ),
  (
    'tiktok_ad_vertical_001',
    'TikTok vertical ad no text',
    'tiktok',
    'ad',
    'bright',
    '9:16',
    'Create a bright mobile-first ecommerce ad visual without text. Keep the product unchanged and place it in the lower center with clean space in the upper area for later editable copy. Preserve all product details and only generate background, lighting, and composition.',
    JSON_ARRAY('Do not generate text', 'Do not change the product', 'Do not alter logo or package text'),
    JSON_OBJECT('width', 1080, 'height', 1920, 'format', 'jpg'),
    30
  )
ON DUPLICATE KEY UPDATE
  `prompt_template` = VALUES(`prompt_template`),
  `negative_rules` = VALUES(`negative_rules`),
  `output_config` = VALUES(`output_config`),
  `updated_at` = CURRENT_TIMESTAMP(3);

INSERT INTO `prompt_versions` (`template_id`, `version`, `model`, `prompt_text`, `negative_prompt`, `parameters`, `is_active`)
SELECT `id`, 'v1', 'gpt-image-2', `prompt_template`, JSON_EXTRACT(`negative_rules`, '$'), `output_config`, 1
FROM `templates`
WHERE `code` IN ('amazon_main_white_001', 'shopify_lifestyle_kitchen_001', 'tiktok_ad_vertical_001')
ON DUPLICATE KEY UPDATE
  `prompt_text` = VALUES(`prompt_text`),
  `negative_prompt` = VALUES(`negative_prompt`),
  `parameters` = VALUES(`parameters`),
  `is_active` = VALUES(`is_active`);

INSERT INTO `schema_migrations` (`version`, `name`)
VALUES ('001', 'init_shadow_image')
ON DUPLICATE KEY UPDATE `applied_at` = `applied_at`;
