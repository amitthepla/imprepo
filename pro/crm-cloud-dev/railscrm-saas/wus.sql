-- MySQL dump 10.13  Distrib 5.5.41, for debian-linux-gnu (i686)
--
-- Host: localhost    Database: wus-local
-- ------------------------------------------------------
-- Server version	5.5.41-0ubuntu0.12.04.1

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
-- Table structure for table `Tempsplitvalues`
--

DROP TABLE IF EXISTS `Tempsplitvalues`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `Tempsplitvalues` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `item` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Tempsplitvalues`
--

LOCK TABLES `Tempsplitvalues` WRITE;
/*!40000 ALTER TABLE `Tempsplitvalues` DISABLE KEYS */;
/*!40000 ALTER TABLE `Tempsplitvalues` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `activity_type` varchar(255) DEFAULT NULL,
  `activity_id` int(11) DEFAULT NULL,
  `activity_user_id` int(11) DEFAULT NULL,
  `activity_status` varchar(255) DEFAULT NULL,
  `activity_desc` varchar(255) DEFAULT NULL,
  `activity_date` datetime DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `source_id` int(11) DEFAULT NULL,
  `is_available` tinyint(1) DEFAULT '0',
  `activity_by` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_activities_on_activity_user_id` (`activity_user_id`),
  KEY `index_activities_on_organization_id` (`organization_id`),
  KEY `index_activities_on_activity_date` (`activity_date`),
  KEY `index_activities_on_source_id` (`source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities`
--

LOCK TABLES `activities` WRITE;
/*!40000 ALTER TABLE `activities` DISABLE KEYS */;
/*!40000 ALTER TABLE `activities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activities_contacts`
--

DROP TABLE IF EXISTS `activities_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activities_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `activity_id` int(11) DEFAULT NULL,
  `contactable_type` varchar(255) DEFAULT NULL,
  `contactable_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activities_contacts`
--

LOCK TABLES `activities_contacts` WRITE;
/*!40000 ALTER TABLE `activities_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `activities_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `addresses`
--

DROP TABLE IF EXISTS `addresses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `addresses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `address_type` varchar(255) DEFAULT NULL,
  `address` text,
  `country_id` int(11) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `addressable_type` varchar(255) DEFAULT NULL,
  `addressable_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_addresses_on_organization_id` (`organization_id`),
  KEY `index_addresses_on_country_id` (`country_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `addresses`
--

LOCK TABLES `addresses` WRITE;
/*!40000 ALTER TABLE `addresses` DISABLE KEYS */;
/*!40000 ALTER TABLE `addresses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ahoy_messages`
--

DROP TABLE IF EXISTS `ahoy_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ahoy_messages` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `token` varchar(255) DEFAULT NULL,
  `to` text,
  `user_id` int(11) DEFAULT NULL,
  `user_type` varchar(255) DEFAULT NULL,
  `mailer` varchar(255) DEFAULT NULL,
  `subject` text,
  `content` text,
  `sent_at` datetime DEFAULT NULL,
  `opened_at` datetime DEFAULT NULL,
  `clicked_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_ahoy_messages_on_token` (`token`),
  KEY `index_ahoy_messages_on_user_id_and_user_type` (`user_id`,`user_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ahoy_messages`
--

LOCK TABLES `ahoy_messages` WRITE;
/*!40000 ALTER TABLE `ahoy_messages` DISABLE KEYS */;
/*!40000 ALTER TABLE `ahoy_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `api_integrations`
--

DROP TABLE IF EXISTS `api_integrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `api_integrations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `url` varchar(255) DEFAULT NULL,
  `api_name` varchar(255) DEFAULT NULL,
  `account_id` varchar(255) DEFAULT NULL,
  `auth_token` varchar(255) DEFAULT NULL,
  `oauth_access_token` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `api_integrations`
--

LOCK TABLES `api_integrations` WRITE;
/*!40000 ALTER TABLE `api_integrations` DISABLE KEYS */;
/*!40000 ALTER TABLE `api_integrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attention_deals`
--

DROP TABLE IF EXISTS `attention_deals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attention_deals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `deal_ids` text,
  `deal_count` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attention_deals`
--

LOCK TABLES `attention_deals` WRITE;
/*!40000 ALTER TABLE `attention_deals` DISABLE KEYS */;
/*!40000 ALTER TABLE `attention_deals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `beta_accounts`
--

DROP TABLE IF EXISTS `beta_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `beta_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `invitation_token` text,
  `invited_by` int(11) DEFAULT NULL,
  `is_verified` tinyint(1) DEFAULT '0',
  `is_approved` tinyint(1) DEFAULT '0',
  `is_registered` tinyint(1) DEFAULT '0',
  `is_siteadmin_invited` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `beta_accounts`
--

LOCK TABLES `beta_accounts` WRITE;
/*!40000 ALTER TABLE `beta_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `beta_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bug_reports`
--

DROP TABLE IF EXISTS `bug_reports`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bug_reports` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `platform` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `bug_type` varchar(255) DEFAULT NULL,
  `comments` text,
  `is_resolved` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bug_reports`
--

LOCK TABLES `bug_reports` WRITE;
/*!40000 ALTER TABLE `bug_reports` DISABLE KEYS */;
/*!40000 ALTER TABLE `bug_reports` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `community_plugins`
--

DROP TABLE IF EXISTS `community_plugins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `community_plugins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `description` text,
  `unique_id` text,
  `is_active` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_plugin` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `community_plugins`
--

LOCK TABLES `community_plugins` WRITE;
/*!40000 ALTER TABLE `community_plugins` DISABLE KEYS */;
/*!40000 ALTER TABLE `community_plugins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_contacts`
--

DROP TABLE IF EXISTS `company_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `company_strength_id` int(11) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `messanger_type` varchar(255) DEFAULT NULL,
  `messanger_id` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `linkedin_url` varchar(255) DEFAULT NULL,
  `facebook_url` varchar(255) DEFAULT NULL,
  `twitter_url` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `contact_ref_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `time_zone` varchar(255) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_contacts`
--

LOCK TABLES `company_contacts` WRITE;
/*!40000 ALTER TABLE `company_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `company_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `company_strengths`
--

DROP TABLE IF EXISTS `company_strengths`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `company_strengths` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `range` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `company_strengths`
--

LOCK TABLES `company_strengths` WRITE;
/*!40000 ALTER TABLE `company_strengths` DISABLE KEYS */;
INSERT INTO `company_strengths` VALUES (1,'1-10','2017-05-01 10:27:08','2017-05-01 10:27:08'),(2,'11-50','2017-05-01 10:27:08','2017-05-01 10:27:08'),(3,'51-200','2017-05-01 10:27:08','2017-05-01 10:27:08'),(4,'201-500','2017-05-01 10:27:08','2017-05-01 10:27:08'),(5,'501-1000','2017-05-01 10:27:08','2017-05-01 10:27:08'),(6,'>1000','2017-05-01 10:27:08','2017-05-01 10:27:08');
/*!40000 ALTER TABLE `company_strengths` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_opportunities`
--

DROP TABLE IF EXISTS `contact_opportunities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_opportunities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `opportunity` varchar(255) DEFAULT NULL,
  `individual_contact_id` int(11) DEFAULT NULL,
  `deal_id` int(11) DEFAULT NULL,
  `is_converted` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_opportunities`
--

LOCK TABLES `contact_opportunities` WRITE;
/*!40000 ALTER TABLE `contact_opportunities` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_opportunities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_us`
--

DROP TABLE IF EXISTS `contact_us`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_us` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) DEFAULT NULL,
  `is_remote` tinyint(1) DEFAULT '0',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_us`
--

LOCK TABLES `contact_us` WRITE;
/*!40000 ALTER TABLE `contact_us` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_us` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contact_us_infos`
--

DROP TABLE IF EXISTS `contact_us_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contact_us_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `comment` text,
  `phone` varchar(255) DEFAULT NULL,
  `contact_us_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `need_help` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_contact_us_infos_on_contact_us_id` (`contact_us_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contact_us_infos`
--

LOCK TABLES `contact_us_infos` WRITE;
/*!40000 ALTER TABLE `contact_us_infos` DISABLE KEYS */;
/*!40000 ALTER TABLE `contact_us_infos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contacts`
--

DROP TABLE IF EXISTS `contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `company_strength_id` int(11) DEFAULT NULL,
  `contact_type` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `messanger_type` varchar(255) DEFAULT NULL,
  `messanger_id` varchar(255) DEFAULT NULL,
  `linkedin_url` varchar(255) DEFAULT NULL,
  `facebook_url` varchar(255) DEFAULT NULL,
  `twitter_url` varchar(255) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `index_contacts_on_organization_id` (`organization_id`),
  KEY `index_contacts_on_company_strength_id` (`company_strength_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contacts`
--

LOCK TABLES `contacts` WRITE;
/*!40000 ALTER TABLE `contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ccode` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `isd_code` varchar(255) DEFAULT NULL,
  `flag` varchar(255) DEFAULT NULL,
  `is_priority` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=251 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `countries`
--

LOCK TABLES `countries` WRITE;
/*!40000 ALTER TABLE `countries` DISABLE KEYS */;
INSERT INTO `countries` VALUES (1,'AF','Afghanistan','93','AF.png',0),(2,'AX','Aland Islands','358','AX.png',0),(3,'AL','Albania','355','AL.png',0),(4,'DZ','Algeria','213','DZ.png',0),(5,'AS','American Samoa','1+684','AS.png',0),(6,'AD','Andorra','376','AD.png',0),(7,'AO','Angola','244','AO.png',0),(8,'AI','Anguilla','1+264','AI.png',0),(9,'AQ','Antarctica','672','AQ.png',0),(10,'AG','Antigua and Barbuda','1+268','AG.png',0),(11,'AR','Argentina','54','AR.png',0),(12,'AM','Armenia','374','AM.png',0),(13,'AW','Aruba','297','AW.png',0),(14,'AU','Australia','61','AU.png',0),(15,'AT','Austria','43','AT.png',0),(16,'AZ','Azerbaijan','994','AZ.png',0),(17,'BS','Bahamas','1+242','BS.png',0),(18,'BH','Bahrain','973','BH.png',0),(19,'BD','Bangladesh','880','BD.png',0),(20,'BB','Barbados','1+246','BB.png',0),(21,'BY','Belarus','375','BY.png',0),(22,'BE','Belgium','32','BE.png',0),(23,'BZ','Belize','501','BZ.png',0),(24,'BJ','Benin','229','BJ.png',0),(25,'BM','Bermuda','1+441','BM.png',0),(26,'BT','Bhutan','975','BT.png',0),(27,'BO','Bolivia','591','BO.png',0),(28,'BQ','Bonaire, Sint Eustatius and Saba','599','BQ.png',0),(29,'BA','Bosnia and Herzegovina','387','BA.png',0),(30,'BW','Botswana','267','BW.png',0),(31,'BV','Bouvet Island','NONE','BV.png',0),(32,'BR','Brazil','55','BR.png',0),(33,'IO','British Indian Ocean Territory','246','IO.png',0),(34,'BN','Brunei','673','BN.png',0),(35,'BG','Bulgaria','359','BG.png',0),(36,'BF','Burkina Faso','226','BF.png',0),(37,'BI','Burundi','257','BI.png',0),(38,'KH','Cambodia','855','KH.png',0),(39,'CM','Cameroon','237','CM.png',0),(40,'CA','Canada','1','CA.png',0),(41,'CV','Cape Verde','238','CV.png',0),(42,'KY','Cayman Islands','1+345','KY.png',0),(43,'CF','Central African Republic','236','CF.png',0),(44,'TD','Chad','235','TD.png',0),(45,'CL','Chile','56','CL.png',0),(46,'CN','China','86','CN.png',0),(47,'CX','Christmas Island','61','CX.png',0),(48,'CC','Cocos (Keeling) Islands','61','CC.png',0),(49,'CO','Colombia','57','CO.png',0),(50,'KM','Comoros','269','KM.png',0),(51,'CG','Congo','242','CG.png',0),(52,'CK','Cook Islands','682','CK.png',0),(53,'CR','Costa Rica','506','CR.png',0),(54,'CI','Cote divoire (Ivory Coast)','225','CI.png',0),(55,'HR','Croatia','385','HR.png',0),(56,'CU','Cuba','53','CU.png',0),(57,'CW','Curacao','599','CW.png',0),(58,'CY','Cyprus','357','CY.png',0),(59,'CZ','Czech Republic','420','CZ.png',0),(60,'CD','Democratic Republic of the Congo','243','CD.png',0),(61,'DK','Denmark','45','DK.png',0),(62,'DJ','Djibouti','253','DJ.png',0),(63,'DM','Dominica','1+767','DM.png',0),(64,'DO','Dominican Republic','1+809, 8','DO.png',0),(65,'EC','Ecuador','593','EC.png',0),(66,'EG','Egypt','20','EG.png',0),(67,'SV','El Salvador','503','SV.png',0),(68,'GQ','Equatorial Guinea','240','GQ.png',0),(69,'ER','Eritrea','291','ER.png',0),(70,'EE','Estonia','372','EE.png',0),(71,'ET','Ethiopia','251','ET.png',0),(72,'FK','Falkland Islands (Malvinas)','500','FK.png',0),(73,'FO','Faroe Islands','298','FO.png',0),(74,'FJ','Fiji','679','FJ.png',0),(75,'FI','Finland','358','FI.png',0),(76,'FR','France','33','FR.png',0),(77,'GF','French Guiana','594','GF.png',0),(78,'PF','French Polynesia','689','PF.png',0),(79,'TF','French Southern Territories','','TF.png',0),(80,'GA','Gabon','241','GA.png',0),(81,'GM','Gambia','220','GM.png',0),(82,'GE','Georgia','995','GE.png',0),(83,'DE','Germany','49','DE.png',0),(84,'GH','Ghana','233','GH.png',0),(85,'GI','Gibraltar','350','GI.png',0),(86,'GR','Greece','30','GR.png',0),(87,'GL','Greenland','299','GL.png',0),(88,'GD','Grenada','1+473','GD.png',0),(89,'GP','Guadaloupe','590','GP.png',0),(90,'GU','Guam','1+671','GU.png',0),(91,'GT','Guatemala','502','GT.png',0),(92,'GG','Guernsey','44','GG.png',0),(93,'GN','Guinea','224','GN.png',0),(94,'GW','Guinea-Bissau','245','GW.png',0),(95,'GY','Guyana','592','GY.png',0),(96,'HT','Haiti','509','HT.png',0),(97,'HM','Heard Island and McDonald Islands','NONE','HM.png',0),(98,'HN','Honduras','504','HN.png',0),(99,'HK','Hong Kong','852','HK.png',0),(100,'HU','Hungary','36','HU.png',0),(101,'IS','Iceland','354','IS.png',0),(102,'IN','India','91','IN.png',0),(103,'ID','Indonesia','62','ID.png',0),(104,'IR','Iran','98','IR.png',0),(105,'IQ','Iraq','964','IQ.png',0),(106,'IE','Ireland','353','IE.png',0),(107,'IM','Isle of Man','44','IM.png',0),(108,'IL','Israel','972','IL.png',0),(109,'IT','Italy','39','IT.png',0),(110,'JM','Jamaica','1+876','JM.png',0),(111,'JP','Japan','81','JP.png',0),(112,'JE','Jersey','44','JE.png',0),(113,'JO','Jordan','962','JO.png',0),(114,'KZ','Kazakhstan','7','KZ.png',0),(115,'KE','Kenya','254','KE.png',0),(116,'KI','Kiribati','686','KI.png',0),(117,'XK','Kosovo','381','XK.png',0),(118,'KW','Kuwait','965','KW.png',0),(119,'KG','Kyrgyzstan','996','KG.png',0),(120,'LA','Laos','856','LA.png',0),(121,'LV','Latvia','371','LV.png',0),(122,'LB','Lebanon','961','LB.png',0),(123,'LS','Lesotho','266','LS.png',0),(124,'LR','Liberia','231','LR.png',0),(125,'LY','Libya','218','LY.png',0),(126,'LI','Liechtenstein','423','LI.png',0),(127,'LT','Lithuania','370','LT.png',0),(128,'LU','Luxembourg','352','LU.png',0),(129,'MO','Macao','853','MO.png',0),(130,'MK','Macedonia','389','MK.png',0),(131,'MG','Madagascar','261','MG.png',0),(132,'MW','Malawi','265','MW.png',0),(133,'MY','Malaysia','60','MY.png',0),(134,'MV','Maldives','960','MV.png',0),(135,'ML','Mali','223','ML.png',0),(136,'MT','Malta','356','MT.png',0),(137,'MH','Marshall Islands','692','MH.png',0),(138,'MQ','Martinique','596','MQ.png',0),(139,'MR','Mauritania','222','MR.png',0),(140,'MU','Mauritius','230','MU.png',0),(141,'YT','Mayotte','262','YT.png',0),(142,'MX','Mexico','52','MX.png',0),(143,'FM','Micronesia','691','FM.png',0),(144,'MD','Moldava','373','MD.png',0),(145,'MC','Monaco','377','MC.png',0),(146,'MN','Mongolia','976','MN.png',0),(147,'ME','Montenegro','382','ME.png',0),(148,'MS','Montserrat','1+664','MS.png',0),(149,'MA','Morocco','212','MA.png',0),(150,'MZ','Mozambique','258','MZ.png',0),(151,'MM','Myanmar (Burma)','95','MM.png',0),(152,'NA','Namibia','264','NA.png',0),(153,'NR','Nauru','674','NR.png',0),(154,'NP','Nepal','977','NP.png',0),(155,'NL','Netherlands','31','NL.png',0),(156,'NC','New Caledonia','687','NC.png',0),(157,'NZ','New Zealand','64','NZ.png',0),(158,'NI','Nicaragua','505','NI.png',0),(159,'NE','Niger','227','NE.png',0),(160,'NG','Nigeria','234','NG.png',0),(161,'NU','Niue','683','NU.png',0),(162,'NF','Norfolk Island','672','NF.png',0),(163,'KP','North Korea','850','KP.png',0),(164,'MP','Northern Mariana Islands','1+670','MP.png',0),(165,'NO','Norway','47','NO.png',0),(166,'OM','Oman','968','OM.png',0),(167,'PK','Pakistan','92','PK.png',0),(168,'PW','Palau','680','PW.png',0),(169,'PS','Palestine','970','PS.png',0),(170,'PA','Panama','507','PA.png',0),(171,'PG','Papua New Guinea','675','PG.png',0),(172,'PY','Paraguay','595','PY.png',0),(173,'PE','Peru','51','PE.png',0),(174,'PH','Phillipines','63','PH.png',0),(175,'PN','Pitcairn','NONE','PN.png',0),(176,'PL','Poland','48','PL.png',0),(177,'PT','Portugal','351','PT.png',0),(178,'PR','Puerto Rico','1+939','PR.png',0),(179,'QA','Qatar','974','QA.png',0),(180,'RE','Reunion','262','RE.png',0),(181,'RO','Romania','40','RO.png',0),(182,'RU','Russia','7','RU.png',0),(183,'RW','Rwanda','250','RW.png',0),(184,'BL','Saint Barthelemy','590','BL.png',0),(185,'SH','Saint Helena','290','SH.png',0),(186,'KN','Saint Kitts and Nevis','1+869','KN.png',0),(187,'LC','Saint Lucia','1+758','LC.png',0),(188,'MF','Saint Martin','590','MF.png',0),(189,'PM','Saint Pierre and Miquelon','508','PM.png',0),(190,'VC','Saint Vincent and the Grenadines','1+784','VC.png',0),(191,'WS','Samoa','685','WS.png',0),(192,'SM','San Marino','378','SM.png',0),(193,'ST','Sao Tome and Principe','239','ST.png',0),(194,'SA','Saudi Arabia','966','SA.png',0),(195,'SN','Senegal','221','SN.png',0),(196,'RS','Serbia','381','RS.png',0),(197,'SC','Seychelles','248','SC.png',0),(198,'SL','Sierra Leone','232','SL.png',0),(199,'SG','Singapore','65','SG.png',0),(200,'SX','Sint Maarten','1+721','SX.png',0),(201,'SK','Slovakia','421','SK.png',0),(202,'SI','Slovenia','386','SI.png',0),(203,'SB','Solomon Islands','677','SB.png',0),(204,'SO','Somalia','252','SO.png',0),(205,'ZA','South Africa','27','ZA.png',0),(206,'GS','South Georgia and the South Sandwich Islands','500','GS.png',0),(207,'KR','South Korea','82','KR.png',0),(208,'SS','South Sudan','211','SS.png',0),(209,'ES','Spain','34','ES.png',0),(210,'LK','Sri Lanka','94','LK.png',0),(211,'SD','Sudan','249','SD.png',0),(212,'SR','Suriname','597','SR.png',0),(213,'SJ','Svalbard and Jan Mayen','47','SJ.png',0),(214,'SZ','Swaziland','268','SZ.png',0),(215,'SE','Sweden','46','SE.png',0),(216,'CH','Switzerland','41','CH.png',0),(217,'SY','Syria','963','SY.png',0),(218,'TW','Taiwan','886','TW.png',0),(219,'TJ','Tajikistan','992','TJ.png',0),(220,'TZ','Tanzania','255','TZ.png',0),(221,'TH','Thailand','66','TH.png',0),(222,'TL','Timor-Leste (East Timor)','670','TL.png',0),(223,'TG','Togo','228','TG.png',0),(224,'TK','Tokelau','690','TK.png',0),(225,'TO','Tonga','676','TO.png',0),(226,'TT','Trinidad and Tobago','1+868','TT.png',0),(227,'TN','Tunisia','216','TN.png',0),(228,'TR','Turkey','90','TR.png',0),(229,'TM','Turkmenistan','993','TM.png',0),(230,'TC','Turks and Caicos Islands','1+649','TC.png',0),(231,'TV','Tuvalu','688','TV.png',0),(232,'UG','Uganda','256','UG.png',0),(233,'UA','Ukraine','380','UA.png',0),(234,'AE','United Arab Emirates','971','AE.png',0),(235,'GB','United Kingdom','44','GB.png',0),(236,'US','United States','1','US.png',0),(237,'UM','United States Minor Outlying Islands','NONE','UM.png',0),(238,'UY','Uruguay','598','UY.png',0),(239,'UZ','Uzbekistan','998','UZ.png',0),(240,'VU','Vanuatu','678','VU.png',0),(241,'VA','Vatican City','39','VA.png',0),(242,'VE','Venezuela','58','VE.png',0),(243,'VN','Vietnam','84','VN.png',0),(244,'VG','Virgin Islands, British','1+284','VG.png',0),(245,'VI','Virgin Islands, US','1+340','VI.png',0),(246,'WF','Wallis and Futuna','681','WF.png',0),(247,'EH','Western Sahara','212','EH.png',0),(248,'YE','Yemen','967','YE.png',0),(249,'ZM','Zambia','260','ZM.png',0),(250,'ZW','Zimbabwe','263','ZW.png',0);
/*!40000 ALTER TABLE `countries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `daily_updates`
--

DROP TABLE IF EXISTS `daily_updates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `daily_updates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `deal_id` int(11) DEFAULT NULL,
  `user_ids` varchar(255) DEFAULT NULL,
  `alert_time` time DEFAULT NULL,
  `time_zone` varchar(255) DEFAULT NULL,
  `frequency` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_daily_updates_on_deal_id` (`deal_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `daily_updates`
--

LOCK TABLES `daily_updates` WRITE;
/*!40000 ALTER TABLE `daily_updates` DISABLE KEYS */;
/*!40000 ALTER TABLE `daily_updates` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deal_attachments`
--

DROP TABLE IF EXISTS `deal_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deal_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `deal_conversation_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deal_attachments`
--

LOCK TABLES `deal_attachments` WRITE;
/*!40000 ALTER TABLE `deal_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `deal_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deal_conversations`
--

DROP TABLE IF EXISTS `deal_conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deal_conversations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `deal_id` int(11) NOT NULL,
  `organization_id` int(11) NOT NULL,
  `message` text,
  `subject` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deal_conversations`
--

LOCK TABLES `deal_conversations` WRITE;
/*!40000 ALTER TABLE `deal_conversations` DISABLE KEYS */;
/*!40000 ALTER TABLE `deal_conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deal_industries`
--

DROP TABLE IF EXISTS `deal_industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deal_industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `deal_id` int(11) DEFAULT NULL,
  `industry_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_deal_industries_on_organization_id` (`organization_id`),
  KEY `index_deal_industries_on_deal_id` (`deal_id`),
  KEY `index_deal_industries_on_industry_id` (`industry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deal_industries`
--

LOCK TABLES `deal_industries` WRITE;
/*!40000 ALTER TABLE `deal_industries` DISABLE KEYS */;
/*!40000 ALTER TABLE `deal_industries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deal_labels`
--

DROP TABLE IF EXISTS `deal_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deal_labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `deal_id` int(11) DEFAULT NULL,
  `user_label_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_deal_labels_on_organization_id` (`organization_id`),
  KEY `index_deal_labels_on_deal_id` (`deal_id`),
  KEY `index_deal_labels_on_user_label_id` (`user_label_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deal_labels`
--

LOCK TABLES `deal_labels` WRITE;
/*!40000 ALTER TABLE `deal_labels` DISABLE KEYS */;
/*!40000 ALTER TABLE `deal_labels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deal_moves`
--

DROP TABLE IF EXISTS `deal_moves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deal_moves` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `deal_id` int(11) DEFAULT NULL,
  `deal_status_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_deal_moves_on_organization_id` (`organization_id`),
  KEY `index_deal_moves_on_deal_id` (`deal_id`),
  KEY `index_deal_moves_on_deal_status_id` (`deal_status_id`),
  KEY `index_deal_moves_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deal_moves`
--

LOCK TABLES `deal_moves` WRITE;
/*!40000 ALTER TABLE `deal_moves` DISABLE KEYS */;
/*!40000 ALTER TABLE `deal_moves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deal_settings`
--

DROP TABLE IF EXISTS `deal_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deal_settings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `tabs` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_deal_settings_on_organization_id` (`organization_id`),
  KEY `index_deal_settings_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deal_settings`
--

LOCK TABLES `deal_settings` WRITE;
/*!40000 ALTER TABLE `deal_settings` DISABLE KEYS */;
INSERT INTO `deal_settings` VALUES (1,4,4,'20','2017-05-01 10:38:43','2017-05-01 10:38:43');
/*!40000 ALTER TABLE `deal_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deal_sources`
--

DROP TABLE IF EXISTS `deal_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deal_sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `deal_id` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_deal_sources_on_organization_id` (`organization_id`),
  KEY `index_deal_sources_on_deal_id` (`deal_id`),
  KEY `index_deal_sources_on_source_id` (`source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deal_sources`
--

LOCK TABLES `deal_sources` WRITE;
/*!40000 ALTER TABLE `deal_sources` DISABLE KEYS */;
/*!40000 ALTER TABLE `deal_sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deal_statuses`
--

DROP TABLE IF EXISTS `deal_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deal_statuses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `original_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `is_visible` tinyint(1) DEFAULT '1',
  `color` varchar(255) DEFAULT NULL,
  `is_funnel_view` tinyint(1) DEFAULT '1',
  `is_kanban` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_deal_statuses_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deal_statuses`
--

LOCK TABLES `deal_statuses` WRITE;
/*!40000 ALTER TABLE `deal_statuses` DISABLE KEYS */;
INSERT INTO `deal_statuses` VALUES (1,1,'New',1,'2017-05-01 10:27:10','2017-05-01 10:27:10',1,1,NULL,1,0),(2,1,'Qualified',2,'2017-05-01 10:27:10','2017-05-01 10:27:10',1,1,NULL,1,0),(3,1,'Not Qualified',3,'2017-05-01 10:27:10','2017-05-01 10:27:10',1,1,NULL,1,0),(4,1,'Quote',4,'2017-05-01 10:27:10','2017-05-01 10:27:10',1,1,NULL,1,0),(5,1,'Won',5,'2017-05-01 10:27:10','2017-05-01 10:27:10',1,1,NULL,1,0),(6,1,'Lost',6,'2017-05-01 10:27:10','2017-05-01 10:27:10',1,1,NULL,1,0),(7,2,'New',1,'2017-05-01 10:29:47','2017-05-01 10:29:47',1,1,NULL,1,0),(8,2,'Qualified',2,'2017-05-01 10:29:47','2017-05-01 10:29:47',1,1,NULL,1,0),(9,2,'Not Qualified',3,'2017-05-01 10:29:47','2017-05-01 10:29:47',1,1,NULL,1,0),(10,2,'Quote',4,'2017-05-01 10:29:47','2017-05-01 10:29:47',1,1,NULL,1,0),(11,2,'Won',5,'2017-05-01 10:29:47','2017-05-01 10:29:47',1,1,NULL,1,0),(12,2,'Lost',6,'2017-05-01 10:29:47','2017-05-01 10:29:47',1,1,NULL,1,0),(13,3,'New',1,'2017-05-01 10:33:17','2017-05-01 10:33:17',1,1,NULL,1,0),(14,3,'Qualified',2,'2017-05-01 10:33:17','2017-05-01 10:33:17',1,1,NULL,1,0),(15,3,'Not Qualified',3,'2017-05-01 10:33:17','2017-05-01 10:33:17',1,1,NULL,1,0),(16,3,'Quote',4,'2017-05-01 10:33:17','2017-05-01 10:33:17',1,1,NULL,1,0),(17,3,'Won',5,'2017-05-01 10:33:17','2017-05-01 10:33:17',1,1,NULL,1,0),(18,3,'Lost',6,'2017-05-01 10:33:17','2017-05-01 10:33:17',1,1,NULL,1,0),(19,4,'New',1,'2017-05-01 10:35:10','2017-05-01 10:35:10',1,1,NULL,1,0),(20,4,'Qualified',2,'2017-05-01 10:35:10','2017-05-01 10:35:10',1,1,NULL,1,0),(21,4,'Not Qualified',3,'2017-05-01 10:35:10','2017-05-01 10:35:10',1,1,NULL,1,0),(22,4,'Quote',4,'2017-05-01 10:35:10','2017-05-01 10:35:10',1,1,NULL,1,0),(23,4,'Won',5,'2017-05-01 10:35:10','2017-05-01 10:35:10',1,1,NULL,1,0),(24,4,'Lost',6,'2017-05-01 10:35:10','2017-05-01 10:35:10',1,1,NULL,1,0),(25,5,'New',1,'2017-05-02 10:24:29','2017-05-02 10:24:29',1,1,NULL,1,0),(26,5,'Qualified',2,'2017-05-02 10:24:29','2017-05-02 10:24:29',1,1,NULL,1,0),(27,5,'Not Qualified',3,'2017-05-02 10:24:29','2017-05-02 10:24:29',1,1,NULL,1,0),(28,5,'Quote',4,'2017-05-02 10:24:29','2017-05-02 10:24:29',1,1,NULL,1,0),(29,5,'Won',5,'2017-05-02 10:24:29','2017-05-02 10:24:29',1,1,NULL,1,0),(30,5,'Lost',6,'2017-05-02 10:24:29','2017-05-02 10:24:29',1,1,NULL,1,0);
/*!40000 ALTER TABLE `deal_statuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deals`
--

DROP TABLE IF EXISTS `deals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deals` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `priority_type_id` int(11) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `contact_id` int(11) DEFAULT NULL,
  `tags` varchar(255) DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `probability` int(11) DEFAULT NULL,
  `attempts` int(11) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT '1',
  `initiated_by` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `deal_status_id` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `is_current` tinyint(1) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `is_csv` tinyint(1) DEFAULT '0',
  `is_mail_sent` tinyint(1) DEFAULT '1',
  `closed_by` int(11) DEFAULT NULL,
  `last_activity_date` datetime DEFAULT NULL,
  `comments` text,
  `is_remote` tinyint(1) DEFAULT '0',
  `app_type` varchar(255) DEFAULT NULL,
  `latest_task_type_id` int(11) DEFAULT NULL,
  `contact_info` text,
  `stage_move_date` datetime DEFAULT NULL,
  `duration` varchar(255) DEFAULT NULL,
  `billing_type` varchar(255) DEFAULT NULL,
  `is_opportunity` tinyint(1) NOT NULL DEFAULT '0',
  `payment_status` varchar(255) DEFAULT 'Not done',
  `referrer` varchar(255) DEFAULT NULL,
  `hot_lead_token` text,
  `token_expiry_time` datetime DEFAULT NULL,
  `next_priority_id` int(11) DEFAULT NULL,
  `assignee_id` int(11) DEFAULT NULL,
  `visited` text,
  `location_by_api` text,
  `individual_contact_id` int(11) DEFAULT NULL,
  `user_label_id` int(11) DEFAULT '1',
  `web_form_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_deals_on_organization_id` (`organization_id`),
  KEY `index_deals_on_priority_type_id` (`priority_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deals`
--

LOCK TABLES `deals` WRITE;
/*!40000 ALTER TABLE `deals` DISABLE KEYS */;
/*!40000 ALTER TABLE `deals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `deals_contacts`
--

DROP TABLE IF EXISTS `deals_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deals_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `deal_id` int(11) DEFAULT NULL,
  `contactable_type` varchar(255) DEFAULT NULL,
  `contactable_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `deals_contacts`
--

LOCK TABLES `deals_contacts` WRITE;
/*!40000 ALTER TABLE `deals_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `deals_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `download_users`
--

DROP TABLE IF EXISTS `download_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `download_users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `download_users`
--

LOCK TABLES `download_users` WRITE;
/*!40000 ALTER TABLE `download_users` DISABLE KEYS */;
/*!40000 ALTER TABLE `download_users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_accounts`
--

DROP TABLE IF EXISTS `email_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `provider` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `access_token` varchar(255) DEFAULT NULL,
  `refresh_token` varchar(255) DEFAULT NULL,
  `expires` tinyint(1) DEFAULT '1',
  `expires_in` int(11) DEFAULT '3600',
  `expires_at` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_accounts`
--

LOCK TABLES `email_accounts` WRITE;
/*!40000 ALTER TABLE `email_accounts` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_accounts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `email_notifications`
--

DROP TABLE IF EXISTS `email_notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `email_notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `due_task` tinyint(1) DEFAULT NULL,
  `task_assign` tinyint(1) DEFAULT NULL,
  `deal_assign` tinyint(1) DEFAULT NULL,
  `donot_send` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `email_notifications`
--

LOCK TABLES `email_notifications` WRITE;
/*!40000 ALTER TABLE `email_notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `email_notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `feed_keywords`
--

DROP TABLE IF EXISTS `feed_keywords`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed_keywords` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `feed_tags` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_feed_keywords_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `feed_keywords`
--

LOCK TABLES `feed_keywords` WRITE;
/*!40000 ALTER TABLE `feed_keywords` DISABLE KEYS */;
/*!40000 ALTER TABLE `feed_keywords` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `images`
--

DROP TABLE IF EXISTS `images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `image_file_name` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_file_size` int(11) DEFAULT NULL,
  `image_updated_at` datetime DEFAULT NULL,
  `imagable_type` varchar(255) DEFAULT NULL,
  `imagable_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_images_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `images`
--

LOCK TABLES `images` WRITE;
/*!40000 ALTER TABLE `images` DISABLE KEYS */;
/*!40000 ALTER TABLE `images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `individual_contacts`
--

DROP TABLE IF EXISTS `individual_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `individual_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `position` varchar(255) DEFAULT NULL,
  `messanger_type` varchar(255) DEFAULT NULL,
  `messanger_id` varchar(255) DEFAULT NULL,
  `linkedin_url` varchar(255) DEFAULT NULL,
  `facebook_url` varchar(255) DEFAULT NULL,
  `twitter_url` varchar(255) DEFAULT NULL,
  `company_contact_id` int(11) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `is_public` tinyint(1) NOT NULL DEFAULT '1',
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `contact_ref_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `time_zone` varchar(255) DEFAULT NULL,
  `is_customer` tinyint(1) NOT NULL DEFAULT '0',
  `subscribe_blog_mail` tinyint(1) NOT NULL DEFAULT '1',
  `subscribe_blog_date` datetime DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `country_id` int(11) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `work_phone` varchar(255) DEFAULT NULL,
  `description` text,
  `is_csv` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `individual_contacts`
--

LOCK TABLES `individual_contacts` WRITE;
/*!40000 ALTER TABLE `individual_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `individual_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `industries`
--

DROP TABLE IF EXISTS `industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `industries` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_industries_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `industries`
--

LOCK TABLES `industries` WRITE;
/*!40000 ALTER TABLE `industries` DISABLE KEYS */;
/*!40000 ALTER TABLE `industries` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoice_items`
--

DROP TABLE IF EXISTS `invoice_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_items` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` text,
  `amount` varchar(255) DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `qty` int(11) DEFAULT NULL,
  `rate` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoice_items`
--

LOCK TABLES `invoice_items` WRITE;
/*!40000 ALTER TABLE `invoice_items` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoice_items` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `contact_id` int(11) DEFAULT NULL,
  `contact_type` varchar(255) DEFAULT NULL,
  `currency` varchar(255) DEFAULT NULL,
  `invoice_no` varchar(255) DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `cc_mail_id` varchar(255) DEFAULT NULL,
  `status` varchar(255) DEFAULT NULL,
  `notes` text,
  `terms_and_condition` text,
  `transaction_date` date DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `logo_url` varchar(255) DEFAULT NULL,
  `deal_id` int(11) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `company_address` text,
  `tax` float DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `invoices`
--

LOCK TABLES `invoices` WRITE;
/*!40000 ALTER TABLE `invoices` DISABLE KEYS */;
/*!40000 ALTER TABLE `invoices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `mail_letters`
--

DROP TABLE IF EXISTS `mail_letters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `mail_letters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `mailable_type` varchar(255) DEFAULT NULL,
  `mailable_id` int(11) DEFAULT NULL,
  `mailto` varchar(255) DEFAULT NULL,
  `subject` varchar(255) DEFAULT NULL,
  `description` text,
  `mail_by` int(11) DEFAULT NULL,
  `mail_cc` varchar(255) DEFAULT NULL,
  `mail_bcc` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `contact_info` text,
  PRIMARY KEY (`id`),
  KEY `index_mail_letters_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `mail_letters`
--

LOCK TABLES `mail_letters` WRITE;
/*!40000 ALTER TABLE `mail_letters` DISABLE KEYS */;
/*!40000 ALTER TABLE `mail_letters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `note_attachments`
--

DROP TABLE IF EXISTS `note_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `note_attachments` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `note_id` int(11) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `organization_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_note_attachments_on_note_id` (`note_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `note_attachments`
--

LOCK TABLES `note_attachments` WRITE;
/*!40000 ALTER TABLE `note_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `note_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notes`
--

DROP TABLE IF EXISTS `notes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `notes` text,
  `file_description` varchar(255) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `notable_type` varchar(255) DEFAULT NULL,
  `notable_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `created_by` int(11) DEFAULT NULL,
  `is_public` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_notes_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notes`
--

LOCK TABLES `notes` WRITE;
/*!40000 ALTER TABLE `notes` DISABLE KEYS */;
/*!40000 ALTER TABLE `notes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `opportunities`
--

DROP TABLE IF EXISTS `opportunities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `opportunities` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `quarter` int(11) DEFAULT NULL,
  `total_deals` int(11) DEFAULT NULL,
  `won_deals` int(11) DEFAULT NULL,
  `win` float DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `opportunities`
--

LOCK TABLES `opportunities` WRITE;
/*!40000 ALTER TABLE `opportunities` DISABLE KEYS */;
/*!40000 ALTER TABLE `opportunities` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `organization_types`
--

DROP TABLE IF EXISTS `organization_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organization_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organization_types`
--

LOCK TABLES `organization_types` WRITE;
/*!40000 ALTER TABLE `organization_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `organization_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `organizations`
--

DROP TABLE IF EXISTS `organizations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `organizations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `total_users` int(11) DEFAULT NULL,
  `size_id` int(11) DEFAULT NULL,
  `is_premium` tinyint(1) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `deleted_at` datetime DEFAULT NULL,
  `beta_account_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `auth_token` varchar(255) DEFAULT NULL,
  `description` text,
  `organization_type` int(11) DEFAULT NULL,
  `current_sub_id` int(11) DEFAULT NULL,
  `current_user_limit` int(11) DEFAULT NULL,
  `current_storage_limit` int(11) DEFAULT NULL,
  `trial_expires_on` datetime DEFAULT NULL,
  `is_sub_active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `organizations`
--

LOCK TABLES `organizations` WRITE;
/*!40000 ALTER TABLE `organizations` DISABLE KEYS */;
INSERT INTO `organizations` VALUES (1,'My Organization','myorg@test.com','www.test.com',10,3,NULL,1,NULL,NULL,'2017-05-01 10:27:07','2017-05-01 10:27:07','MS1NeSBPcmdhbml6YXRpb24tMjAxNy0wNS0wMSAxMDoyNzowNw==\n',NULL,NULL,NULL,NULL,NULL,'2017-05-03 10:36:28',0),(2,'Amit',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2017-05-01 10:29:47','2017-05-02 07:01:54','Mi1BbWl0LTIwMTctMDUtMDEgMTA6Mjk6NDc=\n',NULL,NULL,3,2,NULL,'2017-05-02 07:01:54',1),(3,'A1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2017-05-01 10:33:17','2017-05-01 10:33:17','My1BMS0yMDE3LTA1LTAxIDEwOjMzOjE3\n',NULL,NULL,NULL,NULL,NULL,'2017-05-03 10:36:28',0),(4,'A2',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2017-05-01 10:35:10','2017-05-01 10:46:57','NC1BMi0yMDE3LTA1LTAxIDEwOjM1OjEw\n',NULL,NULL,1,1,NULL,'2017-05-01 10:46:57',0),(5,'z1',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'2017-05-02 10:24:29','2017-05-02 10:30:50','NS16MS0yMDE3LTA1LTAyIDEwOjI0OjI5\n',NULL,NULL,5,3,NULL,'2017-05-02 10:30:50',1);
/*!40000 ALTER TABLE `organizations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `payment_infos`
--

DROP TABLE IF EXISTS `payment_infos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_infos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `transaction_id` varchar(255) DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `transaction_date` datetime DEFAULT NULL,
  `last4_digit` varchar(255) DEFAULT NULL,
  `customer_id` varchar(255) DEFAULT NULL,
  `card_holder_name` varchar(255) DEFAULT NULL,
  `street` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `payment_token` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_payment_infos_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `payment_infos`
--

LOCK TABLES `payment_infos` WRITE;
/*!40000 ALTER TABLE `payment_infos` DISABLE KEYS */;
/*!40000 ALTER TABLE `payment_infos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phones`
--

DROP TABLE IF EXISTS `phones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `phones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `phone_no` varchar(255) DEFAULT NULL,
  `extension` varchar(255) DEFAULT NULL,
  `phone_type` varchar(255) DEFAULT NULL,
  `phoneble_type` varchar(255) DEFAULT NULL,
  `phoneble_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_phones_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phones`
--

LOCK TABLES `phones` WRITE;
/*!40000 ALTER TABLE `phones` DISABLE KEYS */;
INSERT INTO `phones` VALUES (1,4,'213212121',NULL,NULL,'User',4,'2017-05-01 10:38:43','2017-05-01 10:38:43'),(2,4,'213212121',NULL,NULL,'User',4,'2017-05-01 10:38:44','2017-05-01 10:38:44');
/*!40000 ALTER TABLE `phones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plugin_transactions`
--

DROP TABLE IF EXISTS `plugin_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plugin_transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `community_plugin_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `gmt_offset` varchar(255) DEFAULT NULL,
  `location` varchar(255) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `referrer` text,
  `transaction_id` text,
  `transaction_status` varchar(255) DEFAULT NULL,
  `invoice_id` int(11) DEFAULT NULL,
  `is_emailed` tinyint(1) DEFAULT NULL,
  `token` text,
  `download_date` datetime DEFAULT NULL,
  `latitude` float DEFAULT NULL,
  `longitude` float DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `download_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plugin_transactions`
--

LOCK TABLES `plugin_transactions` WRITE;
/*!40000 ALTER TABLE `plugin_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `plugin_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `plugins`
--

DROP TABLE IF EXISTS `plugins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plugins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `description` text,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `plugins`
--

LOCK TABLES `plugins` WRITE;
/*!40000 ALTER TABLE `plugins` DISABLE KEYS */;
/*!40000 ALTER TABLE `plugins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `priority_types`
--

DROP TABLE IF EXISTS `priority_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `priority_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `original_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_priority_types_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `priority_types`
--

LOCK TABLES `priority_types` WRITE;
/*!40000 ALTER TABLE `priority_types` DISABLE KEYS */;
INSERT INTO `priority_types` VALUES (1,1,'Hot',1,'2017-05-01 10:27:07','2017-05-01 10:27:07'),(2,1,'Warm',2,'2017-05-01 10:27:07','2017-05-01 10:27:07'),(3,1,'Cold',3,'2017-05-01 10:27:07','2017-05-01 10:27:07'),(4,1,'Hot',1,'2017-05-01 10:27:10','2017-05-01 10:27:10'),(5,1,'Warm',2,'2017-05-01 10:27:10','2017-05-01 10:27:10'),(6,1,'Cold',3,'2017-05-01 10:27:10','2017-05-01 10:27:10'),(7,2,'Hot',1,'2017-05-01 10:29:47','2017-05-01 10:29:47'),(8,2,'Warm',2,'2017-05-01 10:29:47','2017-05-01 10:29:47'),(9,2,'Cold',3,'2017-05-01 10:29:47','2017-05-01 10:29:47'),(10,3,'Hot',1,'2017-05-01 10:33:17','2017-05-01 10:33:17'),(11,3,'Warm',2,'2017-05-01 10:33:17','2017-05-01 10:33:17'),(12,3,'Cold',3,'2017-05-01 10:33:17','2017-05-01 10:33:17'),(13,4,'Hot',1,'2017-05-01 10:35:10','2017-05-01 10:35:10'),(14,4,'Warm',2,'2017-05-01 10:35:10','2017-05-01 10:35:10'),(15,4,'Cold',3,'2017-05-01 10:35:10','2017-05-01 10:35:10'),(16,5,'Hot',1,'2017-05-02 10:24:29','2017-05-02 10:24:29'),(17,5,'Warm',2,'2017-05-02 10:24:29','2017-05-02 10:24:29'),(18,5,'Cold',3,'2017-05-02 10:24:29','2017-05-02 10:24:29');
/*!40000 ALTER TABLE `priority_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_roles_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,1,'Sales','2017-05-01 10:27:07','2017-05-01 10:27:07'),(2,1,'Lead Generator','2017-05-01 10:27:07','2017-05-01 10:27:07'),(3,2,'Sales','2017-05-01 10:29:47','2017-05-01 10:29:47'),(4,2,'Lead Generator','2017-05-01 10:29:47','2017-05-01 10:29:47'),(5,3,'Sales','2017-05-01 10:33:17','2017-05-01 10:33:17'),(6,3,'Lead Generator','2017-05-01 10:33:17','2017-05-01 10:33:17'),(7,4,'Sales','2017-05-01 10:35:10','2017-05-01 10:35:10'),(8,4,'Lead Generator','2017-05-01 10:35:10','2017-05-01 10:35:10'),(9,5,'Sales','2017-05-02 10:24:29','2017-05-02 10:24:29'),(10,5,'Lead Generator','2017-05-02 10:24:29','2017-05-02 10:24:29');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sales_cycles`
--

DROP TABLE IF EXISTS `sales_cycles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sales_cycles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `year` int(11) DEFAULT NULL,
  `quarter` int(11) DEFAULT NULL,
  `average` int(11) DEFAULT NULL,
  `shortest` int(11) DEFAULT NULL,
  `longest` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sales_cycles`
--

LOCK TABLES `sales_cycles` WRITE;
/*!40000 ALTER TABLE `sales_cycles` DISABLE KEYS */;
/*!40000 ALTER TABLE `sales_cycles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `schema_migrations`
--

DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  UNIQUE KEY `unique_schema_migrations` (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `schema_migrations`
--

LOCK TABLES `schema_migrations` WRITE;
/*!40000 ALTER TABLE `schema_migrations` DISABLE KEYS */;
INSERT INTO `schema_migrations` VALUES ('20131022120349'),('20131022125401'),('20131022130057'),('20131022130650'),('20131022131805'),('20131022134450'),('20131022134655'),('20131022134712'),('20131022134830'),('20131022135431'),('20131022135759'),('20131022135821'),('20131023053934'),('20131023053956'),('20131023054024'),('20131023054112'),('20131023054137'),('20131023054149'),('20131023054211'),('20131023054222'),('20131023054246'),('20131025065144'),('20131025093741'),('20131025095628'),('20131029051436'),('20131031093934'),('20131031124825'),('20131031141719'),('20131031141810'),('20131101111307'),('20131105063400'),('20131105093601'),('20131107111254'),('20131111065210'),('20131112110029'),('20131113060955'),('20131114082022'),('20131114100048'),('20131209130918'),('20131209132328'),('20131210072512'),('20131215233453'),('20131217063200'),('20140103111546'),('20140106135858'),('20140106140309'),('20140108092001'),('20140109053322'),('20140109125632'),('20140113113039'),('20140115111933'),('20140203101910'),('20140206040621'),('20140213075102'),('20140228040346'),('20140310065627'),('20140319070656'),('20140324052435'),('20140324053208'),('20140414091313'),('20140415091949'),('20140421103154'),('20140429134449'),('20140430142618'),('20140501142809'),('20140508054842'),('20140515094201'),('20140515100218'),('20140516071057'),('20140612071320'),('20140612140030'),('20140613062840'),('20140613065225'),('20140616071031'),('20140616100431'),('20140617094447'),('20140618053956'),('20140619053811'),('20140619053812'),('20140619053813'),('20140619091514'),('20140625053059'),('20140630094607'),('20140703114239'),('20140711052139'),('20140711063448'),('20140716122426'),('20140716122457'),('20140718085558'),('20140723081639'),('20140724084701'),('20140724094258'),('20140724094652'),('20140724101604'),('20140724141822'),('20140728134422'),('20140804142656'),('20140912063658'),('20140912124611'),('20160707095358'),('20160721062527'),('20160730060153'),('20160803064518'),('20160812153042'),('20160818110411'),('20160820083228'),('20160820083401'),('20160822103527'),('20160822115357'),('20160822124722'),('20160823064707'),('20160823114438'),('20160824053422'),('20160824094444'),('20160824141527'),('20160920141556'),('20160921051619'),('20160922133959'),('20160923085559'),('20161003102440'),('20161019084718'),('20161024091749'),('20161024094540'),('20161026055333'),('20161026055831'),('20161031092002'),('20161031092018'),('20161101103520'),('20161102085434'),('20161107103857'),('20170114055841'),('20170123120812'),('20170125051007'),('20170127104654'),('20170205152837'),('20170209074029'),('20170217102033'),('20170227132538'),('20170228115835'),('20170302062033'),('20170306092141'),('20170310062145'),('20170310074559'),('20170315140742'),('20170321075004'),('20170322095339'),('20170328050417'),('20170330064330'),('20170405092902'),('20170405124331'),('20170406062529'),('20170406112013'),('20170406112555'),('20170412134732'),('20170421071131'),('20170421113239'),('20170424054821'),('20170424055719'),('20170425121432'),('20170426052738');
/*!40000 ALTER TABLE `schema_migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sent_email_opens`
--

DROP TABLE IF EXISTS `sent_email_opens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sent_email_opens` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `ip_address` varchar(255) DEFAULT NULL,
  `opened` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `activity_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sent_email_opens`
--

LOCK TABLES `sent_email_opens` WRITE;
/*!40000 ALTER TABLE `sent_email_opens` DISABLE KEYS */;
/*!40000 ALTER TABLE `sent_email_opens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sent_emails`
--

DROP TABLE IF EXISTS `sent_emails`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sent_emails` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `sent` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sent_emails`
--

LOCK TABLES `sent_emails` WRITE;
/*!40000 ALTER TABLE `sent_emails` DISABLE KEYS */;
/*!40000 ALTER TABLE `sent_emails` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sources`
--

DROP TABLE IF EXISTS `sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sources` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_sources_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sources`
--

LOCK TABLES `sources` WRITE;
/*!40000 ALTER TABLE `sources` DISABLE KEYS */;
/*!40000 ALTER TABLE `sources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscribe_blog_logs`
--

DROP TABLE IF EXISTS `subscribe_blog_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscribe_blog_logs` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `contact_id` int(11) DEFAULT NULL,
  `contact_email` varchar(255) DEFAULT NULL,
  `blog_title` text,
  `blog_content` text,
  `status` varchar(255) DEFAULT NULL,
  `error_message` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscribe_blog_logs`
--

LOCK TABLES `subscribe_blog_logs` WRITE;
/*!40000 ALTER TABLE `subscribe_blog_logs` DISABLE KEYS */;
/*!40000 ALTER TABLE `subscribe_blog_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `subscriptions`
--

DROP TABLE IF EXISTS `subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `plan_id` text,
  `user_limit` int(11) DEFAULT NULL,
  `storage_limit` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `price` float DEFAULT NULL,
  `free_trial_days` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_subscriptions_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `subscriptions`
--

LOCK TABLES `subscriptions` WRITE;
/*!40000 ALTER TABLE `subscriptions` DISABLE KEYS */;
INSERT INTO `subscriptions` VALUES (1,'rr9r',1,NULL,1,5,NULL,NULL,'2017-05-01 10:43:28','2017-05-01 10:43:28');
/*!40000 ALTER TABLE `subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `taggings`
--

DROP TABLE IF EXISTS `taggings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `taggings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `tag_id` int(11) DEFAULT NULL,
  `taggable_id` int(11) DEFAULT NULL,
  `taggable_type` varchar(255) DEFAULT NULL,
  `tagger_id` int(11) DEFAULT NULL,
  `tagger_type` varchar(255) DEFAULT NULL,
  `context` varchar(128) DEFAULT NULL,
  `created_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `taggings_idx` (`tag_id`,`taggable_id`,`taggable_type`,`context`,`tagger_id`,`tagger_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `taggings`
--

LOCK TABLES `taggings` WRITE;
/*!40000 ALTER TABLE `taggings` DISABLE KEYS */;
/*!40000 ALTER TABLE `taggings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tags`
--

DROP TABLE IF EXISTS `tags`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tags` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `taggings_count` int(11) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_tags_on_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tags`
--

LOCK TABLES `tags` WRITE;
/*!40000 ALTER TABLE `tags` DISABLE KEYS */;
/*!40000 ALTER TABLE `tags` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_outcomes`
--

DROP TABLE IF EXISTS `task_outcomes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_outcomes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `task_out_type` varchar(255) DEFAULT NULL,
  `task_duration` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_outcomes`
--

LOCK TABLES `task_outcomes` WRITE;
/*!40000 ALTER TABLE `task_outcomes` DISABLE KEYS */;
INSERT INTO `task_outcomes` VALUES (1,'Call me Tomorrow','Call','1 Day','2017-05-01 10:26:58','2017-05-01 10:26:58'),(2,'Call me after one month','Call','1 Month','2017-05-01 10:26:58','2017-05-01 10:26:58'),(3,'Send Pricing chart','Quote','1 Day','2017-05-01 10:26:58','2017-05-01 10:26:58'),(4,'Send Company Brochure','Documentation','1 Day','2017-05-01 10:26:58','2017-05-01 10:26:58'),(5,'Voice Message','Call','1 Day','2017-05-01 10:26:58','2017-05-01 10:26:58'),(6,'Not interested in our service',NULL,NULL,'2017-05-01 10:26:58','2017-05-01 10:26:58'),(7,'Do Not want to outsource',NULL,NULL,'2017-05-01 10:26:58','2017-05-01 10:26:58'),(8,'Others',NULL,NULL,'2017-05-01 10:26:58','2017-05-01 10:26:58');
/*!40000 ALTER TABLE `task_outcomes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_priority_types`
--

DROP TABLE IF EXISTS `task_priority_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_priority_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `original_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_task_priority_types_on_organization_id` (`organization_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_priority_types`
--

LOCK TABLES `task_priority_types` WRITE;
/*!40000 ALTER TABLE `task_priority_types` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_priority_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_types`
--

DROP TABLE IF EXISTS `task_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_task_types_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=62 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_types`
--

LOCK TABLES `task_types` WRITE;
/*!40000 ALTER TABLE `task_types` DISABLE KEYS */;
INSERT INTO `task_types` VALUES (1,1,'Appointment','2017-05-01 10:27:07','2017-05-01 10:27:07'),(2,1,'Billing','2017-05-01 10:27:07','2017-05-01 10:27:07'),(3,1,'Call','2017-05-01 10:27:07','2017-05-01 10:27:07'),(4,1,'Documentation','2017-05-01 10:27:07','2017-05-01 10:27:07'),(5,1,'Email','2017-05-01 10:27:07','2017-05-01 10:27:07'),(6,1,'Follow-up','2017-05-01 10:27:07','2017-05-01 10:27:07'),(7,1,'Meeting','2017-05-01 10:27:07','2017-05-01 10:27:07'),(8,1,'None','2017-05-01 10:27:07','2017-05-01 10:27:07'),(9,1,'Quote','2017-05-01 10:27:07','2017-05-01 10:27:07'),(10,1,'Thank-you','2017-05-01 10:27:07','2017-05-01 10:27:07'),(11,1,'Call','2017-05-01 10:27:07','2017-05-01 10:27:07'),(12,1,'Skype','2017-05-01 10:27:07','2017-05-01 10:27:07'),(13,1,'Email','2017-05-01 10:27:07','2017-05-01 10:27:07'),(14,1,'Appointment','2017-05-01 10:27:10','2017-05-01 10:27:10'),(15,1,'Billing','2017-05-01 10:27:10','2017-05-01 10:27:10'),(16,1,'Documentation','2017-05-01 10:27:10','2017-05-01 10:27:10'),(17,1,'Follow-up','2017-05-01 10:27:10','2017-05-01 10:27:10'),(18,1,'Meeting','2017-05-01 10:27:10','2017-05-01 10:27:10'),(19,1,'None','2017-05-01 10:27:10','2017-05-01 10:27:10'),(20,1,'Quote','2017-05-01 10:27:10','2017-05-01 10:27:10'),(21,1,'Thank-you','2017-05-01 10:27:10','2017-05-01 10:27:10'),(22,2,'Appointment','2017-05-01 10:29:47','2017-05-01 10:29:47'),(23,2,'Billing','2017-05-01 10:29:47','2017-05-01 10:29:47'),(24,2,'Call','2017-05-01 10:29:47','2017-05-01 10:29:47'),(25,2,'Documentation','2017-05-01 10:29:47','2017-05-01 10:29:47'),(26,2,'Email','2017-05-01 10:29:47','2017-05-01 10:29:47'),(27,2,'Follow-up','2017-05-01 10:29:47','2017-05-01 10:29:47'),(28,2,'Meeting','2017-05-01 10:29:47','2017-05-01 10:29:47'),(29,2,'None','2017-05-01 10:29:47','2017-05-01 10:29:47'),(30,2,'Quote','2017-05-01 10:29:47','2017-05-01 10:29:47'),(31,2,'Thank-you','2017-05-01 10:29:47','2017-05-01 10:29:47'),(32,3,'Appointment','2017-05-01 10:33:17','2017-05-01 10:33:17'),(33,3,'Billing','2017-05-01 10:33:17','2017-05-01 10:33:17'),(34,3,'Call','2017-05-01 10:33:17','2017-05-01 10:33:17'),(35,3,'Documentation','2017-05-01 10:33:17','2017-05-01 10:33:17'),(36,3,'Email','2017-05-01 10:33:17','2017-05-01 10:33:17'),(37,3,'Follow-up','2017-05-01 10:33:17','2017-05-01 10:33:17'),(38,3,'Meeting','2017-05-01 10:33:17','2017-05-01 10:33:17'),(39,3,'None','2017-05-01 10:33:17','2017-05-01 10:33:17'),(40,3,'Quote','2017-05-01 10:33:17','2017-05-01 10:33:17'),(41,3,'Thank-you','2017-05-01 10:33:17','2017-05-01 10:33:17'),(42,4,'Appointment','2017-05-01 10:35:10','2017-05-01 10:35:10'),(43,4,'Billing','2017-05-01 10:35:10','2017-05-01 10:35:10'),(44,4,'Call','2017-05-01 10:35:10','2017-05-01 10:35:10'),(45,4,'Documentation','2017-05-01 10:35:10','2017-05-01 10:35:10'),(46,4,'Email','2017-05-01 10:35:10','2017-05-01 10:35:10'),(47,4,'Follow-up','2017-05-01 10:35:10','2017-05-01 10:35:10'),(48,4,'Meeting','2017-05-01 10:35:10','2017-05-01 10:35:10'),(49,4,'None','2017-05-01 10:35:10','2017-05-01 10:35:10'),(50,4,'Quote','2017-05-01 10:35:10','2017-05-01 10:35:10'),(51,4,'Thank-you','2017-05-01 10:35:10','2017-05-01 10:35:10'),(52,5,'Appointment','2017-05-02 10:24:29','2017-05-02 10:24:29'),(53,5,'Billing','2017-05-02 10:24:29','2017-05-02 10:24:29'),(54,5,'Call','2017-05-02 10:24:29','2017-05-02 10:24:29'),(55,5,'Documentation','2017-05-02 10:24:29','2017-05-02 10:24:29'),(56,5,'Email','2017-05-02 10:24:29','2017-05-02 10:24:29'),(57,5,'Follow-up','2017-05-02 10:24:29','2017-05-02 10:24:29'),(58,5,'Meeting','2017-05-02 10:24:29','2017-05-02 10:24:29'),(59,5,'None','2017-05-02 10:24:29','2017-05-02 10:24:29'),(60,5,'Quote','2017-05-02 10:24:29','2017-05-02 10:24:29'),(61,5,'Thank-you','2017-05-02 10:24:29','2017-05-02 10:24:29');
/*!40000 ALTER TABLE `task_types` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tasks`
--

DROP TABLE IF EXISTS `tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tasks` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `task_type_id` int(11) DEFAULT NULL,
  `assigned_to` int(11) DEFAULT NULL,
  `priority_id` int(11) DEFAULT NULL,
  `deal_id` int(11) DEFAULT NULL,
  `due_date` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `mail_to` varchar(255) DEFAULT NULL,
  `taskable_id` int(11) DEFAULT NULL,
  `taskable_type` varchar(255) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `is_completed` tinyint(1) NOT NULL DEFAULT '0',
  `task_note` text,
  `recurring_type` varchar(255) NOT NULL DEFAULT 'none',
  `rec_end_date` datetime DEFAULT NULL,
  `parent_id` int(11) DEFAULT NULL,
  `is_event` tinyint(1) NOT NULL DEFAULT '0',
  `event_end_date` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_tasks_on_organization_id` (`organization_id`),
  KEY `index_tasks_on_task_type_id` (`task_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tasks`
--

LOCK TABLES `tasks` WRITE;
/*!40000 ALTER TABLE `tasks` DISABLE KEYS */;
/*!40000 ALTER TABLE `tasks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_contacts`
--

DROP TABLE IF EXISTS `temp_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_contacts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `import_by` int(11) DEFAULT NULL,
  `domain` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `gender` varchar(255) DEFAULT NULL,
  `birthday` varchar(255) DEFAULT NULL,
  `relation` varchar(255) DEFAULT NULL,
  `address_1` varchar(255) DEFAULT NULL,
  `address_2` varchar(255) DEFAULT NULL,
  `city` varchar(255) DEFAULT NULL,
  `region` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `postcode` varchar(255) DEFAULT NULL,
  `phone_number` varchar(255) DEFAULT NULL,
  `profile_picture` varchar(255) DEFAULT NULL,
  `updated` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_contacts`
--

LOCK TABLES `temp_contacts` WRITE;
/*!40000 ALTER TABLE `temp_contacts` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_contacts` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_file_uploads`
--

DROP TABLE IF EXISTS `temp_file_uploads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_file_uploads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `attachment_file_name` varchar(255) DEFAULT NULL,
  `attachment_content_type` varchar(255) DEFAULT NULL,
  `attachment_file_size` int(11) DEFAULT NULL,
  `attachment_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_file_uploads`
--

LOCK TABLES `temp_file_uploads` WRITE;
/*!40000 ALTER TABLE `temp_file_uploads` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_file_uploads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_images`
--

DROP TABLE IF EXISTS `temp_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_images` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `avatar_file_name` varchar(255) DEFAULT NULL,
  `avatar_content_type` varchar(255) DEFAULT NULL,
  `avatar_file_size` int(11) DEFAULT NULL,
  `avatar_updated_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_temp_images_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_images`
--

LOCK TABLES `temp_images` WRITE;
/*!40000 ALTER TABLE `temp_images` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_images` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_leads`
--

DROP TABLE IF EXISTS `temp_leads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_leads` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `title` text,
  `priority` varchar(255) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `company_size` varchar(255) DEFAULT NULL,
  `website` varchar(255) DEFAULT NULL,
  `contact_name` varchar(255) DEFAULT NULL,
  `designation` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `extension` varchar(255) DEFAULT NULL,
  `mobile` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `technology` varchar(255) DEFAULT NULL,
  `source` text,
  `location` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `industry` varchar(255) DEFAULT NULL,
  `comments` text,
  `created_dt` datetime DEFAULT NULL,
  `description` text,
  `assigned_to` varchar(255) DEFAULT NULL,
  `facebook_url` varchar(255) DEFAULT NULL,
  `linkedin_url` varchar(255) DEFAULT NULL,
  `twitter_url` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `skype_id` varchar(255) DEFAULT NULL,
  `task_type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_leads`
--

LOCK TABLES `temp_leads` WRITE;
/*!40000 ALTER TABLE `temp_leads` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_leads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `temp_tables`
--

DROP TABLE IF EXISTS `temp_tables`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `temp_tables` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `phone` varchar(255) DEFAULT NULL,
  `title` varchar(255) DEFAULT NULL,
  `company_name` varchar(255) DEFAULT NULL,
  `web_site` varchar(255) DEFAULT NULL,
  `address` text,
  `ref_site` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `city` varchar(255) DEFAULT NULL,
  `state` varchar(255) DEFAULT NULL,
  `zipcode` varchar(255) DEFAULT NULL,
  `country` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `note` text,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `temp_tables`
--

LOCK TABLES `temp_tables` WRITE;
/*!40000 ALTER TABLE `temp_tables` DISABLE KEYS */;
/*!40000 ALTER TABLE `temp_tables` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `transactions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `btsubscription_id` text,
  `transaction_id` text,
  `plan_id` text,
  `status` varchar(255) DEFAULT NULL,
  `subscription_price` float DEFAULT NULL,
  `amount` float DEFAULT NULL,
  `balance` float DEFAULT NULL,
  `next_billing_date` datetime DEFAULT NULL,
  `transaction_type` text,
  `invoice_id` int(11) DEFAULT NULL,
  `ip` varchar(255) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `user_subscription_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_transactions_on_organization_id` (`organization_id`),
  KEY `index_transactions_on_user_id` (`user_id`),
  KEY `index_transactions_on_user_subscription_id` (`user_subscription_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `transactions`
--

LOCK TABLES `transactions` WRITE;
/*!40000 ALTER TABLE `transactions` DISABLE KEYS */;
INSERT INTO `transactions` VALUES (1,'fnx3yb','ejf0w57r','1','Active',5,5,0,'2017-06-01 00:00:00','subscription_went_active',NULL,'10.0.2.2',4,3,1,'2017-05-01 10:55:02','2017-05-01 10:55:02');
/*!40000 ALTER TABLE `transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_labels`
--

DROP TABLE IF EXISTS `user_labels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_labels` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `color` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_labels_on_organization_id` (`organization_id`),
  KEY `index_user_labels_on_user_id` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_labels`
--

LOCK TABLES `user_labels` WRITE;
/*!40000 ALTER TABLE `user_labels` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_labels` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_plugins`
--

DROP TABLE IF EXISTS `user_plugins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_plugins` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `plugin_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_plugins_on_user_id` (`user_id`),
  KEY `index_user_plugins_on_plugin_id` (`plugin_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_plugins`
--

LOCK TABLES `user_plugins` WRITE;
/*!40000 ALTER TABLE `user_plugins` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_plugins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_preferences`
--

DROP TABLE IF EXISTS `user_preferences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_preferences` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `weekly_digest` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `digest_mail_frequency` varchar(255) DEFAULT 'weekly',
  PRIMARY KEY (`id`),
  KEY `index_user_preferences_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_preferences`
--

LOCK TABLES `user_preferences` WRITE;
/*!40000 ALTER TABLE `user_preferences` DISABLE KEYS */;
INSERT INTO `user_preferences` VALUES (1,1,NULL,1,'2017-05-01 10:29:48','2017-05-01 10:29:48','weekly'),(2,2,NULL,1,'2017-05-01 10:33:17','2017-05-01 10:33:17','weekly'),(3,3,NULL,1,'2017-05-01 10:35:10','2017-05-01 10:35:10','weekly'),(4,4,4,1,'2017-05-01 10:38:43','2017-05-01 10:38:43','weekly'),(5,5,NULL,1,'2017-05-02 10:24:29','2017-05-02 10:24:29','weekly');
/*!40000 ALTER TABLE `user_preferences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_roles_on_organization_id` (`organization_id`),
  KEY `index_user_roles_on_role_id` (`role_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_subscriptions`
--

DROP TABLE IF EXISTS `user_subscriptions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_subscriptions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `subscription_id` int(11) DEFAULT NULL,
  `user_limit` int(11) DEFAULT NULL,
  `storage_limit` int(11) DEFAULT NULL,
  `price` float DEFAULT NULL,
  `btsubscription_id` text,
  `btprofile_id` text,
  `cc_token` text,
  `payment_status` varchar(255) DEFAULT NULL,
  `is_cancel` tinyint(1) DEFAULT '0',
  `is_updown` varchar(255) DEFAULT NULL,
  `subscription_start_date` datetime DEFAULT NULL,
  `next_billing_date` datetime DEFAULT NULL,
  `cancel_date` datetime DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `organization_id` int(11) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `is_cancel_payment_fail` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_user_subscriptions_on_organization_id` (`organization_id`),
  KEY `index_user_subscriptions_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_subscriptions`
--

LOCK TABLES `user_subscriptions` WRITE;
/*!40000 ALTER TABLE `user_subscriptions` DISABLE KEYS */;
INSERT INTO `user_subscriptions` VALUES (1,1,1,NULL,5,'fnx3yb','157307419','85xrdp','Active',0,'started','2017-05-01 00:00:00','2017-06-01 00:00:00',NULL,0,4,3,'2017-05-01 10:46:57','2017-05-01 10:46:57',0),(2,1,2,NULL,10,'dfq5fg','223744373','cjwdv8','Active',1,'started','2017-05-02 00:00:00','2017-06-02 00:00:00','2017-05-02 06:42:12',0,2,1,'2017-05-02 06:41:32','2017-05-02 06:42:12',0),(3,1,2,NULL,10,'5b6p76','601640934','f5z86y','Active',0,'started','2017-05-02 00:00:00','2017-06-02 00:00:00',NULL,1,2,1,'2017-05-02 07:01:54','2017-05-02 07:01:54',0),(4,1,12,NULL,60,'29n7w2','199183439','2qrv8p','Active',0,'started','2017-05-02 00:00:00','2017-06-02 00:00:00',NULL,0,5,5,'2017-05-02 10:25:29','2017-05-02 10:30:50',0),(5,1,3,NULL,15,'29n7w2','199183439','2qrv8p','Active',0,'down','2017-05-02 00:00:00','2017-06-02 00:00:00',NULL,1,5,5,'2017-05-02 10:30:50','2017-05-02 10:30:50',0);
/*!40000 ALTER TABLE `user_subscriptions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `email` varchar(255) NOT NULL DEFAULT '',
  `first_name` varchar(255) DEFAULT NULL,
  `last_name` varchar(255) DEFAULT NULL,
  `role_id` int(11) DEFAULT NULL,
  `target` int(11) DEFAULT NULL,
  `admin_type` int(11) DEFAULT NULL,
  `encrypted_password` varchar(255) DEFAULT '',
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime DEFAULT NULL,
  `remember_created_at` datetime DEFAULT NULL,
  `sign_in_count` int(11) NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime DEFAULT NULL,
  `last_sign_in_at` datetime DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmed_at` datetime DEFAULT NULL,
  `confirmation_sent_at` datetime DEFAULT NULL,
  `unconfirmed_email` varchar(255) DEFAULT NULL,
  `failed_attempts` int(11) NOT NULL DEFAULT '0',
  `unlock_token` varchar(255) DEFAULT NULL,
  `locked_at` datetime DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  `time_zone` varchar(255) DEFAULT NULL,
  `invitation_token` varchar(255) DEFAULT NULL,
  `invitation_created_at` datetime DEFAULT NULL,
  `invitation_sent_at` datetime DEFAULT NULL,
  `invitation_accepted_at` datetime DEFAULT NULL,
  `invitation_limit` int(11) DEFAULT NULL,
  `invited_by_id` int(11) DEFAULT NULL,
  `invited_by_type` varchar(255) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `task_date` datetime DEFAULT NULL,
  `digest_mail_date` varchar(255) DEFAULT NULL,
  `priority_label` int(11) NOT NULL DEFAULT '0',
  `provider` varchar(255) DEFAULT NULL,
  `uid` varchar(255) DEFAULT NULL,
  `token` varchar(255) DEFAULT NULL,
  `gmail_related_id` int(11) DEFAULT NULL,
  `is_blocked` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_invitation_token` (`invitation_token`),
  KEY `index_users_on_organization_id` (`organization_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,2,'amit.mohanty@andolasoft.co.in',NULL,NULL,NULL,NULL,1,'$2a$10$0Vrc4Kd4u9/s1A1LwrzDvO0.l9cGkTICgKOlbtZC3mNNvVej8vRYG',NULL,NULL,NULL,2,'2017-05-03 06:33:54','2017-05-02 06:40:08','10.0.2.2','10.0.2.2',NULL,'2017-05-01 10:29:47',NULL,NULL,0,NULL,NULL,'2017-05-01 10:29:48','2017-05-03 06:33:54',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,NULL,NULL,NULL,NULL,0),(2,3,'a1@gmail.com',NULL,NULL,NULL,NULL,1,'$2a$10$0zOACT17Gcij1gIw4C1IdehF74P0reWj4jxWa/opT5Al258QBRJQ6',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,'2017-05-01 10:33:17',NULL,NULL,0,NULL,NULL,'2017-05-01 10:33:17','2017-05-01 10:34:34',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,NULL,NULL,NULL,NULL,0),(3,4,'a2@gmail.com',NULL,NULL,NULL,NULL,1,'$2a$10$1GDXnQPJgRwWGIKSxE0O2OfXv0wS93a7ks8tjoyQq4o1ABuAjS35u',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,'2017-05-01 10:35:10',NULL,NULL,0,NULL,NULL,'2017-05-01 10:35:10','2017-05-01 10:35:42',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,NULL,NULL,NULL,NULL,0),(4,4,'p1@gmail.com','P1','A2',7,NULL,2,'$2a$10$5Muh57Go.uik6tlL1N/rGOn1v7CTM2ycH5cL3iIHmRHwykz0gwqtu',NULL,NULL,NULL,1,'2017-05-01 10:40:18','2017-05-01 10:40:18','10.0.2.2','10.0.2.2',NULL,'2017-05-01 10:40:18',NULL,NULL,0,NULL,NULL,'2017-05-01 10:38:43','2017-05-01 10:40:18','Pacific Time (US & Canada)',NULL,'2017-05-01 10:38:44','2017-05-01 10:38:44','2017-05-01 10:40:18',NULL,3,'User',1,NULL,NULL,0,NULL,NULL,NULL,NULL,0),(5,5,'z1@gmail.com',NULL,NULL,NULL,NULL,1,'$2a$10$AJ5mtu3Jt/5Pcf1thavece0vK5siJMUoVnE0lSzpGILxb7HtxOgMO',NULL,NULL,NULL,0,NULL,NULL,NULL,NULL,NULL,'2017-05-02 10:24:29',NULL,NULL,0,NULL,NULL,'2017-05-02 10:24:29','2017-05-02 10:24:29',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,0,NULL,NULL,NULL,NULL,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `web_forms`
--

DROP TABLE IF EXISTS `web_forms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `web_forms` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` int(11) DEFAULT NULL,
  `form_unique_id` varchar(255) DEFAULT NULL,
  `form_name` varchar(255) DEFAULT NULL,
  `user_responsible` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `is_display_thank_you_page` tinyint(1) DEFAULT NULL,
  `external_link` varchar(255) DEFAULT NULL,
  `send_email_notification` tinyint(1) DEFAULT NULL,
  `field_names` text,
  `form_html_code` text,
  `created_by` int(11) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT '1',
  `email_to` varchar(255) DEFAULT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `web_forms`
--

LOCK TABLES `web_forms` WRITE;
/*!40000 ALTER TABLE `web_forms` DISABLE KEYS */;
/*!40000 ALTER TABLE `web_forms` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `widgets`
--

DROP TABLE IF EXISTS `widgets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `widgets` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) DEFAULT NULL,
  `organization_id` int(11) DEFAULT NULL,
  `chart` tinyint(1) DEFAULT '1',
  `activities` tinyint(1) DEFAULT '1',
  `feeds` tinyint(1) DEFAULT '1',
  `tasks` tinyint(1) DEFAULT '1',
  `usage` tinyint(1) DEFAULT '1',
  `summary` tinyint(1) DEFAULT '1',
  `pie_chart` tinyint(1) DEFAULT '1',
  `column_chart` tinyint(1) DEFAULT '1',
  `line_chart` tinyint(1) DEFAULT '1',
  `statistics_chart` tinyint(1) DEFAULT '1',
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_widgets_on_user_id` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `widgets`
--

LOCK TABLES `widgets` WRITE;
/*!40000 ALTER TABLE `widgets` DISABLE KEYS */;
INSERT INTO `widgets` VALUES (1,1,NULL,1,1,1,1,1,1,1,1,1,1,'2017-05-01 10:29:48','2017-05-01 10:29:48'),(2,2,NULL,1,1,1,1,1,1,1,1,1,1,'2017-05-01 10:33:17','2017-05-01 10:33:17'),(3,3,NULL,1,1,1,1,1,1,1,1,1,1,'2017-05-01 10:35:10','2017-05-01 10:35:10'),(4,4,4,1,1,1,1,1,1,1,1,1,1,'2017-05-01 10:38:43','2017-05-01 10:38:43'),(5,5,NULL,1,1,1,1,1,1,1,1,1,1,'2017-05-02 10:24:29','2017-05-02 10:24:29');
/*!40000 ALTER TABLE `widgets` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2017-05-03 13:02:42
