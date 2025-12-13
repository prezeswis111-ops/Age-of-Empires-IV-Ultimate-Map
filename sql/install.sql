-- Heist Statistics Table
CREATE TABLE IF NOT EXISTS `heist_stats` (
  `identifier` varchar(60) NOT NULL,
  `total_heists` int(11) DEFAULT 0,
  `total_earned` int(11) DEFAULT 0,
  `last_heist` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Phone App Installations Table
CREATE TABLE IF NOT EXISTS `heist_app_installs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(60) NOT NULL,
  `installed_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
