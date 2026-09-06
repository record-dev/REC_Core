
CREATE TABLE IF NOT EXISTS `rec_core_characters` (
  `id` bigint(8) NOT NULL AUTO_INCREMENT,
  `citizenId` varchar(50) NOT NULL,
  `license` varchar(100) NOT NULL,
  `slot` tinyint(4) NOT NULL,
  `charinfo` longtext NOT NULL,
  `job` longtext NOT NULL,
  `gang` longtext NOT NULL,
  `money` longtext NOT NULL,
  `metadata` longtext NOT NULL,
  `position` longtext DEFAULT NULL,
  `lastLoggedOutAt` timestamp NULL DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenId` (`citizenId`),
  UNIQUE KEY `license_slot` (`license`, `slot`),
  KEY `license` (`license`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `rec_core_data` (
  `id` bigint(8) NOT NULL AUTO_INCREMENT,
  `citizenId` varchar(50) NOT NULL,
  `namespace` varchar(50) NOT NULL,
  `dataKey` varchar(100) NOT NULL,
  `value` longtext DEFAULT NULL,
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenId_namespace_dataKey` (`citizenId`, `namespace`, `dataKey`),
  KEY `citizenId` (`citizenId`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
