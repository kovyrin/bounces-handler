-- MySQL dump 10.11
--
-- Host: localhost    Database: bounces_test
-- ------------------------------------------------------
-- Server version	5.0.45

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `mailing_blacklist`
--

DROP TABLE IF EXISTS `mailing_blacklist`;
CREATE TABLE `mailing_blacklist` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `domain_id` int(10) unsigned NOT NULL,
  `user_crc32` int(10) unsigned NOT NULL,
  `user` varchar(100) NOT NULL default '',
  `source` enum('bounce','unsubscribe','honeypot','other') NOT NULL default 'other',
  `level` enum('soft','hard') NOT NULL default 'hard',
  `reason` varchar(50) default NULL,
  `created_at` timestamp NOT NULL default '0000-00-00 00:00:00' on update CURRENT_TIMESTAMP,
  PRIMARY KEY  (`id`),
  KEY `reports_by_date` (`domain_id`,`user_crc32`,`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=566526135 DEFAULT CHARSET=latin1;

--
-- Table structure for table `mailing_domains`
--

DROP TABLE IF EXISTS `mailing_domains`;
CREATE TABLE `mailing_domains` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `name_crc32` int(10) unsigned NOT NULL default '0',
  `name` varchar(100) NOT NULL default '',
  PRIMARY KEY  (`id`),
  UNIQUE KEY `name_crc32` (`name_crc32`,`name`)
) ENGINE=InnoDB AUTO_INCREMENT=419694933 DEFAULT CHARSET=latin1;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2008-07-15  5:38:35
