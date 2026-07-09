SET FOREIGN_KEY_CHECKS=0;
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: entities
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `entities`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `entities` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci */;

USE `entities`;

--
-- Table structure for table `barangays_districts`
--

DROP TABLE IF EXISTS `barangays_districts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `barangays_districts` (
  `barangay_district_id` int(11) NOT NULL AUTO_INCREMENT,
  `barangay_district_name` char(60) NOT NULL,
  `town_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`barangay_district_id`),
  KEY `fk_barangays_districts_towns1_idx` (`town_id`),
  CONSTRAINT `barangays_districts_to_towns` FOREIGN KEY (`town_id`) REFERENCES `towns` (`town_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1000004 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `counter_parties`
--

DROP TABLE IF EXISTS `counter_parties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `counter_parties` (
  `entity_id` int(11) NOT NULL,
  `counter_party` int(11) NOT NULL,
  KEY `counter_parties_to_entities1_idx` (`entity_id`),
  KEY `counter_parties_to_entities2_idx` (`counter_party`),
  CONSTRAINT `counter_parties_to_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `counter_parties_to_entities2` FOREIGN KEY (`counter_party`) REFERENCES `entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `counter_parties_modifications`
--

DROP TABLE IF EXISTS `counter_parties_modifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `counter_parties_modifications` (
  `non_persons_entry_id` int(11) DEFAULT NULL,
  `persons_entry_id` int(11) DEFAULT NULL,
  `counter_party` int(11) NOT NULL,
  KEY `fk_counter_parties_modifications_entities2_idx` (`counter_party`),
  KEY `fk_counter_parties_modifications_non_persons_modifications1_idx` (`non_persons_entry_id`),
  KEY `fk_counter_parties_modifications_persons_modifications1_idx` (`persons_entry_id`),
  CONSTRAINT `fk_counter_parties_modifications_entities2` FOREIGN KEY (`counter_party`) REFERENCES `entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_counter_parties_modifications_non_persons_modifications1` FOREIGN KEY (`non_persons_entry_id`) REFERENCES `non_persons_modifications` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_counter_parties_modifications_persons_modifications1` FOREIGN KEY (`persons_entry_id`) REFERENCES `persons_modifications` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `countries`
--

DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `countries` (
  `country_id` int(11) NOT NULL AUTO_INCREMENT,
  `country_name` char(60) NOT NULL,
  PRIMARY KEY (`country_id`)
) ENGINE=InnoDB AUTO_INCREMENT=257 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `entities`
--

DROP TABLE IF EXISTS `entities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entities` (
  `entity_id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) DEFAULT NULL,
  `nonperson_id` int(11) DEFAULT NULL,
  `creation_datetime` datetime NOT NULL COMMENT 'value will be based from the database server date and time\n',
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`entity_id`),
  KEY `entities_to_persons_idx` (`person_id`),
  KEY `entities_to_non_persons_idx` (`nonperson_id`),
  KEY `entities_to_application_users_idx` (`created_by`),
  CONSTRAINT `entities_to_application_users` FOREIGN KEY (`created_by`) REFERENCES `application_users_entity`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `entities_to_non_persons` FOREIGN KEY (`nonperson_id`) REFERENCES `non_persons` (`nonperson_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `entities_to_persons` FOREIGN KEY (`person_id`) REFERENCES `persons` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1002469 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `entities_groupings`
--

DROP TABLE IF EXISTS `entities_groupings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entities_groupings` (
  `entity_id` int(11) NOT NULL,
  `group_id` int(11) NOT NULL,
  KEY `fk_entities_groupings_groupings1_idx` (`group_id`),
  KEY `fk_entities_groupings_entities1_idx` (`entity_id`),
  CONSTRAINT `fk_entities_groupings_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_entities_groupings_groupings1` FOREIGN KEY (`group_id`) REFERENCES `groupings` (`group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `generational_suffixes`
--

DROP TABLE IF EXISTS `generational_suffixes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `generational_suffixes` (
  `generational_suffixes_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`generational_suffixes_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `groupings`
--

DROP TABLE IF EXISTS `groupings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `groupings` (
  `group_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(100) DEFAULT NULL,
  PRIMARY KEY (`group_id`)
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `identification_cards`
--

DROP TABLE IF EXISTS `identification_cards`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `identification_cards` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(80) NOT NULL,
  `person` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=73 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `non_persons`
--

DROP TABLE IF EXISTS `non_persons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `non_persons` (
  `nonperson_id` int(11) NOT NULL AUTO_INCREMENT,
  `nonperson_name` char(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `contact_id1` int(11) NOT NULL,
  `contact_id2` int(11) DEFAULT NULL,
  `tax_identification` char(20) NOT NULL DEFAULT '',
  `adrs_house_street` char(250) NOT NULL DEFAULT '',
  `adrs_barangay` int(11) DEFAULT NULL,
  `zip_code` char(5) NOT NULL DEFAULT '',
  `email_address1` char(100) NOT NULL DEFAULT '',
  `email_address2` char(100) NOT NULL DEFAULT '',
  `email_address3` char(100) NOT NULL DEFAULT '',
  `landphone1` char(13) NOT NULL DEFAULT '',
  `landphone2` char(13) NOT NULL DEFAULT '',
  `mobilephone1` char(13) NOT NULL DEFAULT '',
  `mobilephone2` char(13) NOT NULL DEFAULT '',
  `tax_template_id` int(11) NOT NULL DEFAULT 1,
  PRIMARY KEY (`nonperson_id`),
  KEY `non_persons_to_barangays_districts_idx` (`adrs_barangay`),
  KEY `non_persons_to_entities1_idx` (`contact_id1`),
  KEY `non_persons_to_entities2_idx` (`contact_id2`),
  KEY `fk_non_persons_tax_template1_idx` (`tax_template_id`),
  CONSTRAINT `fk_non_persons_tax_template1` FOREIGN KEY (`tax_template_id`) REFERENCES `tax_template` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `non_persons_to_barangays_districts` FOREIGN KEY (`adrs_barangay`) REFERENCES `barangays_districts` (`barangay_district_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `non_persons_to_entities1` FOREIGN KEY (`contact_id1`) REFERENCES `entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `non_persons_to_entities2` FOREIGN KEY (`contact_id2`) REFERENCES `entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3666 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `non_persons_modifications`
--

DROP TABLE IF EXISTS `non_persons_modifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `non_persons_modifications` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `nonperson_id` int(11) NOT NULL,
  `nonperson_name` char(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_bin NOT NULL,
  `contact_id1` int(11) DEFAULT NULL,
  `contact_id2` int(11) DEFAULT NULL,
  `tax_identification` char(20) NOT NULL DEFAULT '',
  `adrs_house_street` char(250) NOT NULL DEFAULT '',
  `adrs_barangay` int(11) DEFAULT NULL,
  `zip_code` char(5) NOT NULL DEFAULT '',
  `email_address1` char(100) NOT NULL DEFAULT '',
  `email_address2` char(100) NOT NULL DEFAULT '',
  `email_address3` char(100) NOT NULL DEFAULT '',
  `landphone1` char(13) NOT NULL DEFAULT '',
  `landphone2` char(13) NOT NULL DEFAULT '',
  `mobilephone1` char(13) NOT NULL DEFAULT '',
  `mobilephone2` char(13) NOT NULL DEFAULT '',
  `reason` char(250) NOT NULL,
  `modified_by` int(11) NOT NULL,
  `modification_datetime` datetime NOT NULL COMMENT 'value will be based from database server’s date and time',
  `approved_by` int(11) DEFAULT NULL,
  `approval_datetime` datetime DEFAULT NULL,
  `tax_template_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `non_persons_modifications_to_non_persons_idx` (`nonperson_id`),
  KEY `non_persons_modifications_to_application_users1_idx` (`modified_by`),
  KEY `non_persons_modifications_to_application_users2_idx` (`approved_by`),
  KEY `non_persons_modifications_to_entities1_idx` (`contact_id1`),
  KEY `non_persons_modifications_to_entities2_idx` (`contact_id2`),
  KEY `non_persons_modifications_to_barangays_districts_idx` (`adrs_barangay`),
  KEY `non_persons_modifications_tax_template_FK` (`tax_template_id`),
  KEY `non_persons_modifications_groupings_FK` (`group_id`),
  CONSTRAINT `non_persons_modifications_groupings_FK` FOREIGN KEY (`group_id`) REFERENCES `groupings` (`group_id`),
  CONSTRAINT `non_persons_modifications_tax_template_FK` FOREIGN KEY (`tax_template_id`) REFERENCES `tax_template` (`template_id`),
  CONSTRAINT `non_persons_modifications_to_application_users1` FOREIGN KEY (`modified_by`) REFERENCES `application_users_entity`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `non_persons_modifications_to_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_entity`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `non_persons_modifications_to_barangays_districts` FOREIGN KEY (`adrs_barangay`) REFERENCES `barangays_districts` (`barangay_district_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `non_persons_modifications_to_entities1` FOREIGN KEY (`contact_id1`) REFERENCES `entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `non_persons_modifications_to_entities2` FOREIGN KEY (`contact_id2`) REFERENCES `entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `non_persons_modificationsto_to_non_persons` FOREIGN KEY (`nonperson_id`) REFERENCES `non_persons` (`nonperson_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=98 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `other_ids`
--

DROP TABLE IF EXISTS `other_ids`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `other_ids` (
  `person_id` int(11) DEFAULT NULL,
  `nonperson_id` int(11) DEFAULT NULL,
  `card_id` int(11) NOT NULL,
  `reference` char(30) NOT NULL,
  `image` mediumblob DEFAULT NULL,
  KEY `fk_other_ids_persons1_idx` (`person_id`),
  KEY `fk_other_ids_identification_cards1_idx` (`card_id`),
  KEY `fk_other_ids_nonpersons` (`nonperson_id`),
  CONSTRAINT `fk_other_ids_identification_cards1` FOREIGN KEY (`card_id`) REFERENCES `identification_cards` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_other_ids_nonpersons` FOREIGN KEY (`nonperson_id`) REFERENCES `non_persons` (`nonperson_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_other_ids_persons1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `other_ids_modifications`
--

DROP TABLE IF EXISTS `other_ids_modifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `other_ids_modifications` (
  `entry_id` int(11) NOT NULL,
  `person_id` int(11) DEFAULT NULL,
  `nonperson_id` int(11) DEFAULT NULL,
  `card_id` int(11) NOT NULL,
  `reference` char(30) NOT NULL,
  `image` mediumblob DEFAULT NULL,
  KEY `fk_other_ids_modifications_persons1_idx` (`person_id`),
  KEY `fk_other_ids_modifications_identification_cards1_idx` (`card_id`),
  KEY `other_ids_modifications_persons_modifications_FK` (`entry_id`),
  CONSTRAINT `fk_other_ids_modifications_identification_cards1` FOREIGN KEY (`card_id`) REFERENCES `identification_cards` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_other_ids_modifications_persons1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `person_images`
--

DROP TABLE IF EXISTS `person_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `person_images` (
  `person_id` int(11) NOT NULL,
  `doc_image` mediumblob NOT NULL,
  `modifications_entry_id` int(11) DEFAULT NULL,
  KEY `fk_person_images_persons1_idx` (`person_id`),
  KEY `fk_person_images_persons_modifications1_idx` (`modifications_entry_id`),
  CONSTRAINT `fk_person_images_persons1` FOREIGN KEY (`person_id`) REFERENCES `persons` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_person_images_persons_modifications1` FOREIGN KEY (`modifications_entry_id`) REFERENCES `persons_modifications` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `persons`
--

DROP TABLE IF EXISTS `persons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `persons` (
  `person_id` int(11) NOT NULL AUTO_INCREMENT,
  `lastname` char(30) NOT NULL DEFAULT '',
  `firstname` char(30) NOT NULL DEFAULT '',
  `middlename` char(30) NOT NULL DEFAULT '',
  `sex` tinyint(1) NOT NULL,
  `birthdate` date DEFAULT '0000-00-00',
  `civilstatus` tinyint(1) NOT NULL DEFAULT 0,
  `tax_identification` char(20) NOT NULL DEFAULT '',
  `adrs_house_street` char(250) NOT NULL DEFAULT '',
  `adrs_barangay` int(11) DEFAULT NULL,
  `zip_code` char(5) NOT NULL DEFAULT '',
  `email_address1` char(100) NOT NULL DEFAULT '',
  `email_address2` char(100) NOT NULL DEFAULT '',
  `email_address3` char(100) NOT NULL DEFAULT '',
  `landphone1` char(13) NOT NULL DEFAULT '',
  `landphone2` char(13) NOT NULL DEFAULT '',
  `mobilephone1` char(13) NOT NULL DEFAULT '',
  `mobilephone2` char(13) NOT NULL DEFAULT '',
  `tax_template_id` int(11) NOT NULL DEFAULT 1,
  `generational_suffix_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`person_id`),
  KEY `fk_persons_barangays_districts1_idx` (`adrs_barangay`),
  KEY `fk_persons_tax_template1_idx` (`tax_template_id`),
  KEY `fk_persons_generational_suffixes1` (`generational_suffix_id`),
  CONSTRAINT `fk_persons_generational_suffixes1` FOREIGN KEY (`generational_suffix_id`) REFERENCES `generational_suffixes` (`generational_suffixes_id`),
  CONSTRAINT `fk_persons_tax_template1` FOREIGN KEY (`tax_template_id`) REFERENCES `tax_template` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `persons_to_barangays_districts` FOREIGN KEY (`adrs_barangay`) REFERENCES `barangays_districts` (`barangay_district_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=313 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `persons_modifications`
--

DROP TABLE IF EXISTS `persons_modifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `persons_modifications` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `person_id` int(11) NOT NULL,
  `lastname` char(30) NOT NULL DEFAULT '',
  `firstname` char(30) NOT NULL DEFAULT '',
  `middlename` char(30) NOT NULL DEFAULT '',
  `sex` tinyint(1) NOT NULL DEFAULT 0,
  `birthdate` date NOT NULL DEFAULT '1900-01-01',
  `civilstatus` tinyint(1) NOT NULL DEFAULT 0,
  `tax_identification` char(20) NOT NULL DEFAULT '',
  `adrs_house_street` char(250) NOT NULL DEFAULT '',
  `adrs_barangay` int(11) DEFAULT NULL,
  `zip_code` char(5) NOT NULL DEFAULT '',
  `email_address1` char(100) NOT NULL DEFAULT '',
  `email_address2` char(100) NOT NULL DEFAULT '',
  `email_address3` char(100) NOT NULL DEFAULT '',
  `landphone1` char(13) NOT NULL DEFAULT '',
  `landphone2` char(13) NOT NULL DEFAULT '',
  `mobilephone1` char(13) NOT NULL DEFAULT '',
  `mobilephone2` char(13) NOT NULL DEFAULT '',
  `reason` char(250) NOT NULL,
  `modified_by` int(11) NOT NULL,
  `modification_datetime` datetime NOT NULL COMMENT 'value will be based from database server’s date and time',
  `approved_by` int(11) DEFAULT NULL,
  `approval_datetime` datetime DEFAULT NULL,
  `tax_template_id` int(11) DEFAULT NULL,
  `group_id` int(11) DEFAULT NULL,
  `image` mediumblob DEFAULT NULL,
  `generational_suffixes_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `persons_modifications_to_persons_idx` (`person_id`),
  KEY `persons_modifications_to_application_users1_idx` (`modified_by`),
  KEY `persons_modifications_to_application_users2_idx` (`approved_by`),
  KEY `persons_modifications_barangays_to_districts_idx` (`adrs_barangay`),
  KEY `persons_modifications_tax_template_FK` (`tax_template_id`),
  KEY `persons_modifications_groupings_FK` (`group_id`),
  KEY `persons_modifications_generational_suffixes_FK` (`generational_suffixes_id`),
  CONSTRAINT `persons_modifications_generational_suffixes_FK` FOREIGN KEY (`generational_suffixes_id`) REFERENCES `generational_suffixes` (`generational_suffixes_id`),
  CONSTRAINT `persons_modifications_groupings_FK` FOREIGN KEY (`group_id`) REFERENCES `groupings` (`group_id`),
  CONSTRAINT `persons_modifications_tax_template_FK` FOREIGN KEY (`tax_template_id`) REFERENCES `tax_template` (`template_id`),
  CONSTRAINT `persons_modifications_to_application_users1` FOREIGN KEY (`modified_by`) REFERENCES `application_users_entity`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `persons_modifications_to_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_entity`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `persons_modifications_to_barangays_districts` FOREIGN KEY (`adrs_barangay`) REFERENCES `barangays_districts` (`barangay_district_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `persons_modifications_to_persons` FOREIGN KEY (`person_id`) REFERENCES `persons` (`person_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=237 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `property_address`
--

DROP TABLE IF EXISTS `property_address`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `property_address` (
  `barangay_district_id` int(11) NOT NULL,
  `property_id` int(11) NOT NULL,
  KEY `fk_property_address_barangays_districts1_idx` (`barangay_district_id`),
  CONSTRAINT `fk_property_address_barangays_districts1` FOREIGN KEY (`barangay_district_id`) REFERENCES `barangays_districts` (`barangay_district_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `provinces_states`
--

DROP TABLE IF EXISTS `provinces_states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `provinces_states` (
  `province_state_id` int(11) NOT NULL AUTO_INCREMENT,
  `province_state_name` char(60) NOT NULL,
  `country_id` int(11) NOT NULL,
  PRIMARY KEY (`province_state_id`),
  KEY `fk_provinces_states_countries1_idx` (`country_id`),
  CONSTRAINT `provinces_states_to_countries` FOREIGN KEY (`country_id`) REFERENCES `countries` (`country_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=121 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `relationships`
--

DROP TABLE IF EXISTS `relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relationships` (
  `relationship_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(50) NOT NULL,
  PRIMARY KEY (`relationship_id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `tax_template`
--

DROP TABLE IF EXISTS `tax_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `tax_template` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(100) NOT NULL,
  `vat_rate` decimal(6,2) NOT NULL DEFAULT 0.12,
  `wtax_rate` decimal(6,2) NOT NULL DEFAULT 0.05,
  `vat_inclusive` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`template_id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `towns`
--

DROP TABLE IF EXISTS `towns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `towns` (
  `town_id` int(11) NOT NULL AUTO_INCREMENT,
  `town_name` char(60) NOT NULL,
  `province_state_id` int(11) NOT NULL,
  PRIMARY KEY (`town_id`),
  KEY `fk_towns_provinces_states1_idx` (`province_state_id`),
  CONSTRAINT `towns_to_provinces_states` FOREIGN KEY (`province_state_id`) REFERENCES `provinces_states` (`province_state_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1660 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:41
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: entities_udf_and_views
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `entities_udf_and_views`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `entities_udf_and_views` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `entities_udf_and_views`;

--
-- Temporary table structure for view `entity_counter_parties`
--

DROP TABLE IF EXISTS `entity_counter_parties`;
/*!50001 DROP VIEW IF EXISTS `entity_counter_parties`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `entity_counter_parties` AS SELECT
 1 AS `entity_id`,
  1 AS `entity_counter_parties` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `entity_details`
--

DROP TABLE IF EXISTS `entity_details`;
/*!50001 DROP VIEW IF EXISTS `entity_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `entity_details` AS SELECT
 1 AS `entity_id`,
  1 AS `is_person`,
  1 AS `person_nonperson_id`,
  1 AS `street`,
  1 AS `zip_code`,
  1 AS `billing_email`,
  1 AS `tel_no`,
  1 AS `phone_no`,
  1 AS `barangay`,
  1 AS `barangay_id`,
  1 AS `municipality`,
  1 AS `province`,
  1 AS `country`,
  1 AS `tax_identification`,
  1 AS `vat_rate`,
  1 AS `wtax_rate`,
  1 AS `vat_inclusive`,
  1 AS `group_id`,
  1 AS `group_name` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `entity_name`
--

DROP TABLE IF EXISTS `entity_name`;
/*!50001 DROP VIEW IF EXISTS `entity_name`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `entity_name` AS SELECT
 1 AS `is_person`,
  1 AS `person_nonperson_id`,
  1 AS `entity_id`,
  1 AS `customer_id`,
  1 AS `entity_name`,
  1 AS `customer_name`,
  1 AS `group_id`,
  1 AS `group_name` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `person_id_details`
--

DROP TABLE IF EXISTS `person_id_details`;
/*!50001 DROP VIEW IF EXISTS `person_id_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `person_id_details` AS SELECT
 1 AS `person_id`,
  1 AS `person_id_details` */;
SET character_set_client = @saved_cs_client;

--
-- Current Database: `entities_udf_and_views`
--

USE `entities_udf_and_views`;

--
-- Final view structure for view `entity_counter_parties`
--

/*!50001 DROP VIEW IF EXISTS `entity_counter_parties`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `entity_counter_parties` AS select `aa`.`entity_id` AS `entity_id`,json_arrayagg(json_object('counter_party_id',`aa`.`counter_party_id`,'bol_person',`aa`.`bol_person`,'prsn_nonprsn_id',`aa`.`prsn_nonprsn_id`,'counter_party_name',`aa`.`counter_party_name`) order by `aa`.`counter_party_name` ASC) AS `entity_counter_parties` from (select `a`.`entity_id` AS `entity_id`,`a`.`counter_party` AS `counter_party_id`,if(`c`.`person_id` is null,0,1) AS `bol_person`,if(`c`.`person_id` is null,`d`.`nonperson_id`,`c`.`person_id`) AS `prsn_nonprsn_id`,case when `c`.`person_id` is not null then concat(`c`.`lastname`,', ',`c`.`firstname`,' ',`c`.`middlename`) else `d`.`nonperson_name` end AS `counter_party_name` from (((`entities`.`counter_parties` `a` left join `entities`.`entities` `b` on(`a`.`counter_party` = `b`.`entity_id`)) left join `entities`.`persons` `c` on(`b`.`person_id` = `c`.`person_id`)) left join `entities`.`non_persons` `d` on(`b`.`nonperson_id` = `d`.`nonperson_id`))) `aa` group by `aa`.`entity_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `entity_details`
--

/*!50001 DROP VIEW IF EXISTS `entity_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `entity_details` AS select `e`.`entity_id` AS `entity_id`,1 AS `is_person`,`p`.`person_id` AS `person_nonperson_id`,`p`.`adrs_house_street` AS `street`,`p`.`zip_code` AS `zip_code`,coalesce(nullif(`p`.`email_address1`,''),nullif(`p`.`email_address2`,''),nullif(`p`.`email_address3`,'')) AS `billing_email`,coalesce(nullif(`p`.`landphone1`,''),nullif(`p`.`landphone2`,'')) AS `tel_no`,coalesce(nullif(`p`.`mobilephone1`,''),nullif(`p`.`mobilephone2`,'')) AS `phone_no`,`bd`.`barangay_district_name` AS `barangay`,`bd`.`barangay_district_id` AS `barangay_id`,`t`.`town_name` AS `municipality`,`ps`.`province_state_name` AS `province`,`c`.`country_name` AS `country`,`p`.`tax_identification` AS `tax_identification`,(select `tt`.`vat_rate` from `entities`.`tax_template` `tt` where `tt`.`template_id` = `p`.`tax_template_id`) AS `vat_rate`,(select `tt`.`wtax_rate` from `entities`.`tax_template` `tt` where `tt`.`template_id` = `p`.`tax_template_id`) AS `wtax_rate`,(select `tt`.`vat_inclusive` from `entities`.`tax_template` `tt` where `tt`.`template_id` = `p`.`tax_template_id`) AS `vat_inclusive`,(select `g`.`group_id` from (`entities`.`entities_groupings` `eg` join `entities`.`groupings` `g` on(`g`.`group_id` = `eg`.`group_id`)) where `eg`.`entity_id` = `e`.`entity_id` limit 1) AS `group_id`,(select `g`.`description` from (`entities`.`entities_groupings` `eg` join `entities`.`groupings` `g` on(`g`.`group_id` = `eg`.`group_id`)) where `eg`.`entity_id` = `e`.`entity_id` limit 1) AS `group_name` from (((((`entities`.`persons` `p` join `entities`.`barangays_districts` `bd` on(`p`.`adrs_barangay` = `bd`.`barangay_district_id`)) join `entities`.`towns` `t` on(`bd`.`town_id` = `t`.`town_id`)) join `entities`.`provinces_states` `ps` on(`t`.`province_state_id` = `ps`.`province_state_id`)) join `entities`.`countries` `c` on(`ps`.`country_id` = `c`.`country_id`)) join `entities`.`entities` `e` on(`p`.`person_id` = `e`.`person_id`)) union select `e`.`entity_id` AS `entity_id`,0 AS `is_person`,`np`.`nonperson_id` AS `person_nonperson_id`,`np`.`adrs_house_street` AS `street`,`np`.`zip_code` AS `zip_code`,coalesce(nullif(`np`.`email_address1`,''),nullif(`np`.`email_address2`,''),nullif(`np`.`email_address3`,'')) AS `billing_email`,coalesce(nullif(`np`.`landphone1`,''),nullif(`np`.`landphone2`,'')) AS `tel_no`,coalesce(nullif(`np`.`mobilephone1`,''),nullif(`np`.`mobilephone2`,'')) AS `phone_no`,`bd`.`barangay_district_name` AS `barangay`,`bd`.`barangay_district_id` AS `barangay_id`,`t`.`town_name` AS `municipality`,`ps`.`province_state_name` AS `province`,`c`.`country_name` AS `country`,`np`.`tax_identification` AS `tax_identification`,(select `tt`.`vat_rate` from `entities`.`tax_template` `tt` where `tt`.`template_id` = `np`.`tax_template_id`) AS `vat_rate`,(select `tt`.`wtax_rate` from `entities`.`tax_template` `tt` where `tt`.`template_id` = `np`.`tax_template_id`) AS `wtax_rate`,(select `tt`.`vat_inclusive` from `entities`.`tax_template` `tt` where `tt`.`template_id` = `np`.`tax_template_id`) AS `vat_inclusive`,(select `g`.`group_id` from (`entities`.`entities_groupings` `eg` join `entities`.`groupings` `g` on(`g`.`group_id` = `eg`.`group_id`)) where `eg`.`entity_id` = `e`.`entity_id` limit 1) AS `group_id`,(select `g`.`description` from (`entities`.`entities_groupings` `eg` join `entities`.`groupings` `g` on(`g`.`group_id` = `eg`.`group_id`)) where `eg`.`entity_id` = `e`.`entity_id` limit 1) AS `group_name` from (((((`entities`.`non_persons` `np` join `entities`.`barangays_districts` `bd` on(`np`.`adrs_barangay` = `bd`.`barangay_district_id`)) join `entities`.`towns` `t` on(`bd`.`town_id` = `t`.`town_id`)) join `entities`.`provinces_states` `ps` on(`t`.`province_state_id` = `ps`.`province_state_id`)) join `entities`.`countries` `c` on(`ps`.`country_id` = `c`.`country_id`)) join `entities`.`entities` `e` on(`np`.`nonperson_id` = `e`.`nonperson_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `entity_name`
--

/*!50001 DROP VIEW IF EXISTS `entity_name`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `entity_name` AS select `aa`.`is_person` AS `is_person`,`aa`.`person_nonperson_id` AS `person_nonperson_id`,`aa`.`entity_id` AS `entity_id`,`aa`.`customer_id` AS `customer_id`,`aa`.`entity_name` AS `entity_name`,`aa`.`entity_name` AS `customer_name`,(select `g`.`group_id` from (`entities`.`entities_groupings` `eg` join `entities`.`groupings` `g` on(`g`.`group_id` = `eg`.`group_id`)) where `eg`.`entity_id` = `aa`.`entity_id` limit 1) AS `group_id`,(select `g`.`description` from (`entities`.`entities_groupings` `eg` join `entities`.`groupings` `g` on(`g`.`group_id` = `eg`.`group_id`)) where `eg`.`entity_id` = `aa`.`entity_id` limit 1) AS `group_name` from (select `e`.`person_id` is not null AS `is_person`,coalesce(`e`.`person_id`,`e`.`nonperson_id`) AS `person_nonperson_id`,`e`.`entity_id` AS `entity_id`,concat('C',date_format(`e`.`creation_datetime`,'%m%Y'),'-',lpad(`e`.`entity_id`,6,'0')) AS `customer_id`,if(`p`.`person_id` is not null,concat(`p`.`lastname`,', ',`p`.`firstname`,' ',`p`.`middlename`),`np`.`nonperson_name`) AS `entity_name` from ((`entities`.`entities` `e` left join `entities`.`persons` `p` on(`e`.`person_id` = `p`.`person_id`)) left join `entities`.`non_persons` `np` on(`e`.`nonperson_id` = `np`.`nonperson_id`))) `aa` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `person_id_details`
--

/*!50001 DROP VIEW IF EXISTS `person_id_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `person_id_details` AS select `aa`.`person_id` AS `person_id`,json_arrayagg(json_object('person_id',`aa`.`person_id`,'card_id',`aa`.`card_id`,'card_name',`aa`.`card_name`,'reference',`aa`.`reference`) order by `aa`.`card_name` ASC) AS `person_id_details` from (select `a`.`person_id` AS `person_id`,`a`.`card_id` AS `card_id`,`b`.`description` AS `card_name`,`a`.`reference` AS `reference` from (`entities`.`other_ids` `a` join `entities`.`identification_cards` `b` on(`a`.`card_id` = `b`.`id`))) `aa` group by `aa`.`person_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:41
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: employees_profile
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `employees_profile`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `employees_profile` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci */;

USE `employees_profile`;

--
-- Table structure for table `accredited_overtime`
--

DROP TABLE IF EXISTS `accredited_overtime`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accredited_overtime` (
  `accredited_ot_id` int(11) NOT NULL AUTO_INCREMENT,
  `unit_id` int(11) NOT NULL,
  PRIMARY KEY (`accredited_ot_id`),
  KEY `fk_accredited_overtime_units1_idx` (`unit_id`),
  CONSTRAINT `fk_accredited_overtime_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `accredited_overtime_details`
--

DROP TABLE IF EXISTS `accredited_overtime_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `accredited_overtime_details` (
  `accredited_ot_id` int(11) NOT NULL,
  `main_department_id` int(11) NOT NULL,
  `sub_department_id` int(11) DEFAULT NULL,
  `num_of_hrs_before` int(11) NOT NULL DEFAULT 1,
  `num_of_hrs_after` int(11) NOT NULL DEFAULT 1,
  KEY `fk_accredited_overtime_details_accredited_overtime1_idx` (`accredited_ot_id`),
  KEY `fk_accredited_overtime_details_main_department1_idx` (`main_department_id`),
  KEY `fk_accredited_overtime_details_sub_deparment1` (`sub_department_id`),
  CONSTRAINT `fk_accredited_overtime_details_accredited_overtime1` FOREIGN KEY (`accredited_ot_id`) REFERENCES `accredited_overtime` (`accredited_ot_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_accredited_overtime_details_main_department1` FOREIGN KEY (`main_department_id`) REFERENCES `subscriber_common_tables`.`main_department` (`department_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_accredited_overtime_details_sub_deparment1` FOREIGN KEY (`sub_department_id`) REFERENCES `subscriber_common_tables`.`sub_deparment` (`sub_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `add_time`
--

DROP TABLE IF EXISTS `add_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `add_time` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `working_date` date NOT NULL,
  `recorded_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `approved` tinyint(4) DEFAULT 0,
  `cancelled_by` int(11) DEFAULT NULL,
  `cancelled` tinyint(4) DEFAULT 0,
  `datetime_recorded` datetime NOT NULL DEFAULT current_timestamp(),
  `datetime_approved` datetime DEFAULT NULL,
  `datetime_cancelled` datetime DEFAULT NULL,
  `submitted_by` int(11) DEFAULT NULL,
  `datetime_submitted` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_add_time_employees1_idx` (`employee_id`),
  KEY `fk_add_time_application_users1_idx` (`recorded_by`),
  KEY `fk_add_time_application_users2_idx` (`approved_by`),
  KEY `fk_add_time_application_users3_idx` (`cancelled_by`),
  CONSTRAINT `fk_add_time_application_users1` FOREIGN KEY (`recorded_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_add_time_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_add_time_application_users3` FOREIGN KEY (`cancelled_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_add_time_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `add_time_details`
--

DROP TABLE IF EXISTS `add_time_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `add_time_details` (
  `add_time_id` int(11) NOT NULL,
  `before_schedule` tinyint(1) DEFAULT 0,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime NOT NULL,
  `reason` text NOT NULL,
  `worked_on_break_time` int(11) DEFAULT 0,
  KEY `fk_add_time_details_add_time1_idx` (`add_time_id`),
  CONSTRAINT `fk_add_time_details_add_time1` FOREIGN KEY (`add_time_id`) REFERENCES `add_time` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `beneficiaries`
--

DROP TABLE IF EXISTS `beneficiaries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `beneficiaries` (
  `beneficiary_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `relation_id` int(11) NOT NULL,
  `entities_entity_id` int(11) NOT NULL,
  PRIMARY KEY (`beneficiary_id`),
  KEY `fk_beneficiaries_employees1_idx` (`employee_id`),
  KEY `fk_beneficiaries_relations1_idx` (`relation_id`),
  KEY `fk_beneficiaries_entities1_idx` (`entities_entity_id`),
  CONSTRAINT `fk_beneficiaries_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_beneficiaries_entities1` FOREIGN KEY (`entities_entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_beneficiaries_relations1` FOREIGN KEY (`relation_id`) REFERENCES `relations` (`relation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=84 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blocked_calendar_dates`
--

DROP TABLE IF EXISTS `blocked_calendar_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocked_calendar_dates` (
  `entry_id` int(11) NOT NULL,
  `from` date NOT NULL,
  `to` date NOT NULL,
  KEY `fk_blocked_calendar_dates_blocked_periods1_idx` (`entry_id`),
  CONSTRAINT `fk_blocked_calendar_dates_blocked_periods1` FOREIGN KEY (`entry_id`) REFERENCES `blocked_periods` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blocked_dates`
--

DROP TABLE IF EXISTS `blocked_dates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocked_dates` (
  `entry_id` int(11) NOT NULL,
  `from` tinyint(4) NOT NULL,
  `to` tinyint(4) NOT NULL,
  KEY `fk_blocked_dates_blocked_periods1_idx` (`entry_id`),
  CONSTRAINT `fk_blocked_dates_blocked_periods1` FOREIGN KEY (`entry_id`) REFERENCES `blocked_periods` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blocked_periods`
--

DROP TABLE IF EXISTS `blocked_periods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocked_periods` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(60) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_blocked_periods_application_users1_idx` (`created_by`),
  KEY `fk_blocked_periods_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_blocked_periods_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blocked_periods_main_departments`
--

DROP TABLE IF EXISTS `blocked_periods_main_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocked_periods_main_departments` (
  `department_id` int(11) NOT NULL,
  `blocked_period_entry_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  UNIQUE KEY `unique_period_department` (`blocked_period_entry_id`,`department_id`),
  KEY `fk_blocked_periods_main_departments_main_department1_idx` (`department_id`),
  KEY `fk_blocked_periods_main_departments_blocked_periods1_idx` (`blocked_period_entry_id`),
  KEY `fk_blocked_periods_main_departments_application_users1_idx` (`created_by`),
  KEY `fk_blocked_periods_main_departments_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_blocked_periods_main_departments_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_main_departments_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_main_departments_blocked_periods1` FOREIGN KEY (`blocked_period_entry_id`) REFERENCES `blocked_periods` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_main_departments_main_department1` FOREIGN KEY (`department_id`) REFERENCES `subscriber_common_tables`.`main_department` (`department_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blocked_periods_units`
--

DROP TABLE IF EXISTS `blocked_periods_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocked_periods_units` (
  `unit_id` int(11) NOT NULL,
  `blocked_period_entry_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  UNIQUE KEY `unique_period_unit` (`blocked_period_entry_id`,`unit_id`),
  KEY `fk_blocked_periods_units_units1_idx` (`unit_id`),
  KEY `fk_blocked_periods_units_blocked_periods1_idx` (`blocked_period_entry_id`),
  KEY `fk_blocked_periods_units_application_users1_idx` (`created_by`),
  KEY `fk_blocked_periods_units_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_blocked_periods_units_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_units_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_units_blocked_periods1` FOREIGN KEY (`blocked_period_entry_id`) REFERENCES `blocked_periods` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_units_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `blocked_periods_units_main_departments`
--

DROP TABLE IF EXISTS `blocked_periods_units_main_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `blocked_periods_units_main_departments` (
  `blocked_period_entry_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `main_department_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  UNIQUE KEY `unique_period_unit_department` (`blocked_period_entry_id`,`unit_id`,`main_department_id`),
  KEY `fk_blocked_periods_units_main_departments_blocked_periods1_idx` (`blocked_period_entry_id`),
  KEY `fk_blocked_periods_units_main_departments_units1_idx` (`unit_id`),
  KEY `fk_blocked_periods_units_main_departments_main_department1_idx` (`main_department_id`),
  KEY `fk_blocked_periods_units_main_departments_application_users_idx` (`created_by`),
  KEY `fk_blocked_periods_units_main_departments_application_users_idx1` (`modified_by`),
  CONSTRAINT `fk_blocked_periods_units_main_departments_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_units_main_departments_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_units_main_departments_blocked_periods1` FOREIGN KEY (`blocked_period_entry_id`) REFERENCES `blocked_periods` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_units_main_departments_main_department1` FOREIGN KEY (`main_department_id`) REFERENCES `subscriber_common_tables`.`main_department` (`department_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_blocked_periods_units_main_departments_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `change_employee_schedule`
--

DROP TABLE IF EXISTS `change_employee_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `change_employee_schedule` (
  `change_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `datetime_created` datetime DEFAULT current_timestamp(),
  `imposed` tinyint(1) DEFAULT 0,
  `unit_payroll_id` int(11) DEFAULT NULL,
  `recorded_by` int(11) NOT NULL,
  PRIMARY KEY (`change_id`),
  KEY `fk_change_employee_schedule_employees1_idx` (`employee_id`),
  KEY `fk_change_employee_schedule_payroll_per_unit1_idx` (`unit_payroll_id`),
  KEY `fk_change_employee_schedule_application_users1_idx` (`recorded_by`),
  CONSTRAINT `fk_change_employee_schedule_application_users1` FOREIGN KEY (`recorded_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_change_employee_schedule_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_change_employee_schedule_payroll_per_unit1` FOREIGN KEY (`unit_payroll_id`) REFERENCES `payroll`.`payroll_per_unit` (`unit_payroll_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `change_employee_schedule_details`
--

DROP TABLE IF EXISTS `change_employee_schedule_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `change_employee_schedule_details` (
  `change_id` int(11) NOT NULL,
  `day_number` int(11) NOT NULL DEFAULT 1,
  `date_selected` date NOT NULL,
  `start_time` time NOT NULL,
  `end_time` time NOT NULL,
  `remark` varchar(145) NOT NULL,
  KEY `fk_change_employee_schedule_details_change_employee_schedul_idx` (`change_id`),
  CONSTRAINT `fk_change_employee_schedule_details_change_employee_schedule1` FOREIGN KEY (`change_id`) REFERENCES `change_employee_schedule` (`change_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `change_employee_schedule_swap_rd`
--

DROP TABLE IF EXISTS `change_employee_schedule_swap_rd`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `change_employee_schedule_swap_rd` (
  `change_id` int(11) NOT NULL,
  `rest_day_number` int(11) NOT NULL,
  KEY `fk_change_employee_schedule_rest_day_number_change_employee_idx` (`change_id`),
  CONSTRAINT `fk_change_employee_schedule_rest_day_number_change_employee_s1` FOREIGN KEY (`change_id`) REFERENCES `change_employee_schedule` (`change_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `default_policy_template`
--

DROP TABLE IF EXISTS `default_policy_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `default_policy_template` (
  `template_id` int(11) DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `datetime_updated` datetime DEFAULT NULL,
  KEY `fk_default_policy_template_policies_templates1_idx` (`template_id`),
  KEY `fk_default_policy_template_application_users1_idx` (`updated_by`),
  CONSTRAINT `fk_default_policy_template_application_users1` FOREIGN KEY (`updated_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_default_policy_template_policies_templates1` FOREIGN KEY (`template_id`) REFERENCES `policies_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `degree`
--

DROP TABLE IF EXISTS `degree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `degree` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deparments_jobs`
--

DROP TABLE IF EXISTS `deparments_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deparments_jobs` (
  `department_id` int(11) NOT NULL,
  `job_id` int(11) NOT NULL,
  KEY `fk_deparments_jobs_main_department1_idx` (`department_id`),
  KEY `fk_deparments_jobs_job_references1_idx` (`job_id`),
  CONSTRAINT `fk_deparments_jobs_job_references1` FOREIGN KEY (`job_id`) REFERENCES `job_references` (`reference_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_deparments_jobs_main_department1` FOREIGN KEY (`department_id`) REFERENCES `subscriber_common_tables`.`main_department` (`department_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dependents`
--

DROP TABLE IF EXISTS `dependents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dependents` (
  `employee_id` int(11) NOT NULL,
  `entity_id` int(11) NOT NULL,
  `relation_id` int(11) NOT NULL,
  KEY `fk_dependents_employees1_idx` (`employee_id`),
  KEY `fk_dependents_entities1_idx` (`entity_id`),
  KEY `fk_dependents_relations1_idx` (`relation_id`),
  CONSTRAINT `fk_dependents_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_dependents_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_dependents_relations1` FOREIGN KEY (`relation_id`) REFERENCES `relations` (`relation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `education_backgrounds`
--

DROP TABLE IF EXISTS `education_backgrounds`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `education_backgrounds` (
  `employee_id` int(11) NOT NULL,
  `school_id` int(11) NOT NULL,
  `education_id` int(11) NOT NULL,
  `date_graduated` date NOT NULL,
  `degree` char(100) DEFAULT NULL,
  `town_id` int(11) DEFAULT NULL,
  `phone_01` char(15) DEFAULT NULL,
  `phone_02` char(15) DEFAULT NULL,
  `degree_id` int(11) DEFAULT NULL,
  `town_name` varchar(150) DEFAULT NULL,
  KEY `fk_education_backgrounds_employees1_idx` (`employee_id`),
  KEY `fk_education_backgrounds_educational_level1_idx` (`education_id`),
  KEY `fk_education_backgrounds_schools1_idx` (`school_id`),
  KEY `education_backgrounds_degree_FK` (`degree_id`),
  CONSTRAINT `education_backgrounds_degree_FK` FOREIGN KEY (`degree_id`) REFERENCES `degree` (`id`),
  CONSTRAINT `fk_education_backgrounds_educational_level1` FOREIGN KEY (`education_id`) REFERENCES `educational_level` (`education_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_education_backgrounds_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_education_backgrounds_schools1` FOREIGN KEY (`school_id`) REFERENCES `schools` (`school_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `educational_level`
--

DROP TABLE IF EXISTS `educational_level`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `educational_level` (
  `education_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(50) DEFAULT NULL,
  PRIMARY KEY (`education_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `emergency_contacts`
--

DROP TABLE IF EXISTS `emergency_contacts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `emergency_contacts` (
  `entities_entity_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `relation_id` int(11) NOT NULL,
  KEY `fk_emergency_contacts_entities1_idx` (`entities_entity_id`),
  KEY `fk_emergency_contacts_employees1_idx` (`employee_id`),
  KEY `fk_emergency_contacts_relations1_idx` (`relation_id`),
  CONSTRAINT `fk_emergency_contacts_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_emergency_contacts_entities1` FOREIGN KEY (`entities_entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_emergency_contacts_relations1` FOREIGN KEY (`relation_id`) REFERENCES `relations` (`relation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_add_time`
--

DROP TABLE IF EXISTS `employee_add_time`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employee_add_time` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `add_time_date` date NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_employee_add_time_employees1_idx` (`employee_id`),
  CONSTRAINT `fk_employee_add_time_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_add_time_details`
--

DROP TABLE IF EXISTS `employee_add_time_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employee_add_time_details` (
  `employee_add_time_id` int(11) NOT NULL,
  `row_index` int(11) NOT NULL DEFAULT 1,
  `before_schedule` tinyint(1) DEFAULT 0,
  `start_datetime` datetime NOT NULL,
  `end_datetime` datetime NOT NULL,
  `total_hours` decimal(10,2) NOT NULL DEFAULT 0.00,
  `reason` text NOT NULL,
  `recorded_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `cancelled_by` int(11) DEFAULT NULL,
  `datetime_recorded` datetime NOT NULL DEFAULT current_timestamp(),
  `datetime_approved` datetime DEFAULT NULL,
  `datetime_disapproved` datetime DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `datetime_verified` datetime DEFAULT NULL,
  `worked_on_break_time` int(11) DEFAULT 0,
  KEY `fk_employee_add_time_details_employee_add_time1_idx` (`employee_add_time_id`),
  KEY `fk_employee_add_time_details_application_users1_idx` (`recorded_by`),
  KEY `fk_employee_add_time_details_application_users2_idx` (`approved_by`),
  KEY `fk_employee_add_time_details_application_users3_idx` (`cancelled_by`),
  CONSTRAINT `fk_employee_add_time_details_application_users1` FOREIGN KEY (`recorded_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_add_time_details_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_add_time_details_application_users3` FOREIGN KEY (`cancelled_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_add_time_details_employee_add_time1` FOREIGN KEY (`employee_add_time_id`) REFERENCES `employee_add_time` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_cessations`
--

DROP TABLE IF EXISTS `employee_cessations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employee_cessations` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL COMMENT 'update tables employees_profile.request_employees_status and employee_profile.employees_status upon effectivity date during payroll generatrion',
  `submission_date` date NOT NULL,
  `effective_date` date DEFAULT NULL,
  `request_id` int(11) NOT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_employee_resignations_request_employee_resignations1_idx` (`request_id`),
  KEY `fk_employee_resignations_employees1_idx` (`employee_id`),
  KEY `fk_employee_cessations_employment_status1_idx` (`status_id`),
  CONSTRAINT `fk_employee_cessations_employment_status1` FOREIGN KEY (`status_id`) REFERENCES `employment_status` (`status_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_resignations_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_resignations_request_employee_resignations1` FOREIGN KEY (`request_id`) REFERENCES `request_employee_cessations` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_rate`
--

DROP TABLE IF EXISTS `employee_rate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employee_rate` (
  `employee_id` int(11) NOT NULL,
  `daily_rate` decimal(7,2) NOT NULL,
  `estimated_monthly_rate` decimal(12,2) NOT NULL,
  `daily_paid` tinyint(4) NOT NULL DEFAULT 1,
  `entitled_overtime` tinyint(4) NOT NULL DEFAULT 1,
  `entitled_holiday` tinyint(4) NOT NULL DEFAULT 1,
  `personal_exemption` decimal(9,2) NOT NULL DEFAULT 0.00,
  `dependents_exemption` decimal(9,2) NOT NULL DEFAULT 0.00,
  `total_exemptions` decimal(12,2) GENERATED ALWAYS AS (`personal_exemption` + `dependents_exemption`) STORED,
  `datetime_requested` datetime NOT NULL,
  `requested_by` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  `date_effective` date DEFAULT NULL,
  KEY `fk_employee_rate_request_employee_rate1_idx` (`request_id`),
  KEY `fk_employee_rate_employees1_idx` (`employee_id`),
  CONSTRAINT `fk_employee_rate_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_rate_request_employee_rate1` FOREIGN KEY (`request_id`) REFERENCES `request_employee_rate` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_responses`
--

DROP TABLE IF EXISTS `employee_responses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employee_responses` (
  `response_entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `violations_entry_id` int(11) NOT NULL,
  `pdf_document` mediumblob NOT NULL,
  `uploaded_by` int(11) NOT NULL,
  `datetime_uploaded` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`response_entry_id`),
  KEY `fk_employee_responses_violations1_idx` (`violations_entry_id`),
  KEY `fk_employee_responses_application_users1_idx` (`uploaded_by`),
  KEY `fk_employee_responses_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_employee_responses_application_users1` FOREIGN KEY (`uploaded_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_responses_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employee_responses_violations1` FOREIGN KEY (`violations_entry_id`) REFERENCES `violations` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employee_types`
--

DROP TABLE IF EXISTS `employee_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employee_types` (
  `type_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(100) NOT NULL,
  PRIMARY KEY (`type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees`
--

DROP TABLE IF EXISTS `employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees` (
  `employee_id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) NOT NULL,
  `birthplace_town` int(11) NOT NULL,
  `current_number_street` char(200) DEFAULT NULL,
  `current_barangay` int(11) NOT NULL,
  `zip_code` char(5) DEFAULT NULL,
  `tax_identification` char(20) DEFAULT NULL,
  `sss_number` char(20) DEFAULT NULL,
  `philhealth_number` char(20) DEFAULT NULL,
  `pag_ibig_number` char(20) DEFAULT NULL,
  `date_hired` date DEFAULT NULL,
  `tenure_in_years` int(11) GENERATED ALWAYS AS (timestampdiff(YEAR,`date_hired`,current_timestamp())) VIRTUAL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`employee_id`),
  KEY `fk_employees_entities_idx` (`entity_id`),
  KEY `fk_employees_towns1_idx` (`birthplace_town`),
  KEY `fk_employees_barangays_districts1_idx` (`current_barangay`),
  KEY `fk_employees_application_users2_idx` (`modified_by`),
  KEY `fk_employees_application_users1_idx` (`created_by`),
  CONSTRAINT `fk_employees_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_barangays_districts1` FOREIGN KEY (`current_barangay`) REFERENCES `entities`.`barangays_districts` (`barangay_district_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_entities` FOREIGN KEY (`entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_towns1` FOREIGN KEY (`birthplace_town`) REFERENCES `entities`.`towns` (`town_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=72 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_jobs`
--

DROP TABLE IF EXISTS `employees_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_jobs` (
  `employee_id` int(11) NOT NULL,
  `job_reference` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `request_id` int(11) NOT NULL,
  KEY `fk_employees_jobs_employees1_idx` (`employee_id`),
  KEY `fk_employees_jobs_job_references1_idx` (`job_reference`),
  KEY `fk_employees_jobs_application_users1_idx` (`created_by`),
  KEY `fk_employees_jobs_request_employees_jobs1_idx` (`request_id`),
  CONSTRAINT `fk_employees_jobs_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_jobs_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_jobs_job_references1` FOREIGN KEY (`job_reference`) REFERENCES `job_references` (`reference_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_jobs_request_employees_jobs1` FOREIGN KEY (`request_id`) REFERENCES `request_employees_jobs` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_leave_credits`
--

DROP TABLE IF EXISTS `employees_leave_credits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_leave_credits` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `leave_id` int(11) NOT NULL,
  `beginning_leave_credits` smallint(6) NOT NULL DEFAULT 0,
  `added_to_leave_credits` smallint(6) NOT NULL DEFAULT 0,
  `deducted_from_leave_credits` smallint(6) NOT NULL DEFAULT 0,
  `remaining_leave_credits` smallint(6) GENERATED ALWAYS AS (`beginning_leave_credits` + `added_to_leave_credits` - `deducted_from_leave_credits`) STORED,
  `leave_credits_request_id` int(11) NOT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_employees_leave_credits_employees1_idx` (`employee_id`),
  KEY `fk_employees_leave_credits_personnel_leaves_definitions1_idx` (`leave_id`),
  KEY `fk_employees_leave_credits_request_employee_leave_credits1_idx` (`leave_credits_request_id`),
  CONSTRAINT `fk_employees_leave_credits_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_leave_credits_personnel_leaves_definitions1` FOREIGN KEY (`leave_id`) REFERENCES `personnel_leaves_definitions` (`leave_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_leave_credits_request_employee_leave_credits1` FOREIGN KEY (`leave_credits_request_id`) REFERENCES `request_employees_leave_credits` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_leaves`
--

DROP TABLE IF EXISTS `employees_leaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_leaves` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `leave_request_id` int(11) NOT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_employees_leaves_request_employees_leaves1_idx` (`leave_request_id`),
  CONSTRAINT `fk_employees_leaves_request_employees_leaves1` FOREIGN KEY (`leave_request_id`) REFERENCES `request_employees_leaves` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_main_department`
--

DROP TABLE IF EXISTS `employees_main_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_main_department` (
  `employee_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `request_id` int(11) NOT NULL,
  KEY `fk_employees_main_department_employees1_idx` (`employee_id`),
  KEY `fk_employees_main_department_main_department1_idx` (`department_id`),
  KEY `fk_employees_main_department_application_users1_idx` (`created_by`),
  KEY `fk_employees_main_department_request_employees_main_departm_idx` (`request_id`),
  CONSTRAINT `fk_employees_main_department_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_main_department_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_main_department_main_department1` FOREIGN KEY (`department_id`) REFERENCES `subscriber_common_tables`.`main_department` (`department_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_main_department_request_employees_main_department1` FOREIGN KEY (`request_id`) REFERENCES `request_employees_main_department` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_schedule_templates`
--

DROP TABLE IF EXISTS `employees_schedule_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_schedule_templates` (
  `template_id` int(11) DEFAULT NULL,
  `employee_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `request_id` int(11) NOT NULL,
  `number_of_punch` int(11) NOT NULL DEFAULT 2,
  KEY `fk_employees_schedule_templates_schedule_templates1_idx` (`template_id`),
  KEY `fk_employees_schedule_templates_employees1_idx` (`employee_id`),
  KEY `fk_employees_schedule_templates_application_users1_idx` (`requested_by`),
  KEY `fk_employees_schedule_templates_request_employees_schedule__idx` (`request_id`),
  CONSTRAINT `fk_employees_schedule_templates_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_schedule_templates_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_schedule_templates_request_employees_schedule_te1` FOREIGN KEY (`request_id`) REFERENCES `request_employees_schedule_templates` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_schedule_templates_schedule_templates1` FOREIGN KEY (`template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_schedule_templates_other_details`
--

DROP TABLE IF EXISTS `employees_schedule_templates_other_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_schedule_templates_other_details` (
  `request_id` int(11) NOT NULL,
  `shift_type_id` int(11) NOT NULL,
  `day_number` int(11) DEFAULT 1,
  `week_sequence` int(11) DEFAULT 0,
  KEY `fk_employee_rest_day_request_employees_schedule_templates1_idx` (`request_id`),
  KEY `fk_employees_schedule_templates_other_details_shift_type1_idx` (`shift_type_id`),
  CONSTRAINT `fk_employee_rest_day_request_employees_schedule_templates1` FOREIGN KEY (`request_id`) REFERENCES `request_employees_schedule_templates` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_schedule_templates_other_details_shift_type1` FOREIGN KEY (`shift_type_id`) REFERENCES `shift_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_status`
--

DROP TABLE IF EXISTS `employees_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_status` (
  `status_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL,
  `request_id` int(11) NOT NULL,
  KEY `fk_employees_status_employment_status1_idx` (`status_id`),
  KEY `fk_employees_status_request_employees_status1_idx` (`request_id`),
  KEY `fk_employees_status_employees1_idx` (`employee_id`),
  CONSTRAINT `fk_employees_status_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_status_employment_status1` FOREIGN KEY (`status_id`) REFERENCES `employment_status` (`status_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_status_request_employees_status1` FOREIGN KEY (`request_id`) REFERENCES `request_employees_status` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_sub_department`
--

DROP TABLE IF EXISTS `employees_sub_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_sub_department` (
  `employee_id` int(11) NOT NULL,
  `sub_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `request_id` int(11) NOT NULL,
  KEY `fk_employees_sub_department_employees1_idx` (`employee_id`),
  KEY `fk_employees_sub_department_sub_deparment1_idx` (`sub_id`),
  KEY `fk_employees_sub_department_application_users1_idx` (`created_by`),
  KEY `fk_employees_sub_department_request_employees_sub_departmen_idx` (`request_id`),
  CONSTRAINT `fk_employees_sub_department_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_sub_department_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_sub_department_request_employees_sub_department1` FOREIGN KEY (`request_id`) REFERENCES `request_employees_sub_department` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_sub_department_sub_deparment1` FOREIGN KEY (`sub_id`) REFERENCES `subscriber_common_tables`.`sub_deparment` (`sub_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_units`
--

DROP TABLE IF EXISTS `employees_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_units` (
  `employee_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `request_id` int(11) NOT NULL,
  KEY `fk_employees_units_employees1_idx` (`employee_id`),
  KEY `fk_employees_units_units1_idx` (`unit_id`),
  KEY `fk_employees_units_application_users1_idx` (`requested_by`),
  KEY `fk_employees_units_request_employee_units1_idx` (`request_id`),
  CONSTRAINT `fk_employees_units_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_units_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_units_request_employee_units1` FOREIGN KEY (`request_id`) REFERENCES `request_employee_units` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_units_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employees_violations`
--

DROP TABLE IF EXISTS `employees_violations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employees_violations` (
  `employee_id` int(11) NOT NULL,
  `entry_id` int(11) NOT NULL,
  KEY `fk_employees_violations_employees1_idx` (`employee_id`),
  KEY `fk_employees_violations_violations1_idx` (`entry_id`),
  CONSTRAINT `fk_employees_violations_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employees_violations_violations1` FOREIGN KEY (`entry_id`) REFERENCES `violations` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employers`
--

DROP TABLE IF EXISTS `employers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employers` (
  `employer_id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) NOT NULL,
  `industry_id` int(11) NOT NULL,
  PRIMARY KEY (`employer_id`),
  KEY `fk_employers_industries1_idx` (`industry_id`),
  KEY `fk_employers_entities1_idx` (`entity_id`),
  CONSTRAINT `fk_employers_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employers_industries1` FOREIGN KEY (`industry_id`) REFERENCES `industries` (`industry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employment_history`
--

DROP TABLE IF EXISTS `employment_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employment_history` (
  `employee_id` int(11) NOT NULL,
  `employer_id` int(11) NOT NULL,
  `position_id` int(11) DEFAULT NULL,
  `period_from` date NOT NULL,
  `period_to` date DEFAULT NULL,
  `position_description` varchar(100) DEFAULT NULL,
  KEY `fk_employment_history_employees1_idx` (`employee_id`),
  KEY `fk_employment_history_employers1_idx` (`employer_id`),
  KEY `fk_employment_history_employment_positions1_idx` (`position_id`),
  CONSTRAINT `fk_employment_history_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employment_history_employers1` FOREIGN KEY (`employer_id`) REFERENCES `employers` (`employer_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_employment_history_employment_positions1` FOREIGN KEY (`position_id`) REFERENCES `employment_positions` (`position_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employment_positions`
--

DROP TABLE IF EXISTS `employment_positions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employment_positions` (
  `position_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(80) NOT NULL,
  PRIMARY KEY (`position_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `employment_status`
--

DROP TABLE IF EXISTS `employment_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `employment_status` (
  `status_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(100) DEFAULT NULL,
  `cessation_status` tinyint(4) NOT NULL DEFAULT 0,
  `with_effective_date` tinyint(4) NOT NULL DEFAULT 1,
  PRIMARY KEY (`status_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `for_dtr_uploading`
--

DROP TABLE IF EXISTS `for_dtr_uploading`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `for_dtr_uploading` (
  `employee_id` int(11) NOT NULL,
  `payroll_id` int(11) NOT NULL,
  `payroll_period_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  KEY `fk_for_dtr_uploading_employees1_idx` (`employee_id`),
  KEY `fk_for_dtr_uploading_payroll_main1_idx` (`payroll_id`),
  KEY `fk_for_dtr_uploading_payroll_period1_idx` (`payroll_period_id`),
  KEY `fk_for_dtr_uploading_units1_idx` (`unit_id`),
  CONSTRAINT `fk_for_dtr_uploading_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_for_dtr_uploading_payroll_main1` FOREIGN KEY (`payroll_id`) REFERENCES `payroll`.`payroll_main` (`payroll_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_for_dtr_uploading_payroll_period1` FOREIGN KEY (`payroll_period_id`) REFERENCES `payroll`.`payroll_period` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_for_dtr_uploading_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_entity`
--

DROP TABLE IF EXISTS `group_entity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_entity` (
  `groupings_group_id` int(11) NOT NULL,
  KEY `fk_group_entity_groupings1_idx` (`groupings_group_id`),
  CONSTRAINT `fk_group_entity_groupings1` FOREIGN KEY (`groupings_group_id`) REFERENCES `entities`.`groupings` (`group_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_schedule_template`
--

DROP TABLE IF EXISTS `group_schedule_template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_schedule_template` (
  `grp_sched_template_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(120) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  PRIMARY KEY (`grp_sched_template_id`),
  KEY `fk_group_schedule_template_application_users1_idx` (`created_by`),
  KEY `fk_group_schedule_template_units1_idx` (`unit_id`),
  CONSTRAINT `fk_group_schedule_template_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_group_schedule_template_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_schedule_template_details`
--

DROP TABLE IF EXISTS `group_schedule_template_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_schedule_template_details` (
  `grp_sched_template_id` int(11) NOT NULL,
  `template_id` int(11) NOT NULL,
  KEY `fk_group_schedule_template_details_group_schedule_template1_idx` (`grp_sched_template_id`),
  KEY `fk_group_schedule_template_details_schedule_template_days1_idx` (`template_id`),
  CONSTRAINT `fk_group_schedule_template_details_group_schedule_template1` FOREIGN KEY (`grp_sched_template_id`) REFERENCES `group_schedule_template` (`grp_sched_template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_group_schedule_template_details_schedule_template_days1` FOREIGN KEY (`template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_schedule_templates`
--

DROP TABLE IF EXISTS `group_schedule_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_schedule_templates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) DEFAULT NULL,
  `shift_type_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_group_schedule_templates_shift_type1_idx` (`shift_type_id`),
  CONSTRAINT `fk_group_schedule_templates_shift_type1` FOREIGN KEY (`shift_type_id`) REFERENCES `shift_type` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_schedule_templates_details`
--

DROP TABLE IF EXISTS `group_schedule_templates_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_schedule_templates_details` (
  `group_template_id` int(11) NOT NULL,
  `schedule_template_id` int(11) NOT NULL,
  `order_index` int(11) NOT NULL,
  KEY `fk_group_schedule_templates_details_group_schedule_template_idx` (`group_template_id`),
  KEY `fk_group_schedule_templates_details_schedule_templates1_idx` (`schedule_template_id`),
  CONSTRAINT `fk_group_schedule_templates_details_group_schedule_templates1` FOREIGN KEY (`group_template_id`) REFERENCES `group_schedule_templates` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_group_schedule_templates_details_schedule_templates1` FOREIGN KEY (`schedule_template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_schedule_templates_temporary_details`
--

DROP TABLE IF EXISTS `group_schedule_templates_temporary_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_schedule_templates_temporary_details` (
  `group_template_id` int(11) NOT NULL,
  `schedule_template_id` int(11) NOT NULL,
  `rest_day_JSON` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin NOT NULL CHECK (json_valid(`rest_day_JSON`)),
  `year` int(11) NOT NULL,
  `month` int(11) NOT NULL,
  `week_of_the_month` int(11) NOT NULL,
  KEY `fk_group_schedule_templates_temporary_details_group_schedul_idx` (`group_template_id`),
  KEY `fk_group_schedule_templates_temporary_details_schedule_temp_idx` (`schedule_template_id`),
  CONSTRAINT `fk_group_schedule_templates_temporary_details_group_schedule_1` FOREIGN KEY (`group_template_id`) REFERENCES `group_schedule_templates` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_group_schedule_templates_temporary_details_schedule_templa1` FOREIGN KEY (`schedule_template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `group_user_access`
--

DROP TABLE IF EXISTS `group_user_access`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `group_user_access` (
  `user_id` int(11) NOT NULL,
  `grp_sched_template_id` int(11) NOT NULL,
  KEY `fk_group_user_access_application_users1_idx` (`user_id`),
  KEY `fk_group_user_access_group_schedule_template1_idx` (`grp_sched_template_id`),
  CONSTRAINT `fk_group_user_access_application_users1` FOREIGN KEY (`user_id`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_group_user_access_group_schedule_template1` FOREIGN KEY (`grp_sched_template_id`) REFERENCES `group_schedule_template` (`grp_sched_template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `hris_parms`
--

DROP TABLE IF EXISTS `hris_parms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `hris_parms` (
  `number_of_violations_for_automatic_cessation_request` int(11) NOT NULL DEFAULT 3,
  `default_policy_vioated_for_cessation` int(11) NOT NULL,
  KEY `fk_hris_parms_section_items1_idx` (`default_policy_vioated_for_cessation`),
  CONSTRAINT `fk_hris_parms_section_items1` FOREIGN KEY (`default_policy_vioated_for_cessation`) REFERENCES `section_items` (`section_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `industries`
--

DROP TABLE IF EXISTS `industries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `industries` (
  `industry_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(80) NOT NULL,
  PRIMARY KEY (`industry_id`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_references`
--

DROP TABLE IF EXISTS `job_references`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_references` (
  `reference_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(100) NOT NULL,
  `type_id` int(11) NOT NULL,
  `education_id` int(11) NOT NULL,
  `qualifications` tinyblob DEFAULT NULL,
  `work_experiences` tinyblob DEFAULT NULL,
  `duties_and_responsibilities` tinyblob DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime DEFAULT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`reference_id`),
  KEY `fk_job_references_application_users1_idx` (`created_by`),
  KEY `fk_job_references_application_users2_idx` (`modified_by`),
  KEY `fk_job_references_employee_types1_idx` (`type_id`),
  KEY `fk_job_references_educational_level1_idx` (`education_id`),
  CONSTRAINT `fk_job_references_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_job_references_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_job_references_educational_level1` FOREIGN KEY (`education_id`) REFERENCES `educational_level` (`education_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_job_references_employee_types1` FOREIGN KEY (`type_id`) REFERENCES `employee_types` (`type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `jobs_scales`
--

DROP TABLE IF EXISTS `jobs_scales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs_scales` (
  `job_id` int(11) NOT NULL,
  `scale_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `request_id` int(11) NOT NULL,
  KEY `fk_jobs_scales_job_references1_idx` (`job_id`),
  KEY `fk_jobs_scales_pay_scales1_idx` (`scale_id`),
  KEY `fk_jobs_scales_application_users1_idx` (`created_by`),
  KEY `fk_jobs_scales_request_jobs_scales1_idx` (`request_id`),
  CONSTRAINT `fk_jobs_scales_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_jobs_scales_job_references1` FOREIGN KEY (`job_id`) REFERENCES `job_references` (`reference_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_jobs_scales_pay_scales1` FOREIGN KEY (`scale_id`) REFERENCES `pay_scales` (`scale_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_jobs_scales_request_jobs_scales1` FOREIGN KEY (`request_id`) REFERENCES `request_jobs_scales` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `leave_credits_adjustments`
--

DROP TABLE IF EXISTS `leave_credits_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `leave_credits_adjustments` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `request_id` int(11) NOT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_leave_credits_adjustments_request_leave_credits_adjustme_idx` (`request_id`),
  CONSTRAINT `fk_leave_credits_adjustments_request_leave_credits_adjustments1` FOREIGN KEY (`request_id`) REFERENCES `request_leave_credits_adjustments` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lsof_employee_scheduler`
--

DROP TABLE IF EXISTS `lsof_employee_scheduler`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lsof_employee_scheduler` (
  `lsof_id` int(11) NOT NULL AUTO_INCREMENT,
  `approved` tinyint(4) DEFAULT NULL,
  `unit_id` int(11) NOT NULL,
  `template_id` int(11) NOT NULL,
  PRIMARY KEY (`lsof_id`),
  KEY `fk_lsof_employee_scheduler_units1_idx` (`unit_id`),
  KEY `fk_lsof_employee_scheduler_schedule_templates1_idx` (`template_id`),
  CONSTRAINT `fk_lsof_employee_scheduler_schedule_templates1` FOREIGN KEY (`template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_lsof_employee_scheduler_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `lsof_employee_scheduler_details`
--

DROP TABLE IF EXISTS `lsof_employee_scheduler_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `lsof_employee_scheduler_details` (
  `request_id` int(11) NOT NULL COMMENT 'parent id from request_employeees_schedule_templates',
  `lsof_id` int(11) NOT NULL,
  KEY `fk_table1_lsof_employee_scheduler1_idx` (`lsof_id`),
  CONSTRAINT `fk_table1_lsof_employee_scheduler1` FOREIGN KEY (`lsof_id`) REFERENCES `lsof_employee_scheduler` (`lsof_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `main_policy_items`
--

DROP TABLE IF EXISTS `main_policy_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `main_policy_items` (
  `main_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `brief_description` char(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`main_item_id`),
  KEY `fk_main_policy_items_application_users1_idx` (`created_by`),
  KEY `fk_main_policy_items_application_users2_idx` (`modified_by`),
  KEY `fk_main_policy_items_policies_templates1_idx` (`template_id`),
  CONSTRAINT `fk_main_policy_items_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_main_policy_items_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_main_policy_items_policies_templates1` FOREIGN KEY (`template_id`) REFERENCES `policies_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=83 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `occupations`
--

DROP TABLE IF EXISTS `occupations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `occupations` (
  `occupation_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(80) NOT NULL,
  PRIMARY KEY (`occupation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `parents`
--

DROP TABLE IF EXISTS `parents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `parents` (
  `entity_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `relation_id` int(11) NOT NULL,
  `occupation_id` int(11) DEFAULT NULL,
  KEY `fk_parents_entities1_idx` (`entity_id`),
  KEY `fk_parents_employees1_idx` (`employee_id`),
  KEY `fk_parents_relations1_idx` (`relation_id`),
  KEY `fk_parents_occupations1_idx` (`occupation_id`),
  CONSTRAINT `fk_parents_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_parents_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_parents_occupations1` FOREIGN KEY (`occupation_id`) REFERENCES `occupations` (`occupation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_parents_relations1` FOREIGN KEY (`relation_id`) REFERENCES `relations` (`relation_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pay_scales`
--

DROP TABLE IF EXISTS `pay_scales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pay_scales` (
  `scale_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(100) NOT NULL,
  `min_daily_rate` decimal(12,2) NOT NULL DEFAULT 1.00,
  `max_daily_rate` decimal(12,2) NOT NULL DEFAULT 1.00,
  `min_hour_rate` decimal(12,2) GENERATED ALWAYS AS (`min_daily_rate` / 8.00) STORED,
  `max_hour_rate` decimal(12,2) GENERATED ALWAYS AS (`max_daily_rate` / 8.00) STORED,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`scale_id`),
  KEY `fk_pay_bands_application_users1_idx` (`created_by`),
  KEY `fk_pay_bands_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_pay_bands_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_pay_bands_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `personnel_leaves_definitions`
--

DROP TABLE IF EXISTS `personnel_leaves_definitions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personnel_leaves_definitions` (
  `leave_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(60) NOT NULL,
  `govt_mandated` tinyint(4) NOT NULL DEFAULT 0,
  `with_pay` tinyint(4) NOT NULL DEFAULT 0,
  `min_number_of_hours` int(11) NOT NULL DEFAULT 1,
  `max_number_of_hours` int(11) NOT NULL DEFAULT 1,
  `employment_status_id` int(11) DEFAULT NULL,
  `request_days_before` tinyint(4) NOT NULL,
  `tenure_in_months` tinyint(4) NOT NULL DEFAULT 0,
  `can_be_monetized` tinyint(4) NOT NULL DEFAULT 0,
  `employee_type_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`leave_id`),
  KEY `fk_personnel_leaves_definitions_application_users1_idx` (`created_by`),
  KEY `fk_personnel_leaves_definitions_application_users2_idx` (`modified_by`),
  KEY `fk_personnel_leaves_definitions_employment_status1_idx` (`employment_status_id`),
  KEY `fk_personnel_leaves_definitions_employee_types1_idx` (`employee_type_id`),
  CONSTRAINT `fk_personnel_leaves_definitions_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_personnel_leaves_definitions_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_personnel_leaves_definitions_employee_types1` FOREIGN KEY (`employee_type_id`) REFERENCES `employee_types` (`type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_personnel_leaves_definitions_employment_status1` FOREIGN KEY (`employment_status_id`) REFERENCES `employment_status` (`status_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policies_templates`
--

DROP TABLE IF EXISTS `policies_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policies_templates` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT,
  `description_version` varchar(100) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  PRIMARY KEY (`template_id`),
  KEY `fk_policies_templates_application_users1_idx` (`created_by`),
  KEY `fk_policies_templates_application_users2_idx` (`modified_by`),
  KEY `fk_policies_templates_application_users3_idx` (`approved_by`),
  CONSTRAINT `fk_policies_templates_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_policies_templates_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_policies_templates_application_users3` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `policy_sections_violated`
--

DROP TABLE IF EXISTS `policy_sections_violated`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `policy_sections_violated` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `section_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_policies_violated_section_items1_idx` (`section_id`),
  KEY `fk_policy_sections_violated_request_violations1_idx` (`request_id`),
  CONSTRAINT `fk_policies_violated_section_items1` FOREIGN KEY (`section_id`) REFERENCES `section_items` (`section_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_policy_sections_violated_request_violations1` FOREIGN KEY (`request_id`) REFERENCES `request_violations` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recurring_time_schedule`
--

DROP TABLE IF EXISTS `recurring_time_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `recurring_time_schedule` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_recurring_time_schedule_schedule_templates1_idx` (`template_id`),
  CONSTRAINT `fk_recurring_time_schedule_schedule_templates1` FOREIGN KEY (`template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `relations`
--

DROP TABLE IF EXISTS `relations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `relations` (
  `relation_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) NOT NULL,
  PRIMARY KEY (`relation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employee_cessations`
--

DROP TABLE IF EXISTS `request_employee_cessations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employee_cessations` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `submission_date` date NOT NULL,
  `effective_date` date DEFAULT NULL COMMENT 'only fill-up when emplyment_status.with_effective_date is set to 1',
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_request_employee_resignations_employees1_idx` (`employee_id`),
  KEY `fk_request_employee_resignations_application_users1_idx` (`requested_by`),
  KEY `fk_request_employee_resignations_application_users2_idx` (`approved_by`),
  KEY `fk_request_employee_cessations_employment_status1_idx` (`status_id`),
  KEY `fk_request_employee_cessations_section_items1_idx` (`section_id`),
  CONSTRAINT `fk_request_employee_cessations_employment_status1` FOREIGN KEY (`status_id`) REFERENCES `employment_status` (`status_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_cessations_section_items1` FOREIGN KEY (`section_id`) REFERENCES `section_items` (`section_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_resignations_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_resignations_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_resignations_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employee_rate`
--

DROP TABLE IF EXISTS `request_employee_rate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employee_rate` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `daily_rate` decimal(7,2) NOT NULL,
  `estimated_monthly_rate` decimal(12,2) NOT NULL,
  `daily_paid` tinyint(4) NOT NULL DEFAULT 1,
  `entitled_overtime` tinyint(4) NOT NULL DEFAULT 1,
  `entitled_holiday` tinyint(4) NOT NULL DEFAULT 1,
  `personal_exemption` decimal(9,2) NOT NULL DEFAULT 0.00,
  `dependents_exemption` decimal(9,2) NOT NULL DEFAULT 0.00,
  `total_exemptions` decimal(12,2) GENERATED ALWAYS AS (`personal_exemption` + `dependents_exemption`) STORED,
  `datetime_requested` datetime NOT NULL,
  `requested_by` int(11) NOT NULL,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  `date_effective` date DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employee_rate_employees1_idx` (`employee_id`),
  KEY `fk_request_employee_rate_application_users1_idx` (`requested_by`),
  KEY `fk_request_employee_rate_application_users2_idx` (`approved_by`),
  CONSTRAINT `fk_request_employee_rate_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_rate_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_rate_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=104 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employee_units`
--

DROP TABLE IF EXISTS `request_employee_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employee_units` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employee_units_employees1_idx` (`employee_id`),
  KEY `fk_request_employee_units_units1_idx` (`unit_id`),
  KEY `fk_request_employee_units_application_users1_idx` (`requested_by`),
  KEY `fk_request_employee_units_application_users2_idx` (`approved_by`),
  CONSTRAINT `fk_request_employee_units_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_units_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_units_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_units_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employees_jobs`
--

DROP TABLE IF EXISTS `request_employees_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employees_jobs` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `job_reference` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` varchar(45) NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employees_jobs_job_references1_idx` (`job_reference`),
  KEY `fk_request_employees_jobs_employees1_idx` (`employee_id`),
  KEY `fk_request_employees_jobs_application_users1_idx` (`requested_by`),
  KEY `fk_request_employees_jobs_application_users2_idx` (`approved_by`),
  CONSTRAINT `fk_request_employees_jobs_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_jobs_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_jobs_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_jobs_job_references1` FOREIGN KEY (`job_reference`) REFERENCES `job_references` (`reference_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employees_leave_credits`
--

DROP TABLE IF EXISTS `request_employees_leave_credits`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employees_leave_credits` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `leave_id` int(11) NOT NULL,
  `leave_credits_in_hours` tinyint(4) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL DEFAULT current_timestamp(),
  `datetime_modified` datetime DEFAULT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  `cancelled` tinyint(4) NOT NULL DEFAULT 0,
  `cancelled_by` int(11) DEFAULT NULL,
  `datetime_cancelled` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employee_leave_credits_employees1_idx` (`employee_id`),
  KEY `fk_request_employee_leave_credits_personnel_leaves_definiti_idx` (`leave_id`),
  KEY `fk_request_employee_leave_credits_application_users1_idx` (`requested_by`),
  KEY `fk_request_employee_leave_credits_application_users2_idx` (`approved_by`),
  KEY `fk_request_employee_leave_credits_application_users3_idx` (`cancelled_by`),
  CONSTRAINT `fk_request_employee_leave_credits_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_leave_credits_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_leave_credits_application_users3` FOREIGN KEY (`cancelled_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_leave_credits_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employee_leave_credits_personnel_leaves_definitions1` FOREIGN KEY (`leave_id`) REFERENCES `personnel_leaves_definitions` (`leave_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employees_leaves`
--

DROP TABLE IF EXISTS `request_employees_leaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employees_leaves` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `leave_credits_entry_id` int(11) NOT NULL,
  `starting_date_applied` date NOT NULL,
  `number_of_hours` int(11) NOT NULL,
  `ending_date` date GENERATED ALWAYS AS (`starting_date_applied` + interval `number_of_hours` DIV 8 + if(`number_of_hours` MOD 8 > 0,1,0) day) VIRTUAL,
  `remarks` text NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL DEFAULT current_timestamp(),
  `datetime_modified` datetime DEFAULT NULL,
  `cancelled` tinyint(4) NOT NULL DEFAULT 0,
  `datetime_cancelled` datetime DEFAULT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `disapproved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_disapproved_by` int(11) DEFAULT NULL,
  `datetime_approved_disapproved` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employees_leaves_employees_leave_credits1_idx` (`leave_credits_entry_id`),
  KEY `fk_request_employees_leaves_application_users1_idx` (`requested_by`),
  KEY `fk_request_employees_leaves_application_users2_idx` (`approved_disapproved_by`),
  CONSTRAINT `fk_request_employees_leaves_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_leaves_application_users2` FOREIGN KEY (`approved_disapproved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_leaves_employees_leave_credits1` FOREIGN KEY (`leave_credits_entry_id`) REFERENCES `employees_leave_credits` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employees_main_department`
--

DROP TABLE IF EXISTS `request_employees_main_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employees_main_department` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `department_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employees_main_department_employees1_idx` (`employee_id`),
  KEY `fk_request_employees_main_department_application_users1_idx` (`requested_by`),
  KEY `fk_request_employees_main_department_application_users2_idx` (`approved_by`),
  KEY `fk_request_employees_main_department_main_department1_idx` (`department_id`),
  CONSTRAINT `fk_request_employees_main_department_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_main_department_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_main_department_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_main_department_main_department1` FOREIGN KEY (`department_id`) REFERENCES `subscriber_common_tables`.`main_department` (`department_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employees_schedule_templates`
--

DROP TABLE IF EXISTS `request_employees_schedule_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employees_schedule_templates` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) DEFAULT NULL,
  `employee_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  `date_effective` date DEFAULT NULL,
  `number_of_punch` int(11) NOT NULL DEFAULT 2,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employees_schedule_templates_application_users1_idx` (`approved_by`),
  CONSTRAINT `fk_request_employees_schedule_templates_application_users1` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employees_status`
--

DROP TABLE IF EXISTS `request_employees_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employees_status` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `employee_id` int(11) NOT NULL,
  `status_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employees_status_application_users1_idx` (`requested_by`),
  KEY `fk_request_employees_status_application_users2_idx` (`approved_by`),
  KEY `fk_request_employees_status_employees1_idx` (`employee_id`),
  KEY `fk_request_employees_status_employment_status1_idx` (`status_id`),
  CONSTRAINT `fk_request_employees_status_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_status_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_status_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_status_employment_status1` FOREIGN KEY (`status_id`) REFERENCES `employment_status` (`status_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=85 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employees_sub_department`
--

DROP TABLE IF EXISTS `request_employees_sub_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employees_sub_department` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `sub_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_request` datetime NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_employees_sub_department_employees1_idx` (`employee_id`),
  KEY `fk_request_employees_sub_department_application_users1_idx` (`requested_by`),
  KEY `fk_request_employees_sub_department_application_users2_idx` (`approved_by`),
  KEY `fk_request_employees_sub_department_sub_deparment1_idx` (`sub_id`),
  CONSTRAINT `fk_request_employees_sub_department_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_sub_department_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_sub_department_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_sub_department_sub_deparment1` FOREIGN KEY (`sub_id`) REFERENCES `subscriber_common_tables`.`sub_deparment` (`sub_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_employees_violations`
--

DROP TABLE IF EXISTS `request_employees_violations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_employees_violations` (
  `employee_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  KEY `fk_request_employees_violations_employees1_idx` (`employee_id`),
  KEY `fk_request_employees_violations_request_violations1_idx` (`request_id`),
  CONSTRAINT `fk_request_employees_violations_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_employees_violations_request_violations1` FOREIGN KEY (`request_id`) REFERENCES `request_violations` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_jobs_scales`
--

DROP TABLE IF EXISTS `request_jobs_scales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_jobs_scales` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `job_id` int(11) NOT NULL,
  `scaled_id` int(11) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_jobs_scales_job_references1_idx` (`job_id`),
  KEY `fk_request_jobs_scales_pay_scales1_idx` (`scaled_id`),
  KEY `fk_request_jobs_scales_application_users1_idx` (`requested_by`),
  KEY `fk_request_jobs_scales_application_users2_idx` (`approved_by`),
  CONSTRAINT `fk_request_jobs_scales_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_jobs_scales_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_jobs_scales_job_references1` FOREIGN KEY (`job_id`) REFERENCES `job_references` (`reference_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_jobs_scales_pay_scales1` FOREIGN KEY (`scaled_id`) REFERENCES `pay_scales` (`scale_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_leave_credits_adjustments`
--

DROP TABLE IF EXISTS `request_leave_credits_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_leave_credits_adjustments` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `leave_credits_entry_id` int(11) NOT NULL,
  `number_of_hours` tinyint(4) NOT NULL DEFAULT 1,
  `add_to_credits` tinyint(4) NOT NULL DEFAULT 0,
  `remarks` text NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL DEFAULT current_timestamp(),
  `cancelled` tinyint(4) NOT NULL DEFAULT 0,
  `datetime_cancelled` datetime DEFAULT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_leave_credits_adjustments_employees_leave_credit_idx` (`leave_credits_entry_id`),
  KEY `fk_request_leave_credits_adjustments_application_users1_idx` (`requested_by`),
  KEY `fk_request_leave_credits_adjustments_application_users2_idx` (`approved_by`),
  CONSTRAINT `fk_request_leave_credits_adjustments_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_leave_credits_adjustments_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_leave_credits_adjustments_employees_leave_credits1` FOREIGN KEY (`leave_credits_entry_id`) REFERENCES `employees_leave_credits` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_violations`
--

DROP TABLE IF EXISTS `request_violations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_violations` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `incident` text NOT NULL,
  `date_of_incident` datetime NOT NULL,
  `incident_why` text NOT NULL,
  `actions_taken` text NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `approved` tinyint(4) NOT NULL DEFAULT 0,
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  `days_duration` int(11) NOT NULL,
  `automatic_clear_date` datetime GENERATED ALWAYS AS (`date_of_incident` + interval `days_duration` day) STORED,
  PRIMARY KEY (`request_id`),
  KEY `fk_request_violations_application_users1_idx` (`approved_by`),
  CONSTRAINT `fk_request_violations_application_users1` FOREIGN KEY (`approved_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sample`
--

DROP TABLE IF EXISTS `sample`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sample` (
  `id` int(11) DEFAULT NULL,
  `numbers` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`numbers`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schedule_template_days`
--

DROP TABLE IF EXISTS `schedule_template_days`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schedule_template_days` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `template_id` int(11) NOT NULL,
  `day_number` tinyint(4) NOT NULL,
  `time_in` time DEFAULT NULL,
  `time_out` time DEFAULT NULL,
  `entry_date` datetime NOT NULL,
  `week_sequence` int(11) DEFAULT 0,
  PRIMARY KEY (`entry_id`),
  KEY `fk_table1_schedule_templates1_idx` (`template_id`),
  CONSTRAINT `fk_table1_schedule_templates1` FOREIGN KEY (`template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=291 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schedule_templates`
--

DROP TABLE IF EXISTS `schedule_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schedule_templates` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(100) NOT NULL,
  `break_allowance` tinyint(4) NOT NULL,
  `minimum_minutes_required_rendered_overtime` tinyint(4) NOT NULL,
  `shift_type_id` int(11) DEFAULT NULL,
  `open_time` tinyint(4) DEFAULT 0 COMMENT 'only for flexible/work from home',
  PRIMARY KEY (`template_id`),
  KEY `schedule_templates_shift_type_FK` (`shift_type_id`),
  CONSTRAINT `schedule_templates_shift_type_FK` FOREIGN KEY (`shift_type_id`) REFERENCES `shift_type` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=58 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `schools`
--

DROP TABLE IF EXISTS `schools`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `schools` (
  `school_id` int(11) NOT NULL AUTO_INCREMENT,
  `school_name` char(100) NOT NULL,
  PRIMARY KEY (`school_id`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `section_items`
--

DROP TABLE IF EXISTS `section_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `section_items` (
  `section_id` int(11) NOT NULL AUTO_INCREMENT,
  `sub_item_id` int(11) NOT NULL,
  `brief_description` char(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`section_id`),
  KEY `fk_section_items_sub_policy_items1_idx` (`sub_item_id`),
  KEY `fk_section_items_application_users1_idx` (`created_by`),
  KEY `fk_section_items_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_section_items_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_section_items_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_section_items_sub_policy_items1` FOREIGN KEY (`sub_item_id`) REFERENCES `sub_policy_items` (`sub_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=1832 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `shift_type`
--

DROP TABLE IF EXISTS `shift_type`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `shift_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(99) NOT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sub_policy_items`
--

DROP TABLE IF EXISTS `sub_policy_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sub_policy_items` (
  `sub_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `main_item_id` int(11) NOT NULL,
  `brief_description` char(100) NOT NULL,
  `description` text DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`sub_item_id`),
  KEY `fk_sub_policy_items_main_policy_items1_idx` (`main_item_id`),
  KEY `fk_sub_policy_items_application_users1_idx` (`created_by`),
  KEY `fk_sub_policy_items_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_sub_policy_items_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sub_policy_items_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sub_policy_items_main_policy_items1` FOREIGN KEY (`main_item_id`) REFERENCES `main_policy_items` (`main_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=261 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unit_app_user_details`
--

DROP TABLE IF EXISTS `unit_app_user_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unit_app_user_details` (
  `unit_shift_id` int(11) NOT NULL,
  `application_users_user_id` int(11) NOT NULL,
  KEY `fk_unit_app_user_details_unit_shift1_idx` (`unit_shift_id`),
  KEY `fk_unit_app_user_details_application_users1_idx` (`application_users_user_id`),
  CONSTRAINT `fk_unit_app_user_details_application_users1` FOREIGN KEY (`application_users_user_id`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_unit_app_user_details_unit_shift1` FOREIGN KEY (`unit_shift_id`) REFERENCES `unit_shift` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unit_schedule_template_details`
--

DROP TABLE IF EXISTS `unit_schedule_template_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unit_schedule_template_details` (
  `unit_shift_id` int(11) NOT NULL,
  `template_id` int(11) NOT NULL,
  KEY `fk_unit_schedule_template_details_unit_shift1_idx` (`unit_shift_id`),
  KEY `fk_unit_schedule_template_details_schedule_templates1_idx` (`template_id`),
  CONSTRAINT `fk_unit_schedule_template_details_schedule_templates1` FOREIGN KEY (`template_id`) REFERENCES `schedule_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_unit_schedule_template_details_unit_shift1` FOREIGN KEY (`unit_shift_id`) REFERENCES `unit_shift` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unit_shift`
--

DROP TABLE IF EXISTS `unit_shift`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unit_shift` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `unit_id` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `fk_unit_shift_units1_idx` (`unit_id`),
  CONSTRAINT `fk_unit_shift_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `violations`
--

DROP TABLE IF EXISTS `violations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `violations` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `incident` text NOT NULL,
  `date_of_incident` datetime NOT NULL,
  `incident_why` text NOT NULL,
  `actions_taken` text NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `request_id` int(11) NOT NULL,
  `cleared` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`entry_id`),
  KEY `fk_employee_violations_application_users1_idx` (`created_by`),
  KEY `fk_violations_request_violations1_idx` (`request_id`),
  CONSTRAINT `fk_employee_violations_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_violations_request_violations1` FOREIGN KEY (`request_id`) REFERENCES `request_violations` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: employees_profile_udf_and_views
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `employees_profile_udf_and_views`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `employees_profile_udf_and_views` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `employees_profile_udf_and_views`;

--
-- Temporary table structure for view `employee_beneficiary_details`
--

DROP TABLE IF EXISTS `employee_beneficiary_details`;
/*!50001 DROP VIEW IF EXISTS `employee_beneficiary_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_beneficiary_details` AS SELECT
 1 AS `employee_id`,
  1 AS `beneficiary_details` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_dependents_details`
--

DROP TABLE IF EXISTS `employee_dependents_details`;
/*!50001 DROP VIEW IF EXISTS `employee_dependents_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_dependents_details` AS SELECT
 1 AS `employee_id`,
  1 AS `dependents_details` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_education_details`
--

DROP TABLE IF EXISTS `employee_education_details`;
/*!50001 DROP VIEW IF EXISTS `employee_education_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_education_details` AS SELECT
 1 AS `employee_id`,
  1 AS `education_details` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_emergency_contact_details`
--

DROP TABLE IF EXISTS `employee_emergency_contact_details`;
/*!50001 DROP VIEW IF EXISTS `employee_emergency_contact_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_emergency_contact_details` AS SELECT
 1 AS `employee_id`,
  1 AS `emergency_contact_details` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_employment_history`
--

DROP TABLE IF EXISTS `employee_employment_history`;
/*!50001 DROP VIEW IF EXISTS `employee_employment_history`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_employment_history` AS SELECT
 1 AS `employee_id`,
  1 AS `employment_history` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_info`
--

DROP TABLE IF EXISTS `employee_info`;
/*!50001 DROP VIEW IF EXISTS `employee_info`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_info` AS SELECT
 1 AS `employee_name`,
  1 AS `employee_number`,
  1 AS `date_hired`,
  1 AS `tenure_in_years`,
  1 AS `employee_type_id`,
  1 AS `employee_type`,
  1 AS `employee_id`,
  1 AS `daily_rate`,
  1 AS `estimated_monthly_rate`,
  1 AS `daily_paid`,
  1 AS `entitled_overtime`,
  1 AS `entitled_holiday`,
  1 AS `personal_exemption`,
  1 AS `dependents_exemption`,
  1 AS `total_exemptions`,
  1 AS `schedule_template_id`,
  1 AS `unit_id`,
  1 AS `unit_description`,
  1 AS `department_id`,
  1 AS `department_description`,
  1 AS `sub_id`,
  1 AS `sub_department_description`,
  1 AS `current_employee`,
  1 AS `sss_number`,
  1 AS `philhealth_number`,
  1 AS `pag_ibig_number`,
  1 AS `number_of_punch` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_main_department_choices`
--

DROP TABLE IF EXISTS `employee_main_department_choices`;
/*!50001 DROP VIEW IF EXISTS `employee_main_department_choices`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_main_department_choices` AS SELECT
 1 AS `employee_id`,
  1 AS `unit_id`,
  1 AS `department_id`,
  1 AS `main_department` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_name`
--

DROP TABLE IF EXISTS `employee_name`;
/*!50001 DROP VIEW IF EXISTS `employee_name`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_name` AS SELECT
 1 AS `employee_id`,
  1 AS `entity_id`,
  1 AS `current_employee`,
  1 AS `customer_id`,
  1 AS `frmt_employee_id`,
  1 AS `employee_name`,
  1 AS `frmt_employee_name` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_parent_details`
--

DROP TABLE IF EXISTS `employee_parent_details`;
/*!50001 DROP VIEW IF EXISTS `employee_parent_details`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_parent_details` AS SELECT
 1 AS `employee_id`,
  1 AS `parent_details` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `employee_sub_department_choices`
--

DROP TABLE IF EXISTS `employee_sub_department_choices`;
/*!50001 DROP VIEW IF EXISTS `employee_sub_department_choices`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `employee_sub_department_choices` AS SELECT
 1 AS `employee_id`,
  1 AS `department_id`,
  1 AS `sub_id`,
  1 AS `sub_department` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `latest_employee_schedule`
--

DROP TABLE IF EXISTS `latest_employee_schedule`;
/*!50001 DROP VIEW IF EXISTS `latest_employee_schedule`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `latest_employee_schedule` AS SELECT
 1 AS `template_id`,
  1 AS `employee_id`,
  1 AS `requested_by`,
  1 AS `datetime_created`,
  1 AS `request_id`,
  1 AS `date_assigned`,
  1 AS `number_of_punch` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `policies_violated`
--

DROP TABLE IF EXISTS `policies_violated`;
/*!50001 DROP VIEW IF EXISTS `policies_violated`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `policies_violated` AS SELECT
 1 AS `request_id`,
  1 AS `policies_violated` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `request_violation_employees`
--

DROP TABLE IF EXISTS `request_violation_employees`;
/*!50001 DROP VIEW IF EXISTS `request_violation_employees`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `request_violation_employees` AS SELECT
 1 AS `request_id`,
  1 AS `employees_involved_request` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `template_policies`
--

DROP TABLE IF EXISTS `template_policies`;
/*!50001 DROP VIEW IF EXISTS `template_policies`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `template_policies` AS SELECT
 1 AS `template_id`,
  1 AS `policies` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `violation_employees`
--

DROP TABLE IF EXISTS `violation_employees`;
/*!50001 DROP VIEW IF EXISTS `violation_employees`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `violation_employees` AS SELECT
 1 AS `entry_id`,
  1 AS `employees_involved` */;
SET character_set_client = @saved_cs_client;

--
-- Current Database: `employees_profile_udf_and_views`
--

USE `employees_profile_udf_and_views`;

--
-- Final view structure for view `employee_beneficiary_details`
--

/*!50001 DROP VIEW IF EXISTS `employee_beneficiary_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_beneficiary_details` AS select `a`.`employee_id` AS `employee_id`,json_arrayagg(json_object('beneficiary_id',`a`.`beneficiary_id`,'entity_id',`a`.`entities_entity_id`,'person_id',`e`.`person_id`,'contact_number',ifnull(nullif(`e`.`mobilephone1`,''),`e`.`mobilephone2`),'address',concat_ws(', ',`e`.`adrs_house_street`,`f`.`barangay_district_name`,`g`.`town_name`,concat(`h`.`province_state_name`,' ',`e`.`zip_code`),`i`.`country_name`),'beneficiary_name',concat(`e`.`lastname`,', ',`e`.`firstname`,' ',`e`.`middlename`),'relation_id',`a`.`relation_id`,'relation',`c`.`description`)) AS `beneficiary_details` from ((((((((`employees_profile`.`beneficiaries` `a` join `employees_profile`.`employees` `b` on(`a`.`employee_id` = `b`.`employee_id`)) join `employees_profile`.`relations` `c` on(`a`.`relation_id` = `c`.`relation_id`)) join `entities`.`entities` `d` on(`a`.`entities_entity_id` = `d`.`entity_id`)) join `entities`.`persons` `e` on(`d`.`person_id` = `e`.`person_id`)) join `entities`.`barangays_districts` `f` on(`e`.`adrs_barangay` = `f`.`barangay_district_id`)) join `entities`.`towns` `g` on(`f`.`town_id` = `g`.`town_id`)) join `entities`.`provinces_states` `h` on(`g`.`province_state_id` = `h`.`province_state_id`)) join `entities`.`countries` `i` on(`h`.`country_id` = `i`.`country_id`)) group by `a`.`employee_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_dependents_details`
--

/*!50001 DROP VIEW IF EXISTS `employee_dependents_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_dependents_details` AS select `a`.`employee_id` AS `employee_id`,json_arrayagg(json_object('entity_id',`a`.`entity_id`,'person_id',`e`.`person_id`,'contact_number',ifnull(nullif(`e`.`mobilephone1`,''),`e`.`mobilephone2`),'address',concat_ws(', ',`e`.`adrs_house_street`,`f`.`barangay_district_name`,`g`.`town_name`,concat(`h`.`province_state_name`,' ',`e`.`zip_code`),`i`.`country_name`),'dependents_name',concat(`e`.`lastname`,', ',`e`.`firstname`,' ',`e`.`middlename`),'relation_id',`a`.`relation_id`,'relation',`c`.`description`)) AS `dependents_details` from ((((((((`employees_profile`.`dependents` `a` join `employees_profile`.`employees` `b` on(`a`.`employee_id` = `b`.`employee_id`)) join `employees_profile`.`relations` `c` on(`a`.`relation_id` = `c`.`relation_id`)) join `entities`.`entities` `d` on(`a`.`entity_id` = `d`.`entity_id`)) join `entities`.`persons` `e` on(`d`.`person_id` = `e`.`person_id`)) join `entities`.`barangays_districts` `f` on(`e`.`adrs_barangay` = `f`.`barangay_district_id`)) join `entities`.`towns` `g` on(`f`.`town_id` = `g`.`town_id`)) join `entities`.`provinces_states` `h` on(`g`.`province_state_id` = `h`.`province_state_id`)) join `entities`.`countries` `i` on(`h`.`country_id` = `i`.`country_id`)) group by `a`.`employee_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_education_details`
--

/*!50001 DROP VIEW IF EXISTS `employee_education_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_education_details` AS select `a`.`employee_id` AS `employee_id`,json_arrayagg(json_object('school_id',`a`.`school_id`,'school_name',`d`.`school_name`,'education_id',`a`.`education_id`,'education_level',`b`.`description`,'date_graduated',`a`.`date_graduated`,'degree',`a`.`degree`,'town_id',`a`.`town_id`,'town_name',`e`.`town_name`,'province_state_id',`e`.`province_state_id`,'province_state_name',`f`.`province_state_name`,'country_id',`f`.`country_id`,'country_name',`g`.`country_name`,'school_address',concat_ws(', ',`e`.`town_name`,`f`.`province_state_name`,`g`.`country_name`),'phone_01',`a`.`phone_01`,'phone_02',`a`.`phone_02`)) AS `education_details` from (((((`employees_profile`.`education_backgrounds` `a` join `employees_profile`.`educational_level` `b` on(`a`.`education_id` = `b`.`education_id`)) join `employees_profile`.`schools` `d` on(`a`.`school_id` = `d`.`school_id`)) join `entities`.`towns` `e` on(`a`.`town_id` = `e`.`town_id`)) join `entities`.`provinces_states` `f` on(`e`.`province_state_id` = `f`.`province_state_id`)) join `entities`.`countries` `g` on(`f`.`country_id` = `g`.`country_id`)) group by `a`.`employee_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_emergency_contact_details`
--

/*!50001 DROP VIEW IF EXISTS `employee_emergency_contact_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_emergency_contact_details` AS select `a`.`employee_id` AS `employee_id`,json_arrayagg(json_object('entity_id',`a`.`entities_entity_id`,'person_id',`d`.`person_id`,'contact_number',ifnull(nullif(`d`.`mobilephone1`,''),`d`.`mobilephone2`),'emergency_contact_name',concat(`d`.`lastname`,', ',`d`.`firstname`,' ',`d`.`middlename`),'relation_id',`a`.`relation_id`,'relation',`b`.`description`)) AS `emergency_contact_details` from (((`employees_profile`.`emergency_contacts` `a` join `employees_profile`.`relations` `b` on(`a`.`relation_id` = `b`.`relation_id`)) join `entities`.`entities` `c` on(`a`.`entities_entity_id` = `c`.`entity_id`)) join `entities`.`persons` `d` on(`c`.`person_id` = `d`.`person_id`)) group by `a`.`employee_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_employment_history`
--

/*!50001 DROP VIEW IF EXISTS `employee_employment_history`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_employment_history` AS select `a`.`employee_id` AS `employee_id`,json_arrayagg(json_object('employer_id',`a`.`employer_id`,'employer_name',`b`.`employer_name`,'contact_number',`b`.`contact_number`,'employer_industry_id',`b`.`industry_id`,'employer_entity_id',`b`.`employer_entity_id`,'employer_industry',`b`.`industry`,'bsns_zip_code',`b`.`zip_code`,'bsns_house_street',`b`.`bsns_house_street`,'bsns_barangay',`b`.`bsns_barangay`,'bsns_barangay_name',`b`.`bsns_barangay_name`,'bsns_town',`b`.`bsns_town`,'bsns_town_name',`b`.`bsns_town_name`,'bsns_province',`b`.`bsns_province`,'bsns_province_name',`b`.`bsns_province_name`,'bsns_country',`b`.`bsns_country`,'bsns_country_name',`b`.`bsns_country_name`,'business_address',`b`.`business_address`,'position_id',`a`.`position_id`,'employment_position',`c`.`description`,'period_from',`a`.`period_from`,'frmt_period_from',ifnull(date_format(`a`.`period_from`,'%Y %b %d'),''),'period_to',`a`.`period_to`,'frmt_period_to',ifnull(date_format(`a`.`period_to`,'%Y %b %d'),''))) AS `employment_history` from ((`employees_profile`.`employment_history` `a` join (select `a`.`employer_id` AS `employer_id`,`d`.`nonperson_name` AS `employer_name`,`c`.`entity_id` AS `employer_entity_id`,ifnull(nullif(`d`.`mobilephone1`,''),`d`.`mobilephone2`) AS `contact_number`,`a`.`industry_id` AS `industry_id`,`b`.`description` AS `industry`,`d`.`zip_code` AS `zip_code`,`d`.`adrs_house_street` AS `bsns_house_street`,`d`.`adrs_barangay` AS `bsns_barangay`,`dd`.`barangay_district_name` AS `bsns_barangay_name`,`dd`.`town_id` AS `bsns_town`,`e`.`town_name` AS `bsns_town_name`,`e`.`province_state_id` AS `bsns_province`,`f`.`province_state_name` AS `bsns_province_name`,`f`.`country_id` AS `bsns_country`,`g`.`country_name` AS `bsns_country_name`,concat_ws(', ',`d`.`adrs_house_street`,`dd`.`barangay_district_name`,`e`.`town_name`,concat(`f`.`province_state_name`,' ',`d`.`zip_code`),`g`.`country_name`) AS `business_address` from (((((((`employees_profile`.`employers` `a` join `employees_profile`.`industries` `b` on(`a`.`industry_id` = `b`.`industry_id`)) join `entities`.`entities` `c` on(`a`.`entity_id` = `c`.`entity_id`)) join `entities`.`non_persons` `d` on(`c`.`nonperson_id` = `d`.`nonperson_id`)) join `entities`.`barangays_districts` `dd` on(`d`.`adrs_barangay` = `dd`.`barangay_district_id`)) join `entities`.`towns` `e` on(`dd`.`town_id` = `e`.`town_id`)) join `entities`.`provinces_states` `f` on(`e`.`province_state_id` = `f`.`province_state_id`)) join `entities`.`countries` `g` on(`f`.`country_id` = `g`.`country_id`))) `b` on(`a`.`employer_id` = `b`.`employer_id`)) join `employees_profile`.`employment_positions` `c` on(`a`.`position_id` = `c`.`position_id`)) group by `a`.`employee_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_info`
--

/*!50001 DROP VIEW IF EXISTS `employee_info`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_info` AS select `emp_info`.`employee_name` AS `employee_name`,`emp_info`.`employee_number` AS `employee_number`,`emp_info`.`date_hired` AS `date_hired`,`emp_info`.`tenure_in_years` AS `tenure_in_years`,`emp_info`.`employee_type_id` AS `employee_type_id`,`emp_info`.`employee_type` AS `employee_type`,`emp_info`.`employee_id` AS `employee_id`,`emp_info`.`daily_rate` AS `daily_rate`,`emp_info`.`estimated_monthly_rate` AS `estimated_monthly_rate`,`emp_info`.`daily_paid` AS `daily_paid`,`emp_info`.`entitled_overtime` AS `entitled_overtime`,`emp_info`.`entitled_holiday` AS `entitled_holiday`,`emp_info`.`personal_exemption` AS `personal_exemption`,`emp_info`.`dependents_exemption` AS `dependents_exemption`,`emp_info`.`total_exemptions` AS `total_exemptions`,`emp_info`.`schedule_template_id` AS `schedule_template_id`,`emp_info`.`unit_id` AS `unit_id`,`emp_info`.`unit_description` AS `unit_description`,`emp_info`.`department_id` AS `department_id`,`emp_info`.`department_description` AS `department_description`,`emp_info`.`sub_id` AS `sub_id`,`emp_info`.`sub_department_description` AS `sub_department_description`,case when exists(select 1 from (`employees_profile`.`employee_cessations` `ec` join `employees_profile`.`employment_status` `ems` on(`ems`.`status_id` = `ec`.`status_id`)) where `ems`.`cessation_status` <> 0 and `ec`.`employee_id` = `emp_info`.`employee_id` limit 1) then 0 else 1 end AS `current_employee`,`emp_info`.`sss_number` AS `sss_number`,`emp_info`.`philhealth_number` AS `philhealth_number`,`emp_info`.`pag_ibig_number` AS `pag_ibig_number`,`emp_info`.`number_of_punch` AS `number_of_punch` from (select concat(`p`.`lastname`,', ',`p`.`firstname`,' ',`p`.`middlename`) AS `employee_name`,concat(date_format(`e`.`date_hired`,'%m%y'),'-',`e`.`employee_id`) AS `employee_number`,`e`.`date_hired` AS `date_hired`,`e`.`tenure_in_years` AS `tenure_in_years`,`jr`.`type_id` AS `employee_type_id`,`etp`.`description` AS `employee_type`,`er`.`employee_id` AS `employee_id`,`er`.`daily_rate` AS `daily_rate`,(select cast(case when count(`estod`.`request_id`) > 1 then `er`.`daily_rate` * 247 / 12 else `er`.`daily_rate` * 313 / 12 end as decimal(12,2)) from (`employees_profile_udf_and_views`.`latest_employee_schedule` `les` join `employees_profile`.`employees_schedule_templates_other_details` `estod` on(`estod`.`request_id` = `les`.`request_id`)) where `les`.`employee_id` = `er`.`employee_id`) AS `estimated_monthly_rate`,`er`.`daily_paid` AS `daily_paid`,`er`.`entitled_overtime` AS `entitled_overtime`,`er`.`entitled_holiday` AS `entitled_holiday`,`er`.`personal_exemption` AS `personal_exemption`,`er`.`dependents_exemption` AS `dependents_exemption`,`er`.`total_exemptions` AS `total_exemptions`,`est`.`template_id` AS `schedule_template_id`,`eu`.`unit_id` AS `unit_id`,coalesce((select `u`.`description` from `subscriber_common_tables`.`units` `u` where `u`.`unit_id` = `eu`.`unit_id`),'N/A') AS `unit_description`,`emd`.`department_id` AS `department_id`,coalesce((select `md`.`description` from `subscriber_common_tables`.`main_department` `md` where `md`.`department_id` = `emd`.`department_id`),'N/A') AS `department_description`,`esd`.`sub_id` AS `sub_id`,coalesce((select `sd`.`description` from `subscriber_common_tables`.`sub_deparment` `sd` where `sd`.`sub_id` = `esd`.`sub_id`),'') AS `sub_department_description`,`e`.`sss_number` AS `sss_number`,`e`.`philhealth_number` AS `philhealth_number`,`e`.`pag_ibig_number` AS `pag_ibig_number`,`est`.`number_of_punch` AS `number_of_punch` from ((((((((((`employees_profile`.`employee_rate` `er` join `employees_profile`.`employees` `e` on(`er`.`employee_id` = `e`.`employee_id`)) join `entities`.`entities` `et` on(`e`.`entity_id` = `et`.`entity_id`)) join `entities`.`persons` `p` on(`et`.`person_id` = `p`.`person_id`)) join `employees_profile`.`employees_jobs` `ej` on(`e`.`employee_id` = `ej`.`employee_id`)) join `employees_profile`.`job_references` `jr` on(`ej`.`job_reference` = `jr`.`reference_id`)) join `employees_profile`.`employee_types` `etp` on(`jr`.`type_id` = `etp`.`type_id`)) join (select max(`est`.`employee_id`) AS `employee_id`,`est`.`template_id` AS `template_id`,`est`.`number_of_punch` AS `number_of_punch` from `employees_profile`.`employees_schedule_templates` `est` group by `est`.`employee_id` desc) `est` on(`e`.`employee_id` = `est`.`employee_id`)) join `employees_profile`.`employees_units` `eu` on(`e`.`employee_id` = `eu`.`employee_id`)) left join `employees_profile`.`employees_main_department` `emd` on(`e`.`employee_id` = `emd`.`employee_id`)) left join `employees_profile`.`employees_sub_department` `esd` on(`e`.`employee_id` = `esd`.`employee_id`))) `emp_info` group by `emp_info`.`employee_id` order by `emp_info`.`employee_name` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_main_department_choices`
--

/*!50001 DROP VIEW IF EXISTS `employee_main_department_choices`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_main_department_choices` AS select `aa`.`employee_id` AS `employee_id`,`a`.`unit_id` AS `unit_id`,`a`.`department_id` AS `department_id`,`b`.`description` AS `main_department` from (((`employees_profile`.`employees_units` `aa` join `subscriber_common_tables`.`units` `bb` on(`aa`.`unit_id` = `bb`.`unit_id`)) join `subscriber_common_tables`.`units_main_departments` `a` on(`bb`.`unit_id` = `a`.`unit_id`)) join `subscriber_common_tables`.`main_department` `b` on(`a`.`department_id` = `b`.`department_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_name`
--

/*!50001 DROP VIEW IF EXISTS `employee_name`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_name` AS select `aa`.`employee_id` AS `employee_id`,`aa`.`entity_id` AS `entity_id`,case when exists(select 1 from (`employees_profile`.`employee_cessations` `ec` join `employees_profile`.`employment_status` `ems` on(`ems`.`status_id` = `ec`.`status_id`)) where `ems`.`cessation_status` <> 0 and `ec`.`employee_id` = `aa`.`employee_id` limit 1) then 0 else 1 end AS `current_employee`,`aa`.`customer_id` AS `customer_id`,`aa`.`frmt_employee_id` AS `frmt_employee_id`,`aa`.`employee_name` AS `employee_name`,concat('(',`aa`.`frmt_employee_id`,') ',`aa`.`employee_name`) AS `frmt_employee_name` from (select `a`.`employee_id` AS `employee_id`,`b`.`entity_id` AS `entity_id`,`b`.`customer_id` AS `customer_id`,concat('E',date_format(`a`.`datetime_created`,'%m%Y'),'-',lpad(`a`.`employee_id`,5,'0')) AS `frmt_employee_id`,`b`.`entity_name` AS `employee_name` from (`employees_profile`.`employees` `a` join `entities_udf_and_views`.`entity_name` `b` on(`a`.`entity_id` = `b`.`entity_id`))) `aa` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_parent_details`
--

/*!50001 DROP VIEW IF EXISTS `employee_parent_details`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_parent_details` AS select `a`.`employee_id` AS `employee_id`,json_arrayagg(json_object('employee_id',`a`.`employee_id`,'entity_id',`a`.`entity_id`,'person_id',`d`.`person_id`,'parent_name',concat(`d`.`lastname`,', ',`d`.`firstname`,' ',`d`.`middlename`),'relation_id',`a`.`relation_id`,'relation',`b`.`description`,'occupation_id',`a`.`occupation_id`,'occupation',`e`.`description`)) AS `parent_details` from ((((`employees_profile`.`parents` `a` join `employees_profile`.`relations` `b` on(`a`.`relation_id` = `b`.`relation_id`)) join `entities`.`entities` `c` on(`a`.`entity_id` = `c`.`entity_id`)) join `entities`.`persons` `d` on(`c`.`person_id` = `d`.`person_id`)) left join `employees_profile`.`occupations` `e` on(`a`.`occupation_id` = `e`.`occupation_id`)) group by `a`.`employee_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `employee_sub_department_choices`
--

/*!50001 DROP VIEW IF EXISTS `employee_sub_department_choices`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `employee_sub_department_choices` AS select `aa`.`employee_id` AS `employee_id`,`a`.`department_id` AS `department_id`,`a`.`sub_id` AS `sub_id`,`a`.`description` AS `sub_department` from ((`employees_profile`.`employees_main_department` `aa` join `subscriber_common_tables`.`main_department` `bb` on(`aa`.`department_id` = `bb`.`department_id`)) join `subscriber_common_tables`.`sub_deparment` `a` on(`bb`.`department_id` = `a`.`department_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `latest_employee_schedule`
--

/*!50001 DROP VIEW IF EXISTS `latest_employee_schedule`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `latest_employee_schedule` AS select `est`.`template_id` AS `template_id`,max(`est`.`employee_id`) AS `employee_id`,`est`.`requested_by` AS `requested_by`,`est`.`datetime_created` AS `datetime_created`,`est`.`request_id` AS `request_id`,(select `employees_profile`.`request_employees_schedule_templates`.`date_effective` from `employees_profile`.`request_employees_schedule_templates` where `employees_profile`.`request_employees_schedule_templates`.`request_id` = `est`.`request_id`) AS `date_assigned`,`est`.`number_of_punch` AS `number_of_punch` from `employees_profile`.`employees_schedule_templates` `est` group by `est`.`employee_id` desc order by `est`.`request_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `policies_violated`
--

/*!50001 DROP VIEW IF EXISTS `policies_violated`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `policies_violated` AS select `psv`.`request_id` AS `request_id`,json_arrayagg(json_object('section_id',`psv`.`section_id`,'section_description',`si`.`brief_description`,'section_detailed_description',`si`.`description`)) AS `policies_violated` from (`employees_profile`.`policy_sections_violated` `psv` join `employees_profile`.`section_items` `si` on(`psv`.`section_id` = `si`.`section_id`)) group by `psv`.`request_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `request_violation_employees`
--

/*!50001 DROP VIEW IF EXISTS `request_violation_employees`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `request_violation_employees` AS select `a`.`request_id` AS `request_id`,json_arrayagg(json_object('employee_id',`a`.`employee_id`,'employee_name',concat(`b`.`employee_name`,' (',lpad(`b`.`employee_id`,8,'0'),')'))) AS `employees_involved_request` from (`employees_profile`.`request_employees_violations` `a` join `employees_profile_udf_and_views`.`employee_name` `b` on(`a`.`employee_id` = `b`.`employee_id`)) group by `a`.`request_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `template_policies`
--

/*!50001 DROP VIEW IF EXISTS `template_policies`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `template_policies` AS select `mpi`.`template_id` AS `template_id`,json_arrayagg(json_object('brief_description',`mpi`.`brief_description`,'detailed_description',`mpi`.`description`,'search_id',concat('main-item-',`mpi`.`main_item_id`),'sub_main',ifnull(`bb`.`sub_main`,json_array()))) AS `policies` from (`employees_profile`.`main_policy_items` `mpi` left join (select `spi`.`main_item_id` AS `main_item_id`,json_arrayagg(json_object('brief_description',`spi`.`brief_description`,'detailed_description',`spi`.`description`,'search_id',concat('sub-item-',`spi`.`sub_item_id`),'section',ifnull(`aa`.`sections`,json_array()))) AS `sub_main` from (`employees_profile`.`sub_policy_items` `spi` left join (select `si`.`sub_item_id` AS `sub_item_id`,json_arrayagg(json_object('brief_description',`si`.`brief_description`,'detailed_description',`si`.`description`,'search_id',concat('section-item-',`si`.`section_id`))) AS `sections` from `employees_profile`.`section_items` `si` group by `si`.`sub_item_id`) `aa` on(`spi`.`sub_item_id` = `aa`.`sub_item_id`)) group by `spi`.`main_item_id`) `bb` on(`mpi`.`main_item_id` = `bb`.`main_item_id`)) group by `mpi`.`template_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `violation_employees`
--

/*!50001 DROP VIEW IF EXISTS `violation_employees`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `violation_employees` AS select `a`.`entry_id` AS `entry_id`,json_arrayagg(json_object('employee_id',`a`.`employee_id`,'employee_name',concat(`b`.`employee_name`,' (',lpad(`b`.`employee_id`,8,'0'),')'))) AS `employees_involved` from (`employees_profile`.`employees_violations` `a` join `employees_profile_udf_and_views`.`employee_name` `b` on(`a`.`employee_id` = `b`.`employee_id`)) group by `a`.`entry_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: subscriber_common_tables
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `subscriber_common_tables`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `subscriber_common_tables` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci */;

USE `subscriber_common_tables`;

--
-- Table structure for table `beyond_office_hours_users`
--

DROP TABLE IF EXISTS `beyond_office_hours_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `beyond_office_hours_users` (
  `beyond_office_hours_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `datetime_start` datetime NOT NULL,
  `datetime_end` datetime NOT NULL,
  KEY `fk_beyond_office_hours_users_application_users1_idx` (`user_id`),
  KEY `fk_beyond_office_hours_users_request_beyond_office_hours1_idx` (`beyond_office_hours_id`),
  CONSTRAINT `fk_beyond_office_hours_users_application_users1` FOREIGN KEY (`user_id`) REFERENCES `application_users`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_beyond_office_hours_users_request_beyond_office_hours1` FOREIGN KEY (`beyond_office_hours_id`) REFERENCES `request_beyond_office_hours` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `billing_statement_preference`
--

DROP TABLE IF EXISTS `billing_statement_preference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `billing_statement_preference` (
  `app_name` char(20) NOT NULL,
  `payable_to` varchar(145) DEFAULT NULL,
  `contact_number` varchar(20) DEFAULT NULL,
  `email` varchar(90) DEFAULT NULL,
  `note` varchar(145) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `business_non_working`
--

DROP TABLE IF EXISTS `business_non_working`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `business_non_working` (
  `entry_id` int(11) NOT NULL AUTO_INCREMENT,
  `non_working_date` date NOT NULL,
  `holiday_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_business_non_working_calendar_of_holidays1_idx` (`holiday_id`),
  CONSTRAINT `fk_business_non_working_calendar_of_holidays1` FOREIGN KEY (`holiday_id`) REFERENCES `calendar_of_holidays` (`holiday_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=327 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `calendar_of_holidays`
--

DROP TABLE IF EXISTS `calendar_of_holidays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `calendar_of_holidays` (
  `holiday_id` int(11) NOT NULL AUTO_INCREMENT,
  `holiday_date` date NOT NULL,
  `description` char(100) NOT NULL,
  `non_working` tinyint(4) NOT NULL DEFAULT 1,
  `special` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`holiday_id`)
) ENGINE=InnoDB AUTO_INCREMENT=113 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `connection_authentication`
--

DROP TABLE IF EXISTS `connection_authentication`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `connection_authentication` (
  `auth_key` varchar(100) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `country_holiday`
--

DROP TABLE IF EXISTS `country_holiday`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `country_holiday` (
  `holiday_id` int(11) NOT NULL,
  `country_id` int(11) NOT NULL,
  KEY `fk_country_holiday_calendar_of_holidays1_idx` (`holiday_id`),
  KEY `fk_country_holiday_countries1_idx` (`country_id`),
  CONSTRAINT `fk_country_holiday_calendar_of_holidays1` FOREIGN KEY (`holiday_id`) REFERENCES `calendar_of_holidays` (`holiday_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_country_holiday_countries1` FOREIGN KEY (`country_id`) REFERENCES `entities`.`countries` (`country_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `end_of_day`
--

DROP TABLE IF EXISTS `end_of_day`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `end_of_day` (
  `executed_by` int(11) NOT NULL,
  `datetime_executed` datetime NOT NULL DEFAULT current_timestamp(),
  `end_of_day` date NOT NULL,
  `beginning_of_day` date NOT NULL,
  KEY `fk_end_of_day_application_users1_idx` (`executed_by`),
  CONSTRAINT `fk_end_of_day_application_users1` FOREIGN KEY (`executed_by`) REFERENCES `application_users`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `link_employee`
--

DROP TABLE IF EXISTS `link_employee`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `link_employee` (
  `plan_link_id` int(11) NOT NULL,
  `employee_id` int(11) NOT NULL,
  KEY `fk_link_employee_plan_link1_idx` (`plan_link_id`),
  KEY `fk_link_employee_employees1_idx` (`employee_id`),
  CONSTRAINT `fk_link_employee_employees1` FOREIGN KEY (`employee_id`) REFERENCES `employees_profile`.`employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_link_employee_plan_link1` FOREIGN KEY (`plan_link_id`) REFERENCES `plan_link` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `link_unit`
--

DROP TABLE IF EXISTS `link_unit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `link_unit` (
  `plan_link_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  KEY `fk_table1_plan_link1_idx` (`plan_link_id`),
  KEY `fk_table1_units1_idx` (`unit_id`),
  CONSTRAINT `fk_table1_plan_link1` FOREIGN KEY (`plan_link_id`) REFERENCES `plan_link` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_units1` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `link_user`
--

DROP TABLE IF EXISTS `link_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `link_user` (
  `plan_link_id` int(11) NOT NULL,
  `subscriber_user_id` int(11) NOT NULL,
  KEY `fk_link_user_plan_link1_idx` (`plan_link_id`),
  KEY `fk_link_user_subscribers_users1_idx` (`subscriber_user_id`),
  CONSTRAINT `fk_link_user_plan_link1` FOREIGN KEY (`plan_link_id`) REFERENCES `plan_link` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_link_user_subscribers_users1` FOREIGN KEY (`subscriber_user_id`) REFERENCES `application_users_employees_profile`.`subscribers_users` (`subscriber_user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `main_department`
--

DROP TABLE IF EXISTS `main_department`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `main_department` (
  `department_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(100) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL,
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`department_id`),
  KEY `fk_main_department_application_users1_idx` (`created_by`),
  KEY `fk_main_department_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_main_department_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_main_department_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_employees_profile`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `module_mapping`
--

DROP TABLE IF EXISTS `module_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `module_mapping` (
  `unique_id` int(11) NOT NULL AUTO_INCREMENT,
  `application_description` varchar(100) DEFAULT NULL,
  `template_column` varchar(100) DEFAULT NULL,
  `schema_prefix` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`unique_id`)
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `office_hours`
--

DROP TABLE IF EXISTS `office_hours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `office_hours` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(99) NOT NULL,
  `non_working` tinyint(1) DEFAULT 0,
  `holiday` tinyint(1) DEFAULT 0,
  `non_working_holiday` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `office_hours_details`
--

DROP TABLE IF EXISTS `office_hours_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `office_hours_details` (
  `office_hours_id` int(11) NOT NULL,
  `time_start` time NOT NULL,
  `time_end` time NOT NULL,
  `sun` tinyint(1) DEFAULT 0,
  `mon` tinyint(1) DEFAULT 0,
  `tue` tinyint(1) DEFAULT 0,
  `wed` tinyint(1) DEFAULT 0,
  `thu` tinyint(1) DEFAULT 0,
  `fri` tinyint(1) DEFAULT 0,
  `sat` tinyint(1) DEFAULT 0,
  KEY `fk_office_hours_details_office_hours1_idx` (`office_hours_id`),
  CONSTRAINT `fk_office_hours_details_office_hours1` FOREIGN KEY (`office_hours_id`) REFERENCES `office_hours` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `office_hours_users`
--

DROP TABLE IF EXISTS `office_hours_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `office_hours_users` (
  `office_hours_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  KEY `fk_office_hours_users_office_hours1_idx` (`office_hours_id`),
  KEY `fk_office_hours_users_application_users1_idx` (`user_id`),
  CONSTRAINT `fk_office_hours_users_application_users1` FOREIGN KEY (`user_id`) REFERENCES `application_users`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_office_hours_users_office_hours1` FOREIGN KEY (`office_hours_id`) REFERENCES `office_hours` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pdf_report_preference`
--

DROP TABLE IF EXISTS `pdf_report_preference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pdf_report_preference` (
  `repeat_header` tinyint(1) DEFAULT 0,
  `enclose_negative` tinyint(1) DEFAULT 0,
  `table_header_bg_color` char(10) DEFAULT '#',
  `table_row_alternate_color` tinyint(1) DEFAULT 0,
  `vertical_table_border` tinyint(1) DEFAULT 0,
  `horizontal_table_border` tinyint(1) DEFAULT 0,
  `summary_background` tinyint(1) DEFAULT 0,
  `show_number_of_entries` tinyint(1) DEFAULT 0,
  `pdf_header` mediumblob DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `plan_link`
--

DROP TABLE IF EXISTS `plan_link`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `plan_link` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  `max_count` int(11) DEFAULT 0,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `province_holiday`
--

DROP TABLE IF EXISTS `province_holiday`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `province_holiday` (
  `holiday_id` int(11) NOT NULL,
  `province_state_id` int(11) NOT NULL,
  KEY `fk_province_holiday_calendar_of_holidays1_idx` (`holiday_id`),
  KEY `fk_province_holiday_provinces_states1_idx` (`province_state_id`),
  CONSTRAINT `fk_province_holiday_calendar_of_holidays1` FOREIGN KEY (`holiday_id`) REFERENCES `calendar_of_holidays` (`holiday_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_province_holiday_provinces_states1` FOREIGN KEY (`province_state_id`) REFERENCES `entities`.`provinces_states` (`province_state_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `psa_barangays`
--

DROP TABLE IF EXISTS `psa_barangays`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `psa_barangays` (
  `bgy_id` int(11) NOT NULL AUTO_INCREMENT,
  `barangay` varchar(45) DEFAULT NULL,
  `town` char(6) NOT NULL,
  `town_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`bgy_id`)
) ENGINE=InnoDB AUTO_INCREMENT=42002 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `psa_muncity`
--

DROP TABLE IF EXISTS `psa_muncity`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `psa_muncity` (
  `city_id` int(11) NOT NULL AUTO_INCREMENT,
  `city` char(60) NOT NULL,
  `interface_id` char(6) NOT NULL,
  `province` char(4) NOT NULL,
  `prov_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`city_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1649 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `psa_province`
--

DROP TABLE IF EXISTS `psa_province`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `psa_province` (
  `prov_id` int(11) NOT NULL AUTO_INCREMENT,
  `province` char(60) NOT NULL,
  `interface_id` char(4) NOT NULL,
  PRIMARY KEY (`prov_id`)
) ENGINE=InnoDB AUTO_INCREMENT=88 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_beyond_office_hours`
--

DROP TABLE IF EXISTS `request_beyond_office_hours`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_beyond_office_hours` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `datetime_start` datetime DEFAULT NULL,
  `datetime_end` datetime DEFAULT NULL,
  `system_remarks` varchar(150) DEFAULT NULL,
  `reason` varchar(150) NOT NULL,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime DEFAULT current_timestamp(),
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  `added_by_admin` tinyint(1) DEFAULT 0,
  `attempt_denied` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `fk_request_beyond_office_hours_application_users1_idx` (`requested_by`),
  KEY `fk_request_beyond_office_hours_application_users2_idx` (`approved_by`),
  CONSTRAINT `fk_request_beyond_office_hours_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_beyond_office_hours_application_users2` FOREIGN KEY (`approved_by`) REFERENCES `application_users`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=155 DEFAULT CHARSET=ascii COLLATE=ascii_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sub_deparment`
--

DROP TABLE IF EXISTS `sub_deparment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sub_deparment` (
  `sub_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(100) NOT NULL,
  `department_id` int(11) NOT NULL,
  PRIMARY KEY (`sub_id`),
  KEY `fk_sub_deparment_main_department1_idx` (`department_id`),
  CONSTRAINT `fk_sub_deparment_main_department1` FOREIGN KEY (`department_id`) REFERENCES `main_department` (`department_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscriber_multiple_units`
--

DROP TABLE IF EXISTS `subscriber_multiple_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscriber_multiple_units` (
  `unit_id` int(11) NOT NULL,
  `subscriber_user_id` int(11) NOT NULL,
  KEY `fk_subscriber_multiple_units_units_idx` (`unit_id`),
  KEY `fk_subscriber_multiple_units_subscribers_users1_idx` (`subscriber_user_id`),
  CONSTRAINT `fk_subscriber_multiple_units_subscribers_users1` FOREIGN KEY (`subscriber_user_id`) REFERENCES `application_users`.`subscribers_users` (`subscriber_user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_subscriber_multiple_units_units` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_preference`
--

DROP TABLE IF EXISTS `system_preference`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_preference` (
  `auto_end_of_day` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `town_holiday`
--

DROP TABLE IF EXISTS `town_holiday`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `town_holiday` (
  `holiday_id` int(11) NOT NULL,
  `town_id` int(11) NOT NULL,
  KEY `fk_town_holiday_calendar_of_holidays1_idx` (`holiday_id`),
  KEY `fk_town_holiday_towns1_idx` (`town_id`),
  CONSTRAINT `fk_town_holiday_calendar_of_holidays1` FOREIGN KEY (`holiday_id`) REFERENCES `calendar_of_holidays` (`holiday_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_town_holiday_towns1` FOREIGN KEY (`town_id`) REFERENCES `entities`.`towns` (`town_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unit_parameter`
--

DROP TABLE IF EXISTS `unit_parameter`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unit_parameter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `clearing_account_glsl_id` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unit_parameter_details`
--

DROP TABLE IF EXISTS `unit_parameter_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unit_parameter_details` (
  `unit_id` int(11) NOT NULL,
  `unit_parameter_id` int(11) NOT NULL,
  `due_to_glsl_id` int(11) NOT NULL,
  `due_from_glsl_id` int(11) NOT NULL,
  KEY `fk_unit_parameter_details_unit_parameter1_idx` (`unit_parameter_id`),
  KEY `fk_unit_parameter_details_units1_idx` (`unit_id`),
  CONSTRAINT `fk_unit_parameter_details_unit_parameter1` FOREIGN KEY (`unit_parameter_id`) REFERENCES `unit_parameter` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_unit_parameter_details_units1` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `units`
--

DROP TABLE IF EXISTS `units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `units` (
  `unit_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(80) NOT NULL,
  `bldg_street_address` char(200) DEFAULT NULL,
  `barangay_district_id` int(11) DEFAULT NULL,
  `head_office` tinyint(4) NOT NULL DEFAULT 0,
  `active` tinyint(1) DEFAULT 1,
  PRIMARY KEY (`unit_id`),
  KEY `fk_units_barangays_districts_idx` (`barangay_district_id`),
  CONSTRAINT `fk_units_barangays_districts` FOREIGN KEY (`barangay_district_id`) REFERENCES `entities`.`barangays_districts` (`barangay_district_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `units_main_departments`
--

DROP TABLE IF EXISTS `units_main_departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `units_main_departments` (
  `unit_id` int(11) NOT NULL,
  `department_id` int(11) NOT NULL,
  KEY `fk_units_main_departments_units1_idx` (`unit_id`),
  KEY `fk_units_main_departments_main_department1_idx` (`department_id`),
  CONSTRAINT `fk_units_main_departments_main_department1` FOREIGN KEY (`department_id`) REFERENCES `main_department` (`department_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_units_main_departments_units1` FOREIGN KEY (`unit_id`) REFERENCES `units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: application_users_inventory
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `application_users_inventory`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `application_users_inventory` /*!40100 DEFAULT CHARACTER SET utf8mb3 COLLATE utf8mb3_unicode_ci */;

USE `application_users_inventory`;

--
-- Table structure for table `access_template_details`
--

DROP TABLE IF EXISTS `access_template_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_template_details` (
  `template_id` int(11) DEFAULT NULL,
  `function_id` int(11) NOT NULL AUTO_INCREMENT,
  KEY `access_template_details_to_access_templates_idx` (`template_id`),
  KEY `access_template_details_to_functionalities_idx` (`function_id`),
  CONSTRAINT `access_template_details_to_access_templates` FOREIGN KEY (`template_id`) REFERENCES `access_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `access_template_details_to_functionalities` FOREIGN KEY (`function_id`) REFERENCES `functionalities` (`function_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `access_templates`
--

DROP TABLE IF EXISTS `access_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `access_templates` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(80) NOT NULL,
  `admin` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`template_id`),
  UNIQUE KEY `description_UNIQUE` (`description`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `application_users`
--

DROP TABLE IF EXISTS `application_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_login_name` varchar(45) NOT NULL,
  `unit_id` int(11) DEFAULT NULL,
  `previous_login` datetime NOT NULL DEFAULT '1900-01-01 00:00:00',
  `previous_logout` datetime NOT NULL DEFAULT '1900-01-01 00:00:00',
  `current_login` datetime NOT NULL DEFAULT '1900-01-01 00:00:00',
  `current_logout` datetime NOT NULL DEFAULT '1900-01-01 00:00:00',
  `access_template_id` int(11) DEFAULT NULL,
  `last_password_change` datetime DEFAULT '1900-01-01 00:00:00',
  `approving_officer` tinyint(4) NOT NULL DEFAULT 0,
  `approving_amount_ceiling_daily` double(12,2) NOT NULL DEFAULT 0.00,
  `approving_amount_ceiling_monthly` double(12,2) NOT NULL DEFAULT 0.00,
  `logged_in` tinyint(4) NOT NULL DEFAULT 0,
  `passwd` varchar(250) DEFAULT NULL,
  `check_digit` tinyint(4) NOT NULL DEFAULT 0,
  `locked` tinyint(4) NOT NULL DEFAULT 0,
  `lock_expiry` int(11) DEFAULT NULL,
  `invalid_login_count` tinyint(1) NOT NULL DEFAULT 0,
  `block_user` tinyint(4) NOT NULL DEFAULT 0,
  `admin_user` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_login_name_UNIQUE` (`user_login_name`),
  KEY `fk_application_users_units1_idx` (`unit_id`),
  KEY `application_users_access_templates_idx` (`access_template_id`),
  CONSTRAINT `application_users_access_templates` FOREIGN KEY (`access_template_id`) REFERENCES `access_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_application_users_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `application_users_dimensions`
--

DROP TABLE IF EXISTS `application_users_dimensions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_users_dimensions` (
  `user_id` int(11) NOT NULL,
  `dimension_id` int(11) NOT NULL,
  KEY `fk_table1_application_users1_idx` (`user_id`),
  KEY `fk_table1_dimensions1_idx` (`dimension_id`),
  CONSTRAINT `fk_table1_application_users1` FOREIGN KEY (`user_id`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_dimensions1` FOREIGN KEY (`dimension_id`) REFERENCES `accounting`.`dimensions` (`dimension_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `auth_tokens`
--

DROP TABLE IF EXISTS `auth_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `auth_tokens` (
  `user_id` int(11) NOT NULL,
  `auth_token` char(200) NOT NULL COMMENT 'SELECT UUID(), UUID_SHORT(), SHA2(RAND(UUID_SHORT()), 512) from inventory.inventory_items limit 10;',
  `expiry` int(11) NOT NULL DEFAULT 0 COMMENT 'select unix_timestamp(DATE_ADD(now(), INTERVAL 60 MINUTE)), now(), DATE_ADD(now(), INTERVAL 60 MINUTE);',
  PRIMARY KEY (`user_id`),
  CONSTRAINT `auth_tokens_to_application_users1` FOREIGN KEY (`user_id`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `field_control_functionalities`
--

DROP TABLE IF EXISTS `field_control_functionalities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `field_control_functionalities` (
  `field_control_id` int(11) NOT NULL,
  `functionalities_id` int(11) NOT NULL,
  KEY `fk_field_control_functionalities_field_control1_idx` (`field_control_id`),
  KEY `fk_field_control_functionalities_functionalities1_idx` (`functionalities_id`),
  CONSTRAINT `fk_field_control_functionalities_field_control1` FOREIGN KEY (`field_control_id`) REFERENCES `access_template_management`.`field_control` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_field_control_functionalities_functionalities1` FOREIGN KEY (`functionalities_id`) REFERENCES `functionalities` (`function_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `function_groupings`
--

DROP TABLE IF EXISTS `function_groupings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `function_groupings` (
  `grouping_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) DEFAULT NULL,
  `image` mediumblob DEFAULT NULL,
  `show_sub` tinyint(1) DEFAULT 0,
  `order_index` int(11) NOT NULL,
  PRIMARY KEY (`grouping_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `functionalities`
--

DROP TABLE IF EXISTS `functionalities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `functionalities` (
  `function_id` int(11) NOT NULL AUTO_INCREMENT,
  `grouping_id` int(11) NOT NULL,
  `admin` tinyint(4) NOT NULL DEFAULT 0,
  `description` varchar(60) NOT NULL,
  `url` varchar(250) NOT NULL,
  `image` mediumblob DEFAULT NULL,
  `order_index` int(11) NOT NULL,
  `involve_currency` tinyint(4) DEFAULT 0,
  `involve_approving` tinyint(4) DEFAULT 0,
  PRIMARY KEY (`function_id`),
  KEY `functionalities_to_function_groupings_idx` (`grouping_id`),
  CONSTRAINT `functionalities_to_function_groupings` FOREIGN KEY (`grouping_id`) REFERENCES `function_groupings` (`grouping_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `functionalities_groupings`
--

DROP TABLE IF EXISTS `functionalities_groupings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `functionalities_groupings` (
  `functionalities_id` int(11) NOT NULL,
  `grouping_details_id` int(11) NOT NULL,
  `isTransactional` tinyint(1) DEFAULT 0,
  `isApprover` tinyint(1) DEFAULT 0,
  `approving_amount_ceiling_daily` decimal(12,2) DEFAULT 0.01,
  `approving_amount_ceiling_monthly` decimal(12,2) DEFAULT 0.01,
  KEY `fk_table1_functionalities1_idx` (`functionalities_id`),
  KEY `fk_table1_1_idx` (`grouping_details_id`),
  CONSTRAINT `fk_table1_1` FOREIGN KEY (`grouping_details_id`) REFERENCES `access_template_management`.`access_templates_grouping_details` (`grouping_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_functionalities1` FOREIGN KEY (`functionalities_id`) REFERENCES `functionalities` (`function_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_application_users_changes_privileges`
--

DROP TABLE IF EXISTS `request_application_users_changes_privileges`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_application_users_changes_privileges` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `user_login_name` varchar(45) NOT NULL,
  `unit_id` int(11) DEFAULT NULL,
  `access_template_id` int(11) DEFAULT NULL,
  `approving_officer` tinyint(4) NOT NULL DEFAULT 0,
  `approving_amount_ceiling_daily` double(12,2) NOT NULL DEFAULT 0.00,
  `approving_amount_ceiling_monthly` double(12,2) NOT NULL DEFAULT 0.00,
  `admin_user` tinyint(4) NOT NULL DEFAULT 0,
  `requested_by` int(11) NOT NULL,
  `datetime_requested` datetime NOT NULL DEFAULT current_timestamp(),
  `approved` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'this will be set to TRUE when approved',
  `approved_by` int(11) DEFAULT NULL,
  `datetime_approved` datetime DEFAULT NULL,
  `implemented` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'set to TRUE when during the beginning of the day process it successfully set the affected user ID’s new unit ID\nONLY APPROVED request entry will be implemented',
  `transaction_date_when_implemented` date DEFAULT NULL COMMENT 'the value of TRANSACTION DATE in the fundparms table when the APPROVED REQUEST IS IMPLEMENTED',
  PRIMARY KEY (`request_id`),
  KEY `fk_request_application_users_changes_privileges_units1_idx` (`unit_id`),
  KEY `fk_request_application_users_changes_privileges_access_temp_idx` (`access_template_id`),
  KEY `fk_request_application_users_changes_privileges_application_idx` (`requested_by`),
  KEY `fk_request_application_users_changes_privileges_application_idx1` (`approved_by`),
  KEY `fk_request_application_users_changes_privileges_application_u1` (`user_id`),
  CONSTRAINT `fk_request_application_users_changes_privileges_access_templa1` FOREIGN KEY (`access_template_id`) REFERENCES `access_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_application_users_changes_privileges_application_u1` FOREIGN KEY (`user_id`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_application_users_changes_privileges_application_u2` FOREIGN KEY (`requested_by`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_application_users_changes_privileges_application_u3` FOREIGN KEY (`approved_by`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_application_users_changes_privileges_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `request_users_change_units`
--

DROP TABLE IF EXISTS `request_users_change_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `request_users_change_units` (
  `request_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL COMMENT 'the application user ID that will be moved to another unit',
  `from_unit_id` int(11) NOT NULL COMMENT 'the application user’s that will be moved current designated unit ID',
  `to_unit_id` int(11) NOT NULL COMMENT 'the unit ID where the affected user ID will be moved to',
  `requested_by` int(11) NOT NULL COMMENT 'the application user ID making or creating the request entry',
  `datetime_requested` datetime NOT NULL DEFAULT current_timestamp(),
  `approved` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'this will be set to TRUE when approved',
  `approved_by` int(11) DEFAULT NULL COMMENT 'the user ID of the officer approving the transfer request',
  `datetime_approved` datetime DEFAULT NULL,
  `implemented` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'set to TRUE when during the beginning of the day process it successfully set the affected user ID’s new unit ID\nONLY APPROVED request entry will be implemented',
  `transaction_date_when_implemented` date DEFAULT NULL COMMENT 'the value of TRANSACTION DATE in the fundparms table when the APPROVED REQUEST IS IMPLEMENTED',
  PRIMARY KEY (`request_id`),
  KEY `fk_request_users_change_units_application_users1_idx` (`user_id`),
  KEY `fk_request_users_change_units_units1_idx` (`from_unit_id`),
  KEY `fk_request_users_change_units_units2_idx` (`to_unit_id`),
  KEY `fk_request_users_change_units_application_users2_idx` (`requested_by`),
  KEY `fk_request_users_change_units_application_users3_idx` (`approved_by`),
  CONSTRAINT `fk_request_users_change_units_application_users1` FOREIGN KEY (`user_id`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_users_change_units_application_users2` FOREIGN KEY (`requested_by`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_users_change_units_application_users3` FOREIGN KEY (`approved_by`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_users_change_units_units1` FOREIGN KEY (`from_unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_request_users_change_units_units2` FOREIGN KEY (`to_unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscribers_applications_user`
--

DROP TABLE IF EXISTS `subscribers_applications_user`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscribers_applications_user` (
  `user_id` int(11) NOT NULL,
  `subscriber_user_id` int(11) NOT NULL,
  KEY `fk_subscribers_applications_user_application_users1_idx` (`user_id`),
  KEY `fk_subscribers_applications_user_subscribers_users1_idx` (`subscriber_user_id`),
  CONSTRAINT `fk_subscribers_applications_user_application_users1` FOREIGN KEY (`user_id`) REFERENCES `application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_subscribers_applications_user_subscribers_users1` FOREIGN KEY (`subscriber_user_id`) REFERENCES `subscribers_users` (`subscriber_user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `subscribers_users`
--

DROP TABLE IF EXISTS `subscribers_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `subscribers_users` (
  `subscriber_user_id` int(11) NOT NULL,
  `full_name` char(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_name` char(60) NOT NULL,
  `email_address` char(250) NOT NULL,
  `admin_user` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`subscriber_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: purchases_ap
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `purchases_ap`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `purchases_ap` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `purchases_ap`;

--
-- Table structure for table `ap_payment_images`
--

DROP TABLE IF EXISTS `ap_payment_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ap_payment_images` (
  `ap_payment_id` int(11) NOT NULL,
  `image` mediumblob NOT NULL,
  PRIMARY KEY (`ap_payment_id`),
  CONSTRAINT `ap_payment_images_ap_payments` FOREIGN KEY (`ap_payment_id`) REFERENCES `ap_payments` (`ap_payment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_payments`
--

DROP TABLE IF EXISTS `ap_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ap_payments` (
  `ap_payment_id` int(11) NOT NULL AUTO_INCREMENT,
  `payment_reference` varchar(45) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `date_paid` date NOT NULL,
  `amount_paid` double(12,2) NOT NULL DEFAULT 1.00,
  `cash_payment` tinyint(4) NOT NULL DEFAULT 1,
  `other_payment` tinyint(4) NOT NULL DEFAULT 0,
  `other_payment_mode` int(11) DEFAULT NULL,
  `posted_by` int(11) NOT NULL,
  `datetime_posted` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'set value to actual server time and date',
  PRIMARY KEY (`ap_payment_id`),
  KEY `ap_payments_payment_modes_idx` (`other_payment_mode`),
  KEY `ap_payments_invoices` (`invoice_id`),
  KEY `fk_ap_payments_application_users1_idx` (`posted_by`),
  CONSTRAINT `ap_payments_invoices` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ap_payments_payment_modes` FOREIGN KEY (`other_payment_mode`) REFERENCES `payment_modes` (`payment_mode_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_ap_payments_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_purchases_ap`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ap_payments_request_vouchers`
--

DROP TABLE IF EXISTS `ap_payments_request_vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ap_payments_request_vouchers` (
  `ap_payment_id` int(11) NOT NULL,
  `voucher_request_id` int(11) NOT NULL,
  KEY `fk_ap_payments_request_vouchers_ap_payments1_idx` (`ap_payment_id`),
  CONSTRAINT `fk_ap_payments_request_vouchers_ap_payments1` FOREIGN KEY (`ap_payment_id`) REFERENCES `ap_payments` (`ap_payment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deliveries`
--

DROP TABLE IF EXISTS `deliveries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deliveries` (
  `delivery_id` int(11) NOT NULL AUTO_INCREMENT,
  `for_delivery_id` int(11) NOT NULL,
  `delivery_date` datetime NOT NULL DEFAULT current_timestamp(),
  `delivery_reference` varchar(45) NOT NULL,
  `posted_by` int(11) NOT NULL,
  `datetime_posted` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'set value to actual server time and date',
  PRIMARY KEY (`delivery_id`),
  UNIQUE KEY `for_delivery_id_UNIQUE` (`for_delivery_id`),
  KEY `deliveries_for_deliveries_idx` (`for_delivery_id`),
  KEY `fk_deliveries_application_users1_idx` (`posted_by`),
  CONSTRAINT `deliveries_for_deliveries` FOREIGN KEY (`for_delivery_id`) REFERENCES `for_deliveries` (`for_delivery_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_deliveries_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_purchases_ap`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `deliveries_details`
--

DROP TABLE IF EXISTS `deliveries_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `deliveries_details` (
  `delivery_id` int(11) NOT NULL,
  `unit_item_id` int(11) NOT NULL,
  `quantity` double(9,2) NOT NULL DEFAULT 1.00,
  `unit_cost` double(12,2) NOT NULL DEFAULT 1.00,
  `total_cost` double(12,2) GENERATED ALWAYS AS (`quantity` * `unit_cost`) STORED,
  KEY `deliveries_details_deliveries_idx` (`delivery_id`),
  KEY `deliveries_details_inventory_units_items_idx` (`unit_item_id`),
  CONSTRAINT `deliveries_details_deliveries` FOREIGN KEY (`delivery_id`) REFERENCES `deliveries` (`delivery_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `deliveries_details_inventory_units_items` FOREIGN KEY (`unit_item_id`) REFERENCES `inventory`.`inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `for_deliveries`
--

DROP TABLE IF EXISTS `for_deliveries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `for_deliveries` (
  `for_delivery_id` int(11) NOT NULL AUTO_INCREMENT,
  `po_id` int(11) NOT NULL,
  `confirmed` tinyint(4) NOT NULL DEFAULT 0,
  `date_confirmed` datetime DEFAULT NULL,
  `posted_by` int(11) NOT NULL,
  `datetime_posted` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'set value to actual server date and time',
  PRIMARY KEY (`for_delivery_id`),
  KEY `for_deliveries_po_main_idx` (`po_id`),
  KEY `fk_for_deliveries_application_users1_idx` (`posted_by`),
  CONSTRAINT `fk_for_deliveries_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_purchases_ap`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `for_deliveries_po_main` FOREIGN KEY (`po_id`) REFERENCES `po_main` (`po_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `for_deliveries_details`
--

DROP TABLE IF EXISTS `for_deliveries_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `for_deliveries_details` (
  `for_delivery_id` int(11) NOT NULL,
  `unit_item_id` int(11) NOT NULL,
  `quantity` double(9,2) NOT NULL DEFAULT 1.00,
  `unit_cost` double(9,2) NOT NULL DEFAULT 1.00,
  `total_cost` double(12,2) GENERATED ALWAYS AS (`quantity` * `unit_cost`) STORED,
  KEY `for_deliveries_details_for_deliveries_idx` (`for_delivery_id`),
  KEY `fk_for_deliveries_details_inventory_units_items1_idx` (`unit_item_id`),
  CONSTRAINT `fk_deliveries_details_inventory_units_items` FOREIGN KEY (`unit_item_id`) REFERENCES `inventory`.`inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `for_deliveries_details_for_deliveries` FOREIGN KEY (`for_delivery_id`) REFERENCES `for_deliveries` (`for_delivery_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoice_entities_ap`
--

DROP TABLE IF EXISTS `invoice_entities_ap`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoice_entities_ap` (
  `invoice_id` int(11) NOT NULL,
  `payable_id` int(11) NOT NULL,
  KEY `fk_table1_invoices1_idx` (`invoice_id`),
  KEY `fk_table1_entities_payables1_idx` (`payable_id`),
  CONSTRAINT `fk_table1_entities_payables1` FOREIGN KEY (`payable_id`) REFERENCES `account_payables`.`entities_payables` (`payable_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_invoices1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoices`
--

DROP TABLE IF EXISTS `invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices` (
  `invoice_id` int(11) NOT NULL AUTO_INCREMENT,
  `delivery_id` int(11) NOT NULL,
  `invoice_date` datetime NOT NULL DEFAULT current_timestamp(),
  `invoice_reference` varchar(45) NOT NULL,
  `invoice_amount` double(12,2) NOT NULL DEFAULT 1.00 COMMENT 'the amount will be equal to corresponding delivery id record total_amount',
  `cash_payment` tinyint(4) NOT NULL DEFAULT 1,
  `on_term` tinyint(4) NOT NULL DEFAULT 0,
  `term_in_days` int(3) DEFAULT NULL,
  `term_due_date` date DEFAULT NULL,
  `other_payment` tinyint(4) NOT NULL DEFAULT 0,
  `other_payment_mode` int(11) DEFAULT NULL,
  `posted_by` int(11) NOT NULL,
  `date_posted` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'set value to actual server date and time',
  `invoice_balance` double(12,2) NOT NULL DEFAULT 0.00,
  `require_pdc` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'this will only be applicable for invoice set as on_term (a/r) - set either TRUE or FALSE',
  PRIMARY KEY (`invoice_id`),
  KEY `invoices_deliveries_idx` (`delivery_id`),
  KEY `invoices_payment_modes_idx` (`other_payment_mode`),
  KEY `fk_invoices_application_users1_idx` (`posted_by`),
  CONSTRAINT `fk_invoices_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_purchases_ap`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `invoices_deliveries` FOREIGN KEY (`delivery_id`) REFERENCES `deliveries` (`delivery_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `invoices_payment_modes` FOREIGN KEY (`other_payment_mode`) REFERENCES `payment_modes` (`payment_mode_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoices_payment_images`
--

DROP TABLE IF EXISTS `invoices_payment_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices_payment_images` (
  `invoice_id` int(11) NOT NULL,
  `image` mediumblob NOT NULL,
  UNIQUE KEY `invoice_id_UNIQUE` (`invoice_id`),
  CONSTRAINT `invoices_payment_image_invoices` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `invoices_request_vouchers`
--

DROP TABLE IF EXISTS `invoices_request_vouchers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `invoices_request_vouchers` (
  `invoice_id` int(11) NOT NULL,
  `voucher_request_id` int(11) NOT NULL,
  KEY `fk_invoices_request_vouchers_invoices1_idx` (`invoice_id`),
  CONSTRAINT `fk_invoices_request_vouchers_invoices1` FOREIGN KEY (`invoice_id`) REFERENCES `invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `payment_modes`
--

DROP TABLE IF EXISTS `payment_modes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `payment_modes` (
  `payment_mode_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  `require_image` tinyint(4) NOT NULL DEFAULT 0,
  `account_code` int(11) DEFAULT NULL,
  `cheque` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`payment_mode_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `po_details`
--

DROP TABLE IF EXISTS `po_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `po_details` (
  `po_id` int(11) NOT NULL,
  `unit_item_id` int(11) NOT NULL,
  `quantity` double(9,2) NOT NULL DEFAULT 1.00,
  `unit_cost` double(9,2) NOT NULL DEFAULT 1.00,
  `total_cost` double(12,2) GENERATED ALWAYS AS (`quantity` * `unit_cost`) STORED,
  KEY `po_details_po_main_idx` (`po_id`),
  KEY `po_details_inventory_units_items_idx` (`unit_item_id`),
  CONSTRAINT `po_details_inventory_units_items` FOREIGN KEY (`unit_item_id`) REFERENCES `inventory`.`inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `po_details_po_main` FOREIGN KEY (`po_id`) REFERENCES `po_main` (`po_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `po_main`
--

DROP TABLE IF EXISTS `po_main`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `po_main` (
  `po_id` int(11) NOT NULL AUTO_INCREMENT,
  `supplier_id` int(11) NOT NULL,
  `receiving_unit` int(11) NOT NULL,
  `date_requested` datetime NOT NULL DEFAULT current_timestamp(),
  `requested_by` int(11) NOT NULL,
  `datetime_posted` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'set value to actual server time and date',
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`po_id`),
  KEY `fk_po_main_entities1_idx` (`supplier_id`),
  KEY `fk_po_main_units1_idx` (`receiving_unit`),
  KEY `fk_po_main_application_users1_idx` (`requested_by`),
  KEY `fk_po_main_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_po_main_application_users1` FOREIGN KEY (`requested_by`) REFERENCES `application_users_purchases_ap`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_po_main_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_purchases_ap`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_po_main_entities1` FOREIGN KEY (`supplier_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_po_main_units1` FOREIGN KEY (`receiving_unit`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary table structure for view `suppliers`
--

DROP TABLE IF EXISTS `suppliers`;
/*!50001 DROP VIEW IF EXISTS `suppliers`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `suppliers` AS SELECT
 1 AS `entity_id`,
  1 AS `supplier` */;
SET character_set_client = @saved_cs_client;

--
-- Current Database: `purchases_ap`
--

USE `purchases_ap`;

--
-- Final view structure for view `suppliers`
--

/*!50001 DROP VIEW IF EXISTS `suppliers`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `suppliers` AS select concat(1,`a`.`person_id`) AS `entity_id`,concat(`a`.`lastname`,', ',`a`.`firstname`,' ',`a`.`middlename`) AS `supplier` from `entities`.`persons` `a` union all select concat(2,`b`.`nonperson_id`) AS `entity_id`,`b`.`nonperson_name` AS `supplier` from `entities`.`non_persons` `b` order by `supplier` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: point_of_sales_ar
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `point_of_sales_ar`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `point_of_sales_ar` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `point_of_sales_ar`;

--
-- Table structure for table `ar_params`
--

DROP TABLE IF EXISTS `ar_params`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_params` (
  `ar_account` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ar_payments`
--

DROP TABLE IF EXISTS `ar_payments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ar_payments` (
  `payment_id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  `payment_reference` varchar(45) NOT NULL COMMENT 'the value for this field must be unique for each corresponding invoice_id',
  `payment_date` datetime NOT NULL DEFAULT current_timestamp(),
  `amount_paid` double(12,2) NOT NULL DEFAULT 1.00,
  `collection_type_id` int(11) NOT NULL,
  `posted_by` int(11) NOT NULL,
  `datetime_posted` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'set field value to server date and time',
  PRIMARY KEY (`payment_id`),
  UNIQUE KEY `ar_payments_uniq_invoice_id_and_payment_reference` (`invoice_id`,`payment_reference`),
  UNIQUE KEY `payment_reference_UNIQUE` (`payment_reference`),
  KEY `ar_payments_pos_invoices_idx` (`invoice_id`),
  KEY `fk_ar_payments_application_users1_idx` (`posted_by`),
  KEY `fk_ar_payments_entities1_idx` (`entity_id`),
  CONSTRAINT `ar_payments_pos_invoices` FOREIGN KEY (`invoice_id`) REFERENCES `pos_invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_ar_payments_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_point_of_sales_ar`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_ar_payments_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `entities_term`
--

DROP TABLE IF EXISTS `entities_term`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `entities_term` (
  `entity_id` int(11) NOT NULL,
  `term_in_days` int(11) NOT NULL DEFAULT 30,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  UNIQUE KEY `entity_id_UNIQUE` (`entity_id`),
  KEY `fk_entities_term_entities1_idx` (`entity_id`),
  KEY `fk_entities_term_application_users3_idx` (`created_by`),
  KEY `fk_entities_term_application_users1_idx` (`modified_by`),
  CONSTRAINT `fk_entities_term_application_users1` FOREIGN KEY (`modified_by`) REFERENCES `application_users_point_of_sales_ar`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_entities_term_application_users3` FOREIGN KEY (`created_by`) REFERENCES `application_users_point_of_sales_ar`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_entities_term_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf32 COLLATE=utf32_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `images_ar_payment`
--

DROP TABLE IF EXISTS `images_ar_payment`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images_ar_payment` (
  `payment_id` int(11) NOT NULL,
  `image` mediumblob NOT NULL,
  PRIMARY KEY (`payment_id`),
  CONSTRAINT `images_ar_payment_ar_payments` FOREIGN KEY (`payment_id`) REFERENCES `ar_payments` (`payment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `images_pos_invoice`
--

DROP TABLE IF EXISTS `images_pos_invoice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `images_pos_invoice` (
  `invoice_id` int(11) NOT NULL,
  `image` mediumblob NOT NULL,
  PRIMARY KEY (`invoice_id`),
  CONSTRAINT `images_pos_invoice_pos_invoices` FOREIGN KEY (`invoice_id`) REFERENCES `pos_invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory_item_sales`
--

DROP TABLE IF EXISTS `inventory_item_sales`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_item_sales` (
  `invoice_id` int(11) NOT NULL,
  `unit_item_id` int(11) DEFAULT NULL,
  `quantity` double(9,2) NOT NULL DEFAULT 1.00,
  `unit_sales_price` double(9,2) NOT NULL DEFAULT 1.00,
  `total_unit_sales` double(12,2) GENERATED ALWAYS AS (`quantity` * `unit_sales_price`) STORED,
  `batch_id` int(11) DEFAULT NULL,
  KEY `inventory_item_sales_inventory_units_items_idx` (`unit_item_id`),
  KEY `fk_inventory_item_sales_inventory_batch_tracking1_idx` (`batch_id`),
  KEY `inventory_item_sales_pos_invoices` (`invoice_id`),
  CONSTRAINT `fk_inventory_item_sales_inventory_batch_tracking1` FOREIGN KEY (`batch_id`) REFERENCES `inventory`.`inventory_batch_tracking` (`batch_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `inventory_item_sales_inventory_units_items` FOREIGN KEY (`unit_item_id`) REFERENCES `inventory`.`inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `inventory_item_sales_pos_invoices` FOREIGN KEY (`invoice_id`) REFERENCES `pos_invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory_items_job_order`
--

DROP TABLE IF EXISTS `inventory_items_job_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_items_job_order` (
  `job_order_id` int(11) NOT NULL,
  `unit_item_id` int(11) NOT NULL,
  `quantity` double(9,2) NOT NULL DEFAULT 1.00,
  `unit_sales_price` double(9,2) NOT NULL DEFAULT 1.00,
  `total_unit_sales` double(12,2) GENERATED ALWAYS AS (`quantity` * `unit_sales_price`) STORED,
  `entry_date` datetime NOT NULL DEFAULT current_timestamp(),
  `posted_by` int(11) NOT NULL,
  `batch_id` int(11) DEFAULT NULL,
  KEY `inventory_items_job_order_job_orders_idx` (`job_order_id`),
  KEY `fk_inventory_items_job_order_inventory_units_items1_idx` (`unit_item_id`),
  KEY `fk_inventory_items_job_order_inventory_batch_tracking1_idx` (`batch_id`),
  KEY `fk_inventory_items_job_order_application_users1_idx` (`posted_by`),
  CONSTRAINT `fk_inventory_items_job_order_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_point_of_sales_ar`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_items_job_order_inventory_batch_tracking1` FOREIGN KEY (`batch_id`) REFERENCES `inventory`.`inventory_batch_tracking` (`batch_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `inventory_items_job_order_inventory_units_items` FOREIGN KEY (`unit_item_id`) REFERENCES `inventory`.`inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `inventory_items_job_order_job_orders` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`job_order_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_order_employees`
--

DROP TABLE IF EXISTS `job_order_employees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_order_employees` (
  `job_order_id` int(11) NOT NULL,
  `employees_employee_id` int(11) NOT NULL,
  KEY `fk_job_order_employees_job_orders1_idx` (`job_order_id`),
  KEY `fk_job_order_employees_employees1_idx` (`employees_employee_id`),
  CONSTRAINT `fk_job_order_employees_employees1` FOREIGN KEY (`employees_employee_id`) REFERENCES `employees_profile`.`employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_job_order_employees_job_orders1` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`job_order_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_order_voucher`
--

DROP TABLE IF EXISTS `job_order_voucher`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_order_voucher` (
  `job_order_id` int(11) NOT NULL,
  `request_id` int(11) NOT NULL,
  KEY `fk_job_order_voucher_job_orders1_idx` (`job_order_id`),
  KEY `fk_job_order_voucher_request_vouchers1_idx` (`request_id`),
  CONSTRAINT `fk_job_order_voucher_job_orders1` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`job_order_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_job_order_voucher_request_vouchers1` FOREIGN KEY (`request_id`) REFERENCES `vouchers`.`request_vouchers` (`request_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `job_orders`
--

DROP TABLE IF EXISTS `job_orders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_orders` (
  `job_order_id` int(11) NOT NULL AUTO_INCREMENT,
  `entity_id` int(11) NOT NULL,
  `job_order_reference` varchar(45) NOT NULL,
  `description` text NOT NULL,
  `plate_number` char(10) DEFAULT NULL,
  `odometer` int(11) DEFAULT NULL,
  `start_date` datetime NOT NULL DEFAULT current_timestamp(),
  `job_order_closed` tinyint(4) NOT NULL DEFAULT 0,
  `date_closed` datetime DEFAULT NULL,
  `posted_by` int(11) NOT NULL,
  `datetime_posted` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'set value from server date and time when posted',
  `invoice_id` int(11) DEFAULT NULL,
  `mod_unit_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`job_order_id`),
  KEY `job_orders_pos_invoices_idx` (`invoice_id`),
  KEY `fk_job_orders_application_users1_idx` (`posted_by`),
  KEY `fk_job_orders_entities1_idx` (`entity_id`),
  KEY `fk_job_orders_inventory_units1_idx` (`mod_unit_id`),
  CONSTRAINT `fk_job_orders_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_point_of_sales_ar`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_job_orders_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_job_orders_inventory_units1` FOREIGN KEY (`mod_unit_id`) REFERENCES `inventory`.`inventory_units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `job_orders_pos_invoices` FOREIGN KEY (`invoice_id`) REFERENCES `pos_invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_invoices`
--

DROP TABLE IF EXISTS `pos_invoices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pos_invoices` (
  `invoice_id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_reference` varchar(45) DEFAULT NULL,
  `invoice_date` datetime NOT NULL DEFAULT current_timestamp(),
  `walk_in` tinyint(4) NOT NULL DEFAULT 0,
  `walk_in_name` char(80) DEFAULT NULL COMMENT 'default value if walk_in is TRUE : ''WALK-IN''',
  `entity_id` int(11) DEFAULT NULL,
  `pick_up` tinyint(4) NOT NULL DEFAULT 0,
  `pickup_unit_id` int(11) DEFAULT NULL,
  `total_amount` double(12,2) NOT NULL DEFAULT 1.00,
  `discount` double(9,2) NOT NULL DEFAULT 0.00,
  `net_amount_due` double(12,2) GENERATED ALWAYS AS (`total_amount` - `discount`) STORED,
  `on_term` tinyint(4) NOT NULL DEFAULT 0 COMMENT 'if on_term set to 1 set fields:\\nterm_in_days > 0\\ninvoice_running_balance = net_amount_due',
  `collection_type_id` int(11) DEFAULT NULL,
  `term_in_days` int(11) DEFAULT NULL,
  `ar_due_date` date DEFAULT NULL,
  `invoice_running_balance` double(12,2) NOT NULL DEFAULT 1.00,
  `posted_by` int(11) NOT NULL,
  `datetime_posted` datetime NOT NULL DEFAULT current_timestamp(),
  `cashier_pending` tinyint(4) NOT NULL DEFAULT 0,
  `tender_amount` double(12,2) NOT NULL DEFAULT 0.00,
  `require_pdc` tinyint(4) NOT NULL DEFAULT 0,
  `vat_amount` decimal(12,2) DEFAULT 0.00,
  PRIMARY KEY (`invoice_id`),
  UNIQUE KEY `invoice_reference_UNIQUE` (`invoice_reference`),
  KEY `fk_pos_invoices_entities1_idx` (`entity_id`),
  KEY `fk_pos_invoices_application_users1_idx` (`posted_by`),
  KEY `fk_pos_invoices_units1_idx` (`pickup_unit_id`),
  CONSTRAINT `fk_pos_invoices_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_point_of_sales_ar`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_pos_invoices_entities1` FOREIGN KEY (`entity_id`) REFERENCES `entities`.`entities` (`entity_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_pos_invoices_units1` FOREIGN KEY (`pickup_unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pos_invoices_collections`
--

DROP TABLE IF EXISTS `pos_invoices_collections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pos_invoices_collections` (
  `collections_entry_id` int(11) NOT NULL,
  `pos_invoices_invoice_id` int(11) NOT NULL,
  KEY `fk_table1_collections1_idx` (`collections_entry_id`),
  KEY `fk_table1_pos_invoices1_idx` (`pos_invoices_invoice_id`),
  CONSTRAINT `fk_table1_collections1` FOREIGN KEY (`collections_entry_id`) REFERENCES `funds`.`collections` (`entry_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_pos_invoices1` FOREIGN KEY (`pos_invoices_invoice_id`) REFERENCES `pos_invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `project_payroll_history`
--

DROP TABLE IF EXISTS `project_payroll_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `project_payroll_history` (
  `job_orders_job_order_id` int(11) NOT NULL,
  `employees_employee_id` int(11) NOT NULL,
  `payroll_period_id` int(11) NOT NULL,
  KEY `fk_table1_job_orders_idx` (`job_orders_job_order_id`),
  KEY `fk_table1_employees1_idx` (`employees_employee_id`),
  KEY `fk_table1_payroll_period1_idx` (`payroll_period_id`),
  CONSTRAINT `fk_table1_employees1` FOREIGN KEY (`employees_employee_id`) REFERENCES `employees_profile`.`employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_job_orders` FOREIGN KEY (`job_orders_job_order_id`) REFERENCES `job_orders` (`job_order_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_payroll_period1` FOREIGN KEY (`payroll_period_id`) REFERENCES `payroll`.`payroll_period` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `purchase_job_order_invoice`
--

DROP TABLE IF EXISTS `purchase_job_order_invoice`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `purchase_job_order_invoice` (
  `job_order_id` int(11) NOT NULL,
  `invoice_id` int(11) NOT NULL,
  KEY `fk_purchase_job_order_invoice_job_orders1_idx` (`job_order_id`),
  KEY `fk_purchase_job_order_invoice_invoices1_idx` (`invoice_id`),
  CONSTRAINT `fk_purchase_job_order_invoice_invoices1` FOREIGN KEY (`invoice_id`) REFERENCES `purchases_ap`.`invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_purchase_job_order_invoice_job_orders1` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`job_order_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `returned_empty_cases`
--

DROP TABLE IF EXISTS `returned_empty_cases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `returned_empty_cases` (
  `invoice_id` int(11) NOT NULL,
  `unit_item_id` int(11) NOT NULL,
  `quantity_returned` double(9,2) NOT NULL DEFAULT 0.00,
  `quantity_unreturned` double(9,2) NOT NULL DEFAULT 0.00,
  KEY `fk_table1_pos_invoices2_idx` (`invoice_id`),
  KEY `fk_returned_empty_cases_inventory_units_items1_idx` (`unit_item_id`),
  CONSTRAINT `fk_returned_empty_cases_inventory_units_items1` FOREIGN KEY (`unit_item_id`) REFERENCES `inventory`.`inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_pos_invoices2` FOREIGN KEY (`invoice_id`) REFERENCES `pos_invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services`
--

DROP TABLE IF EXISTS `services`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services` (
  `service_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` char(80) NOT NULL,
  `service_cost` double(12,2) NOT NULL DEFAULT 1.00,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`service_id`),
  KEY `fk_services_application_users1_idx` (`created_by`),
  KEY `fk_services_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_services_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_point_of_sales_ar`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_services_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_point_of_sales_ar`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services_glsl_item`
--

DROP TABLE IF EXISTS `services_glsl_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services_glsl_item` (
  `service_id` int(11) NOT NULL,
  `glsl_item` int(11) NOT NULL,
  KEY `fk_services_glsl_item_services1_idx` (`service_id`),
  CONSTRAINT `fk_services_glsl_item_services1` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `services_job_order`
--

DROP TABLE IF EXISTS `services_job_order`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `services_job_order` (
  `job_order_id` int(11) NOT NULL,
  `service_id` int(11) NOT NULL,
  `service_cost` double(12,2) NOT NULL DEFAULT 1.00,
  KEY `services_job_order_job_orders_idx` (`job_order_id`),
  KEY `fk_services_job_order_services1_idx` (`service_id`),
  CONSTRAINT `services_job_order_job_orders` FOREIGN KEY (`job_order_id`) REFERENCES `job_orders` (`job_order_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `services_job_order_services` FOREIGN KEY (`service_id`) REFERENCES `services` (`service_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: point_of_sales_ar_udf_and_views
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `point_of_sales_ar_udf_and_views`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `point_of_sales_ar_udf_and_views` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `point_of_sales_ar_udf_and_views`;

--
-- Temporary table structure for view `jsn_jo_items`
--

DROP TABLE IF EXISTS `jsn_jo_items`;
/*!50001 DROP VIEW IF EXISTS `jsn_jo_items`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `jsn_jo_items` AS SELECT
 1 AS `total_item_cost`,
  1 AS `job_order_id`,
  1 AS `jsn_jo_items` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `jsn_jo_services`
--

DROP TABLE IF EXISTS `jsn_jo_services`;
/*!50001 DROP VIEW IF EXISTS `jsn_jo_services`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `jsn_jo_services` AS SELECT
 1 AS `total_service_cost`,
  1 AS `job_order_id`,
  1 AS `jsn_jo_services` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `jsn_sales_items`
--

DROP TABLE IF EXISTS `jsn_sales_items`;
/*!50001 DROP VIEW IF EXISTS `jsn_sales_items`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `jsn_sales_items` AS SELECT
 1 AS `invoice_id`,
  1 AS `jsn_sales_items` */;
SET character_set_client = @saved_cs_client;

--
-- Current Database: `point_of_sales_ar_udf_and_views`
--

USE `point_of_sales_ar_udf_and_views`;

--
-- Final view structure for view `jsn_jo_items`
--

/*!50001 DROP VIEW IF EXISTS `jsn_jo_items`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `jsn_jo_items` AS select sum(`iijo`.`total_unit_sales`) AS `total_item_cost`,`iijo`.`job_order_id` AS `job_order_id`,json_arrayagg(json_object('unit_item_id',`iijo`.`unit_item_id`,'item_description',`iic`.`item_description`,'date_manufactured',`ibt`.`date_manufactured`,'batch_id',`ibt`.`batch_id`,'quantity',`iijo`.`quantity`,'unit',if(coalesce(`iu`.`warehouse`,0),`ii`.`stocking_unit`,`ii`.`retail_unit`),'max_quantity',`iui`.`ending_quantity`,'frmt_quantity',format(`iijo`.`quantity`,2),'unit_sales_price',`iijo`.`unit_sales_price`,'frmt_unit_sales_price',format(`iijo`.`unit_sales_price`,2),'total_unit_sales',`iijo`.`total_unit_sales`,'frmt_total_unit_sales',format(`iijo`.`total_unit_sales`,2),'entry_date',`iijo`.`entry_date`,'frmt_entry_date',date_format(`iijo`.`entry_date`,'%Y %b %d %a'),'posted_by',`iijo`.`posted_by`)) AS `jsn_jo_items` from (((((`point_of_sales_ar`.`inventory_items_job_order` `iijo` join `inventory`.`inventory_units_items` `iui` on(`iijo`.`unit_item_id` = `iui`.`unit_item_id`)) join `inventory_udf_and_views`.`inventory_item_concat` `iic` on(`iui`.`item_id` = `iic`.`item_id`)) join `inventory`.`inventory_items` `ii` on(`iui`.`item_id` = `ii`.`item_id`)) join `inventory`.`inventory_units` `iu` on(`iui`.`unit_id` = `iu`.`unit_id`)) left join `inventory`.`inventory_batch_tracking` `ibt` on(`iijo`.`unit_item_id` = `ibt`.`unit_item_id` and `iijo`.`batch_id` = `ibt`.`batch_id`)) group by `iijo`.`job_order_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `jsn_jo_services`
--

/*!50001 DROP VIEW IF EXISTS `jsn_jo_services`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `jsn_jo_services` AS select sum(`sjo`.`service_cost`) AS `total_service_cost`,`sjo`.`job_order_id` AS `job_order_id`,json_arrayagg(json_object('service_id',`sjo`.`service_id`,'service',`s`.`description`,'service_cost',`sjo`.`service_cost`,'frmt_service_cost',format(`sjo`.`service_cost`,2))) AS `jsn_jo_services` from (`point_of_sales_ar`.`services_job_order` `sjo` join `point_of_sales_ar`.`services` `s` on(`sjo`.`service_id` = `s`.`service_id`)) group by `sjo`.`job_order_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `jsn_sales_items`
--

/*!50001 DROP VIEW IF EXISTS `jsn_sales_items`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `jsn_sales_items` AS select `iis`.`invoice_id` AS `invoice_id`,json_arrayagg(json_object('unit_item_id',`iis`.`unit_item_id`,'item_name',`ii`.`model_description`,'item_description',`iic`.`item_description`,'date_manufactured',`ibt`.`date_manufactured`,'batch_id',`ibt`.`batch_id`,'quantity',`iis`.`quantity`,'unit',if(coalesce(`iu`.`warehouse`,0),`ii`.`stocking_unit`,`ii`.`retail_unit`),'max_quantity',`iui`.`ending_quantity`,'frmt_quantity',format(`iis`.`quantity`,2),'unit_sales_price',`iis`.`unit_sales_price`,'frmt_unit_sales_price',format(`iis`.`unit_sales_price`,2),'total_unit_sales',`iis`.`total_unit_sales`,'frmt_total_unit_sales',format(`iis`.`total_unit_sales`,2),'returned_case',coalesce(`rec`.`quantity_returned`,0),'is_empty_case',case when `iec2`.`main_item_id` = `ii`.`item_id` or `iec`.`empty_item_id` = `ii`.`item_id` then 1 else 0 end)) AS `jsn_sales_items` from ((((((((`point_of_sales_ar`.`inventory_item_sales` `iis` join `inventory`.`inventory_units_items` `iui` on(`iis`.`unit_item_id` = `iui`.`unit_item_id`)) join `inventory_udf_and_views`.`inventory_item_concat` `iic` on(`iui`.`item_id` = `iic`.`item_id`)) join `inventory`.`inventory_items` `ii` on(`iui`.`item_id` = `ii`.`item_id`)) join `inventory`.`inventory_units` `iu` on(`iui`.`unit_id` = `iu`.`unit_id`)) left join (select `inventory`.`inventory_batch_tracking`.`unit_item_id` AS `unit_item_id`,`inventory`.`inventory_batch_tracking`.`batch_id` AS `batch_id`,max(`inventory`.`inventory_batch_tracking`.`date_manufactured`) AS `date_manufactured` from `inventory`.`inventory_batch_tracking` group by `inventory`.`inventory_batch_tracking`.`unit_item_id`,`inventory`.`inventory_batch_tracking`.`batch_id`) `ibt` on(`iis`.`unit_item_id` = `ibt`.`unit_item_id` and `iis`.`batch_id` = `ibt`.`batch_id`)) left join (select distinct `inventory`.`inventory_empty_cases`.`empty_item_id` AS `empty_item_id` from `inventory`.`inventory_empty_cases`) `iec` on(`iec`.`empty_item_id` = `iic`.`item_id`)) left join (select distinct `inventory`.`inventory_empty_cases`.`main_item_id` AS `main_item_id` from `inventory`.`inventory_empty_cases`) `iec2` on(`iec2`.`main_item_id` = `ii`.`item_id`)) left join (select `point_of_sales_ar`.`returned_empty_cases`.`invoice_id` AS `invoice_id`,`point_of_sales_ar`.`returned_empty_cases`.`unit_item_id` AS `unit_item_id`,sum(`point_of_sales_ar`.`returned_empty_cases`.`quantity_returned`) AS `quantity_returned` from `point_of_sales_ar`.`returned_empty_cases` group by `point_of_sales_ar`.`returned_empty_cases`.`invoice_id`,`point_of_sales_ar`.`returned_empty_cases`.`unit_item_id`) `rec` on(`rec`.`invoice_id` = `iis`.`invoice_id` and `rec`.`unit_item_id` = `iis`.`unit_item_id`)) group by `iis`.`invoice_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: inventory
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `inventory`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `inventory` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;

USE `inventory`;

--
-- Table structure for table `brands`
--

DROP TABLE IF EXISTS `brands`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `brands` (
  `brand_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) DEFAULT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`brand_id`),
  UNIQUE KEY `brand_name_UNIQUE` (`description`),
  KEY `fk_brands_application_users1_idx` (`created_by`),
  KEY `fk_brands_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_brands_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_brands_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `confirmed_transit_items`
--

DROP TABLE IF EXISTS `confirmed_transit_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `confirmed_transit_items` (
  `confirmed_transit_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_transit_id` int(11) NOT NULL,
  `quantity_confirmed` double(9,2) NOT NULL DEFAULT 1.00,
  `confirmed_by` int(11) NOT NULL,
  `datetime_confirmed` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`confirmed_transit_id`),
  KEY `fk_confirmed_transit_items_in_transit_items1_idx` (`item_transit_id`),
  KEY `fk_confirmed_transit_items_application_users1_idx` (`confirmed_by`),
  CONSTRAINT `fk_confirmed_transit_items_application_users1` FOREIGN KEY (`confirmed_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_confirmed_transit_items_in_transit_items1` FOREIGN KEY (`item_transit_id`) REFERENCES `in_transit_items` (`item_transit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `in_transit_items`
--

DROP TABLE IF EXISTS `in_transit_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `in_transit_items` (
  `item_transit_id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` int(11) NOT NULL,
  `adjustment_id` int(11) NOT NULL,
  `unit_item_id` int(11) NOT NULL,
  `quantity` double(9,2) NOT NULL,
  `running_quantity` double(9,2) NOT NULL,
  `posted_by` int(11) NOT NULL,
  `datetime_posted` datetime NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`item_transit_id`),
  KEY `fk_in_transit_items_inventory_units_items1_idx` (`unit_item_id`),
  KEY `fk_in_transit_items_application_users1_idx` (`posted_by`),
  KEY `fk_in_transit_items_items_adjustments1_idx` (`adjustment_id`),
  KEY `fk_in_transit_items_pos_invoices1_idx` (`invoice_id`),
  CONSTRAINT `fk_in_transit_items_application_users1` FOREIGN KEY (`posted_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_in_transit_items_inventory_units_items1` FOREIGN KEY (`unit_item_id`) REFERENCES `inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_in_transit_items_items_adjustments1` FOREIGN KEY (`adjustment_id`) REFERENCES `items_adjustments` (`adjustment_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_in_transit_items_pos_invoices1` FOREIGN KEY (`invoice_id`) REFERENCES `point_of_sales_ar`.`pos_invoices` (`invoice_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory_batch_tracking`
--

DROP TABLE IF EXISTS `inventory_batch_tracking`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_batch_tracking` (
  `batch_id` int(11) NOT NULL AUTO_INCREMENT COMMENT 'entry will be created for each inventory item adjustments (when applicable) and during deliveries (when applicable)',
  `delivery_id` int(11) NOT NULL COMMENT 'field value will remain the same even when transferred to another units',
  `unit_item_id` int(11) NOT NULL,
  `date_manufactured` date NOT NULL COMMENT 'set day to 1 and values for year and month remains the same even when transferred to another units',
  `quantity_beg` int(11) NOT NULL DEFAULT 1 COMMENT 'quantity_beg  field value:\\n	quantity upon delivery\\n	quantity upon receiving from another units\\nquantity_out field value (cumulative):\\n	quantity transferred to another unit\\n	quantity adjusted for own unit\\n	quantity sold\\n	',
  `quantity_out` int(11) NOT NULL,
  `quantity_end` int(11) GENERATED ALWAYS AS (`quantity_beg` - `quantity_out`) VIRTUAL,
  PRIMARY KEY (`batch_id`),
  KEY `fk_table1_deliveries1_idx` (`delivery_id`),
  KEY `fk_table1_inventory_units_items1_idx` (`unit_item_id`),
  CONSTRAINT `fk_table1_deliveries1` FOREIGN KEY (`delivery_id`) REFERENCES `purchases_ap`.`deliveries` (`delivery_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_table1_inventory_units_items1` FOREIGN KEY (`unit_item_id`) REFERENCES `inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory_empty_cases`
--

DROP TABLE IF EXISTS `inventory_empty_cases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_empty_cases` (
  `main_item_id` int(11) NOT NULL,
  `empty_item_id` int(11) NOT NULL,
  KEY `fk_inventory_empty_cases_inventory_items1_idx` (`main_item_id`),
  KEY `fk_inventory_empty_cases_inventory_items2_idx` (`empty_item_id`),
  CONSTRAINT `fk_inventory_empty_cases_inventory_items1` FOREIGN KEY (`main_item_id`) REFERENCES `inventory_items` (`item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_empty_cases_inventory_items2` FOREIGN KEY (`empty_item_id`) REFERENCES `inventory_items` (`item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory_item_barcodes`
--

DROP TABLE IF EXISTS `inventory_item_barcodes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_item_barcodes` (
  `barcode_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `barcode_value` varchar(100) NOT NULL,
  `barcode_type` varchar(20) DEFAULT 'INTERNAL',
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime DEFAULT current_timestamp(),
  PRIMARY KEY (`barcode_id`),
  KEY `item_id_idx` (`item_id`),
  CONSTRAINT `fk_barcode_item` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`item_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory_items`
--

DROP TABLE IF EXISTS `inventory_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_items` (
  `item_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_category_id` int(11) NOT NULL,
  `brand_id` int(11) DEFAULT NULL,
  `model_description` varchar(60) DEFAULT NULL,
  `part_id` int(11) DEFAULT NULL,
  `part_number_id` int(11) DEFAULT NULL,
  `size_id` int(11) DEFAULT NULL,
  `valve_id` int(11) DEFAULT NULL,
  `ratio_id` int(11) DEFAULT NULL,
  `pattern_id` int(11) DEFAULT NULL,
  `stocking_unit` varchar(20) NOT NULL,
  `retail_unit` varchar(20) NOT NULL,
  `rtu_over_stu` double(10,2) NOT NULL DEFAULT 1.00,
  `wtd_ave_cost` double(12,2) NOT NULL DEFAULT 0.00,
  `markup_rate` double(6,2) NOT NULL DEFAULT 0.00,
  `selling_price` double(9,2) NOT NULL DEFAULT 0.00,
  `last_highest_in_unit_cost` double(9,2) NOT NULL DEFAULT 0.00,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  `include_vat` tinyint(1) DEFAULT 0,
  PRIMARY KEY (`item_id`),
  KEY `fk_inventory_items_items_categories1_idx` (`item_category_id`),
  KEY `fk_inventory_items_brands1_idx` (`brand_id`),
  KEY `fk_inventory_items_sizes1_idx` (`size_id`),
  KEY `fk_inventory_items_ratios1_idx` (`ratio_id`),
  KEY `fk_inventory_items_thread_patterns1_idx` (`pattern_id`),
  KEY `fk_inventory_items_valve_types1_idx` (`valve_id`),
  KEY `fk_inventory_items_vehicle_parts1_idx` (`part_id`),
  KEY `items_to_vehicle_part_numbers_idx` (`part_number_id`),
  KEY `fk_inventory_items_application_users1_idx` (`created_by`),
  KEY `fk_inventory_items_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_inventory_items_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_items_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `items_to_brands` FOREIGN KEY (`brand_id`) REFERENCES `brands` (`brand_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `items_to_categories` FOREIGN KEY (`item_category_id`) REFERENCES `items_categories` (`item_category_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `items_to_ratios` FOREIGN KEY (`ratio_id`) REFERENCES `ratios` (`ratio_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `items_to_sizes` FOREIGN KEY (`size_id`) REFERENCES `sizes` (`size_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `items_to_thread_patterns` FOREIGN KEY (`pattern_id`) REFERENCES `thread_patterns` (`pattern_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `items_to_valve_types` FOREIGN KEY (`valve_id`) REFERENCES `valve_types` (`valve_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `items_to_vehicle_part_numbers` FOREIGN KEY (`part_number_id`) REFERENCES `vehicle_part_numbers` (`part_number_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `items_to_vehicle_parts` FOREIGN KEY (`part_id`) REFERENCES `vehicle_parts` (`part_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory_units`
--

DROP TABLE IF EXISTS `inventory_units`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_units` (
  `unit_id` int(11) NOT NULL,
  `warehouse` tinyint(4) NOT NULL DEFAULT 0,
  `person_in_charge` int(11) DEFAULT NULL,
  `person_name` varchar(100) DEFAULT NULL,
  PRIMARY KEY (`unit_id`),
  KEY `fk_inventory_units_employees1_idx` (`person_in_charge`),
  CONSTRAINT `fk_inventory_units_employees1` FOREIGN KEY (`person_in_charge`) REFERENCES `employees_profile`.`employees` (`employee_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `inventory_units_items`
--

DROP TABLE IF EXISTS `inventory_units_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `inventory_units_items` (
  `unit_item_id` int(11) NOT NULL AUTO_INCREMENT,
  `item_id` int(11) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `starting_period` datetime NOT NULL,
  `last_entry` datetime NOT NULL,
  `starting_quantity` double(9,2) NOT NULL DEFAULT 0.00,
  `quantity_in` double(9,2) NOT NULL DEFAULT 0.00,
  `quantity_out` double(9,2) NOT NULL DEFAULT 0.00,
  `float_quantity` double(9,2) NOT NULL DEFAULT 0.00,
  `ending_quantity` double(9,2) NOT NULL DEFAULT 0.00,
  `starting_cost` double(12,2) NOT NULL DEFAULT 0.00,
  `cost_in` double(12,2) NOT NULL DEFAULT 0.00,
  `cost_out` double(12,2) NOT NULL DEFAULT 0.00,
  `float_cost` double(12,2) NOT NULL DEFAULT 0.00,
  `ending_cost` double(12,2) NOT NULL DEFAULT 0.00,
  `unit_cost` double(9,2) NOT NULL DEFAULT 0.00,
  `last_highest_in_unit_cost` double(9,2) NOT NULL DEFAULT 0.00,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  `bin_id` int(11) NOT NULL,
  PRIMARY KEY (`unit_item_id`),
  KEY `fk_inventory_units_items_inventory_items1_idx` (`item_id`),
  KEY `fk_inventory_units_items_unit_bins1_idx` (`bin_id`),
  KEY `fk_inventory_units_items_units1_idx` (`unit_id`),
  KEY `fk_inventory_units_items_application_users1_idx` (`created_by`),
  KEY `fk_inventory_units_items_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_inventory_units_items_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_units_items_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_units_items_unit_bins1` FOREIGN KEY (`bin_id`) REFERENCES `unit_bins` (`bin_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_inventory_units_items_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `units_items_to_inventory_items` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_category_glsl_item`
--

DROP TABLE IF EXISTS `item_category_glsl_item`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_category_glsl_item` (
  `item_category_id` int(11) NOT NULL,
  `glsl_item` int(11) NOT NULL,
  KEY `fk_item_category_glsl_item_items_categories1_idx` (`item_category_id`),
  CONSTRAINT `fk_item_category_glsl_item_items_categories1` FOREIGN KEY (`item_category_id`) REFERENCES `items_categories` (`item_category_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `item_images`
--

DROP TABLE IF EXISTS `item_images`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `item_images` (
  `item_id` int(11) NOT NULL,
  `image` longblob NOT NULL,
  PRIMARY KEY (`item_id`),
  CONSTRAINT `item_images_ibfk_1` FOREIGN KEY (`item_id`) REFERENCES `inventory_items` (`item_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items_adjustments`
--

DROP TABLE IF EXISTS `items_adjustments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items_adjustments` (
  `adjustment_id` int(11) NOT NULL AUTO_INCREMENT,
  `adjustment_date` datetime NOT NULL,
  `template_id` int(11) NOT NULL,
  `destination_id` int(11) DEFAULT NULL,
  `source_id` int(11) DEFAULT NULL,
  `item_id` int(11) NOT NULL,
  `quantity` double(9,2) NOT NULL DEFAULT 0.00,
  `unit_cost` double(9,2) NOT NULL DEFAULT 0.00,
  `remarks` char(250) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `batch_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`adjustment_id`),
  KEY `fk_inventory_items_adjustments_items_adjustments_templates1_idx` (`template_id`),
  KEY `adjustments_to_inventory_units_items_source_idx` (`source_id`),
  KEY `adjustments_to_inventory_units_items_destination_idx` (`destination_id`),
  KEY `fk_items_adjustments_inventory_batch_tracking1_idx` (`batch_id`),
  KEY `fk_items_adjustments_application_users1_idx` (`created_by`),
  CONSTRAINT `adjustments_to_adjustments_templates` FOREIGN KEY (`template_id`) REFERENCES `items_adjustments_templates` (`template_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `adjustments_to_inventory_units_items_destination` FOREIGN KEY (`destination_id`) REFERENCES `inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `adjustments_to_inventory_units_items_source` FOREIGN KEY (`source_id`) REFERENCES `inventory_units_items` (`unit_item_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_items_adjustments_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_items_adjustments_inventory_batch_tracking1` FOREIGN KEY (`batch_id`) REFERENCES `inventory_batch_tracking` (`batch_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items_adjustments_templates`
--

DROP TABLE IF EXISTS `items_adjustments_templates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items_adjustments_templates` (
  `template_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) DEFAULT NULL,
  `add_to_quantity` tinyint(4) NOT NULL DEFAULT 0,
  `require_destination_and_source` tinyint(4) NOT NULL DEFAULT 0,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`template_id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_items_adjustments_templates_application_users1_idx` (`created_by`),
  KEY `fk_items_adjustments_templates_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_items_adjustments_templates_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_items_adjustments_templates_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `items_categories`
--

DROP TABLE IF EXISTS `items_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `items_categories` (
  `item_category_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(150) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  `predefined` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`item_category_id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_items_categories_application_users1_idx` (`created_by`),
  KEY `fk_items_categories_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_items_categories_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_items_categories_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ratios`
--

DROP TABLE IF EXISTS `ratios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ratios` (
  `ratio_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`ratio_id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_ratios_application_users1_idx` (`created_by`),
  KEY `fk_ratios_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_ratios_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_ratios_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sizes`
--

DROP TABLE IF EXISTS `sizes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sizes` (
  `size_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`size_id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_sizes_application_users1_idx` (`created_by`),
  KEY `fk_sizes_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_sizes_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_sizes_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `thread_patterns`
--

DROP TABLE IF EXISTS `thread_patterns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `thread_patterns` (
  `pattern_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`pattern_id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_thread_patterns_application_users1_idx` (`created_by`),
  KEY `fk_thread_patterns_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_thread_patterns_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_thread_patterns_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `unit_bins`
--

DROP TABLE IF EXISTS `unit_bins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `unit_bins` (
  `bin_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(45) NOT NULL,
  `unit_id` int(11) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`bin_id`),
  KEY `fk_unit_bins_units1_idx` (`unit_id`),
  KEY `fk_unit_bins_application_users1_idx` (`created_by`),
  KEY `fk_unit_bins_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_unit_bins_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_unit_bins_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_unit_bins_units1` FOREIGN KEY (`unit_id`) REFERENCES `subscriber_common_tables`.`units` (`unit_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `valve_types`
--

DROP TABLE IF EXISTS `valve_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `valve_types` (
  `valve_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`valve_id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_valve_types_application_users1_idx` (`created_by`),
  KEY `fk_valve_types_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_valve_types_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_valve_types_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehicle_part_numbers`
--

DROP TABLE IF EXISTS `vehicle_part_numbers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle_part_numbers` (
  `part_number_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`part_number_id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_vehicle_part_numbers_application_users1_idx` (`created_by`),
  KEY `fk_vehicle_part_numbers_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_vehicle_part_numbers_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_vehicle_part_numbers_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=46 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `vehicle_parts`
--

DROP TABLE IF EXISTS `vehicle_parts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `vehicle_parts` (
  `part_id` int(11) NOT NULL AUTO_INCREMENT,
  `description` varchar(60) NOT NULL,
  `created_by` int(11) NOT NULL,
  `datetime_created` datetime NOT NULL DEFAULT current_timestamp(),
  `modified_by` int(11) DEFAULT NULL,
  `datetime_modified` datetime DEFAULT NULL,
  PRIMARY KEY (`part_id`),
  UNIQUE KEY `description_UNIQUE` (`description`),
  KEY `fk_vehicle_parts_application_users1_idx` (`created_by`),
  KEY `fk_vehicle_parts_application_users2_idx` (`modified_by`),
  CONSTRAINT `fk_vehicle_parts_application_users1` FOREIGN KEY (`created_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `fk_vehicle_parts_application_users2` FOREIGN KEY (`modified_by`) REFERENCES `application_users_inventory`.`application_users` (`user_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=32 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: inventory_udf_and_views
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `inventory_udf_and_views`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `inventory_udf_and_views` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `inventory_udf_and_views`;

--
-- Temporary table structure for view `in_transit_items`
--

DROP TABLE IF EXISTS `in_transit_items`;
/*!50001 DROP VIEW IF EXISTS `in_transit_items`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `in_transit_items` AS SELECT
 1 AS `invoice_id`,
  1 AS `total_running_quantity`,
  1 AS `in_transit_items` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `inventory_item_concat`
--

DROP TABLE IF EXISTS `inventory_item_concat`;
/*!50001 DROP VIEW IF EXISTS `inventory_item_concat`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `inventory_item_concat` AS SELECT
 1 AS `item_id`,
  1 AS `item_category_id`,
  1 AS `item_description` */;
SET character_set_client = @saved_cs_client;

--
-- Temporary table structure for view `unit_item_checking`
--

DROP TABLE IF EXISTS `unit_item_checking`;
/*!50001 DROP VIEW IF EXISTS `unit_item_checking`*/;
SET @saved_cs_client     = @@character_set_client;
SET character_set_client = utf8;
/*!50001 CREATE VIEW `unit_item_checking` AS SELECT
 1 AS `unit_item_id` */;
SET character_set_client = @saved_cs_client;

--
-- Current Database: `inventory_udf_and_views`
--

USE `inventory_udf_and_views`;

--
-- Final view structure for view `in_transit_items`
--

/*!50001 DROP VIEW IF EXISTS `in_transit_items`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `in_transit_items` AS select `iti`.`invoice_id` AS `invoice_id`,sum(`iti`.`running_quantity`) AS `total_running_quantity`,json_arrayagg(json_object('item_transit_id',`iti`.`item_transit_id`,'unit_item_id',`iti`.`unit_item_id`,'item_description',`iic`.`item_description`,'frmt_quantity',format(`iti`.`running_quantity`,2),'quantity',`iti`.`running_quantity`)) AS `in_transit_items` from ((`inventory`.`in_transit_items` `iti` join `inventory`.`inventory_units_items` `iui` on(`iti`.`unit_item_id` = `iui`.`unit_item_id`)) join `inventory_udf_and_views`.`inventory_item_concat` `iic` on(`iui`.`item_id` = `iic`.`item_id`)) group by `iti`.`invoice_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `inventory_item_concat`
--

/*!50001 DROP VIEW IF EXISTS `inventory_item_concat`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `inventory_item_concat` AS select `ii`.`item_id` AS `item_id`,`ii`.`item_category_id` AS `item_category_id`,concat(coalesce(concat(' ',`ic`.`description`),''),coalesce(concat(' ',`b`.`description`),''),coalesce(concat(' ',`ii`.`model_description`),''),coalesce(concat(' ',`s`.`description`),''),coalesce(concat(' ',`r`.`description`),''),coalesce(concat(' ',`tp`.`description`),''),coalesce(concat(' ',`vt`.`description`),''),coalesce(concat(' ',`vp`.`description`),''),coalesce(concat(' ',`vpn`.`description`),'')) AS `item_description` from ((((((((`inventory`.`inventory_items` `ii` join `inventory`.`items_categories` `ic` on(`ii`.`item_category_id` = `ic`.`item_category_id`)) left join `inventory`.`brands` `b` on(`ii`.`brand_id` = `b`.`brand_id`)) left join `inventory`.`sizes` `s` on(`ii`.`size_id` = `s`.`size_id`)) left join `inventory`.`ratios` `r` on(`ii`.`ratio_id` = `r`.`ratio_id`)) left join `inventory`.`thread_patterns` `tp` on(`ii`.`pattern_id` = `tp`.`pattern_id`)) left join `inventory`.`valve_types` `vt` on(`ii`.`valve_id` = `vt`.`valve_id`)) left join `inventory`.`vehicle_parts` `vp` on(`ii`.`part_id` = `vp`.`part_id`)) left join `inventory`.`vehicle_part_numbers` `vpn` on(`ii`.`part_number_id` = `vpn`.`part_number_id`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `unit_item_checking`
--

/*!50001 DROP VIEW IF EXISTS `unit_item_checking`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_unicode_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`developer`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `unit_item_checking` AS select `iui`.`unit_item_id` AS `unit_item_id` from (`inventory`.`inventory_units_items` `iui` join `purchases_ap`.`po_details` `pd` on(`iui`.`unit_item_id` = `pd`.`unit_item_id`)) group by `iui`.`unit_item_id` union select `iui`.`unit_item_id` AS `unit_item_id` from (`inventory`.`inventory_units_items` `iui` join `inventory`.`items_adjustments` `ia` on(`iui`.`unit_item_id` = `ia`.`source_id` or `iui`.`unit_item_id` = `ia`.`destination_id`)) group by `iui`.`unit_item_id` union select `iui`.`unit_item_id` AS `unit_item_id` from (`inventory`.`inventory_units_items` `iui` join `point_of_sales_ar`.`inventory_item_sales` `iis` on(`iui`.`unit_item_id` = `iis`.`unit_item_id`)) group by `iui`.`unit_item_id` union select `iui`.`unit_item_id` AS `unit_item_id` from (`inventory`.`inventory_units_items` `iui` join `point_of_sales_ar`.`inventory_items_job_order` `iijo` on(`iui`.`unit_item_id` = `iijo`.`unit_item_id`)) group by `iui`.`unit_item_id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.6.20-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: 192.168.4.141    Database: udf_and_views_inventory
-- ------------------------------------------------------
-- Server version	10.6.25-MariaDB-ubu2204

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `udf_and_views_inventory`
--

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `udf_and_views_inventory` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */;

USE `udf_and_views_inventory`;

--
-- Dumping routines for database 'udf_and_views_inventory'
--
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getAdjustmentUserUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getAdjustmentUserUnit`(
	IN jsnAdjustmentUserUnit JSON
)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE intUserId INT;
	SET @sampleJSON='{
						"user_id":1
					}';	
	IF JSON_VALID(jsnAdjustmentUserUnit) THEN
		SET bolProceed = TRUE;
	END IF;
	IF bolProceed THEN
		SET intUserId = JSON_VALUE(jsnAdjustmentUserUnit, '$.user_id');
		IF bolProceed THEN
			SET @unitId = 0;
			SET @sqlCommand =  "SELECT COALESCE(u.unit_id,0) INTO @unitId
								FROM application_users_inventory.application_users au
								INNER JOIN subscriber_common_tables.units u ON au.unit_id = u.unit_id
								WHERE au.user_id = ?;";
			PREPARE query_statement FROM @sqlCommand;
			EXECUTE query_statement USING intUserId;
			DEALLOCATE PREPARE query_statement;
			SET @sqlCommand =  "SELECT JSON_OBJECT('success', TRUE, 'message', 'Records retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('unit_id', u.unit_id, 'description', u.description) ORDER BY u.description)) AS response
								FROM subscriber_common_tables.units u
								WHERE u.unit_id = ?;";
			PREPARE query_statement FROM @sqlCommand;
			EXECUTE query_statement USING @unitId;
			DEALLOCATE PREPARE query_statement;
		END IF;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON input', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getClientLedger` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getClientLedger`(
    IN jsonInput TEXT
)
BEGIN 
    DECLARE dateFrom DATE;
    DECLARE dateTo DATE;
    DECLARE intClientID INTEGER(11);
    DECLARE dateTemp DATE;
    DECLARE stringCondition VARCHAR(255);

    -- Extract values from JSON input safely
    SET dateFrom = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.start_date')) AS DATE);
    SET dateTo = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.end_date')) AS DATE);
    SET intClientID = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.client_id')) AS UNSIGNED);

    -- Swap dates if dateFrom > dateTo
    IF dateFrom > dateTo THEN
        SET dateTemp = dateFrom;
        SET dateFrom = dateTo;
        SET dateTo = dateTemp;
    END IF;

    -- Prepare entity_id condition
    IF intClientID = 0 THEN
        SET stringCondition = '1=1'; -- no filter on entity_id
    ELSE
        SET stringCondition = CONCAT('a.entity_id = ', intClientID);
    END IF;
    
    -- Drop temp table if exists
    DROP TEMPORARY TABLE IF EXISTS app_bin.source_ledger;

    -- Create temporary table using accurate Version 1 joins and columns
    SET @sqlCommand = CONCAT(
        "CREATE TEMPORARY TABLE app_bin.source_ledger AS
        SELECT 
            transaction_date,
            reference,
            IF(payment = 0, transaction_amount, 0) AS debit, 
            IF(payment = 1, transaction_amount, 0) AS credit,
            payment_for,
            posted_by,
            posting_unit,
            for_unit,
            b.entity_name AS client,
            a.entity_id,
            transaction_id,
            payment
        FROM 
        (
            SELECT * FROM
            (
                SELECT 
                    DATE(invoice_date) AS transaction_date, 
                    invoice_reference AS reference, 
                    net_amount_due AS transaction_amount,
                    '' AS payment_for,
                    0 AS collection_type,
                    '' AS for_unit,
                    su.full_name AS posted_by,
                    c.description AS posting_unit,
                    0 AS payment,
                    a.entity_id,
                    a.invoice_id AS transaction_id
                FROM 
                    point_of_sales_ar.pos_invoices a
                INNER JOIN
                    application_users_point_of_sales_ar.application_users b 
                ON     
                    a.posted_by = b.user_id 
                INNER JOIN
                    subscriber_common_tables.units c 
                ON 
                    b.unit_id = c.unit_id
                INNER JOIN 
                    application_users_point_of_sales_ar.subscribers_applications_user sau 
                ON 	
                    sau.user_id = b.user_id 
                INNER JOIN 
                    application_users_point_of_sales_ar.subscribers_users su 
                ON 
                    su.subscriber_user_id = sau.subscriber_user_id 

                UNION ALL

                SELECT 
                    DATE(a.payment_date) AS transaction_date,
                    a.payment_reference AS reference,
                    a.amount_paid AS transaction_amount,
                    b.invoice_reference AS payment_for,
                    ct.description AS collection_type,
                    d.description AS for_unit,
                    su.full_name AS posted_by,
                    f.description AS posting_unit,
                    1 AS payment,
                    b.entity_id,
                    a.payment_id AS transaction_id
                FROM 
                    point_of_sales_ar.ar_payments a 
                INNER JOIN
                    point_of_sales_ar.pos_invoices b 
                ON
                    a.invoice_id = b.invoice_id 
                INNER JOIN 
                    application_users_point_of_sales_ar.application_users c 
                ON
                    b.posted_by = c.user_id 
                INNER JOIN 
                    subscriber_common_tables.units d 
                ON
                    c.unit_id = d.unit_id 
                INNER JOIN
                    application_users_point_of_sales_ar.application_users e 
                ON
                    a.posted_by = e.user_id 
                INNER JOIN 
                    subscriber_common_tables.units f 
                ON 
                    e.unit_id = f.unit_id    
                INNER JOIN 
                    funds.collection_types ct 
                ON 
                    ct.collection_id = a.collection_type_id     
                INNER JOIN 
                    application_users_point_of_sales_ar.subscribers_applications_user sau 
                ON 	
                    sau.user_id = c.user_id 
                INNER JOIN 
                    application_users_point_of_sales_ar.subscribers_users su 
                ON 
                    su.subscriber_user_id = sau.subscriber_user_id 
            ) AS aa
            WHERE ", stringCondition COLLATE utf8mb4_general_ci, "
        ) AS a 
        INNER JOIN 
            entities_udf_and_views.entity_name b 
        ON
            a.entity_id = b.entity_id 
        ORDER BY 
            transaction_date, payment, transaction_id;"
    );

    PREPARE stmt FROM @sqlCommand;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    -- Initialize user variables for running balance calculation
    SET @runningBalance = 0;
    SET @forwardBalance = 0;
    SET @numberOfEntries = 0;

    -- Calculate forward balance and number of entries before dateFrom
    SELECT 
        COALESCE(SUM(debit - credit), 0),
        COALESCE(COUNT(reference), 0)
    INTO
        @forwardBalance, @numberOfEntries
    FROM 
        app_bin.source_ledger
    WHERE 
        transaction_date < dateFrom;

    SET @runningBalance = @forwardBalance;

    -- Date range condition string for the final output
    SET stringCondition = CONCAT("t.transaction_date BETWEEN '", DATE_FORMAT(dateFrom, '%Y-%m-%d'), "' AND '", DATE_FORMAT(dateTo, '%Y-%m-%d'), "'");

    -- Build the JSON Response (With safe COALESCE for empty results)
    IF @numberOfEntries > 0 THEN
        SET @sqlCommand = CONCAT(
            "SELECT JSON_OBJECT(
                'success', TRUE, 
                'message', 'Client ledger retrieved successfully.', 
                'json_data', COALESCE(JSON_ARRAYAGG(result ORDER BY transaction_date, payment, transaction_id), JSON_ARRAY())
            ) AS response FROM (
                SELECT 
                    JSON_OBJECT(
                        'transaction_date', DATE_FORMAT('", DATE_FORMAT(dateFrom, '%Y-%m-%d'), "', '%Y %b %d'),
                        'reference', 'Balance forwarded',
                        'debit', IF(@forwardBalance > 0, FORMAT(@forwardBalance, 2), '0.00'),
                        'credit', IF(@forwardBalance < 0, FORMAT(ABS(@forwardBalance), 2), '0.00'),
                        'running_balance', FORMAT(ABS(@runningBalance), 2),
                        'col_balance', IF(@runningBalance >= 0, 'Dr', 'Cr'),
                        'payment_for', '',
                        'posted_by', '',
                        'posting_unit', '',
                        'for_unit', '',
                        'client', ''
                    ) AS result,
                    CAST('0000-00-00' AS DATE) AS transaction_date, 
                    -1 AS payment, 
                    -1 AS transaction_id
                FROM dual

                UNION ALL

                SELECT 
                    JSON_OBJECT(
                        'transaction_date', DATE_FORMAT(t.transaction_date, '%Y %b %d'),
                        'reference', t.reference,
                        'debit', FORMAT(t.debit, 2),
                        'credit', FORMAT(t.credit, 2),
                        'running_balance', FORMAT(ABS(@runningBalance := @runningBalance + (t.debit - t.credit)), 2),
                        'col_balance', IF(@runningBalance >= 0, 'Dr', 'Cr'),
                        'payment_for', t.payment_for,
                        'posted_by', t.posted_by,
                        'posting_unit', t.posting_unit,
                        'for_unit', t.for_unit,
                        'client', t.client
                    ) AS result,
                    t.transaction_date,
                    t.payment,
                    t.transaction_id
                FROM
                    app_bin.source_ledger t
                WHERE ", stringCondition, "
            ) AS ledger"
        );
    ELSE
        SET @sqlCommand = CONCAT(
            "SELECT JSON_OBJECT(
                'success', TRUE, 
                'message', 'Client ledger retrieved successfully.', 
                'json_data', COALESCE(JSON_ARRAYAGG(result ORDER BY transaction_date, payment, transaction_id), JSON_ARRAY())
            ) AS response FROM (
                SELECT 
                    JSON_OBJECT(
                        'transaction_date', DATE_FORMAT(t.transaction_date, '%Y %b %d'),
                        'reference', t.reference,
                        'debit', FORMAT(t.debit, 2),
                        'credit', FORMAT(t.credit, 2),
                        'running_balance', FORMAT(ABS(@runningBalance := @runningBalance + (t.debit - t.credit)), 2),
                        'col_balance', IF(@runningBalance >= 0, 'Dr', 'Cr'),
                        'payment_for', t.payment_for,
                        'posted_by', t.posted_by,
                        'posting_unit', t.posting_unit,
                        'for_unit', t.for_unit,
                        'client', t.client
                    ) AS result,
                    t.transaction_date,
                    t.payment,
                    t.transaction_id
                FROM
                    app_bin.source_ledger t
                WHERE ", stringCondition, "
            ) AS ledger"
        );
    END IF;

    PREPARE stmt FROM @sqlCommand;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getClientName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getClientName`(
    IN jsnCustomer JSON
)
BEGIN 
    DECLARE intEntityId INT DEFAULT 0;
    IF JSON_VALID(jsnCustomer) THEN
        SET intEntityId = COALESCE(JSON_VALUE(jsnCustomer, '$.entity_id'), 0);
        SET @sqlCommand = CONCAT(
            "SELECT JSON_OBJECT('success', TRUE, 'message', 'Records retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT( ",
                "'clientId', entity_id, ",
                "'clientName', entity_name ",
            "))) AS response ",
            "FROM ( ",
                "SELECT entity_id, entity_name ",
                "FROM entities_udf_and_views.entity_name "
        );
        
        IF intEntityId > 0 THEN
            SET @sqlCommand = CONCAT(@sqlCommand, "WHERE entity_id = ", intEntityId, " ");
        END IF;
        SET @sqlCommand = CONCAT(@sqlCommand, ") AS filtered_entities;");
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement;
        DEALLOCATE PREPARE query_statement;
    ELSE
        SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON input', 'json_data', NULL) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getCustomerInactivity` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getCustomerInactivity`(
    IN jsonInput JSON
)
BEGIN 
    DECLARE dateFrom DATE; DECLARE dateTo DATE;
    DECLARE charUnitList_JSON JSON; DECLARE unitCount INT DEFAULT 0;
    DECLARE i INT DEFAULT 0; DECLARE unitId INT;
    DECLARE unitListStringBuilder VARCHAR(255) DEFAULT '';
    DECLARE stringCondition VARCHAR(1000); DECLARE dateTemp DATE;
    IF JSON_VALID(jsonInput) THEN
        SET dateFrom = JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.start_date'));
        SET dateTo = JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.end_date'));
        SET charUnitList_JSON = JSON_EXTRACT(jsonInput, '$.charUnitList');
        IF dateFrom > dateTo THEN SET dateTemp=dateFrom; SET dateFrom=dateTo; SET dateTo=dateTemp; END IF;
        SET stringCondition = '';
        IF charUnitList_JSON IS NOT NULL THEN
            SET unitCount = JSON_LENGTH(charUnitList_JSON);
            IF unitCount > 0 THEN
                SET i=0; SET unitListStringBuilder='';
                WHILE i < unitCount DO
                    SET unitId = CAST(JSON_UNQUOTE(JSON_EXTRACT(charUnitList_JSON, CONCAT('$[', i, ']'))) AS UNSIGNED);
                    IF unitId <> 0 THEN
                        IF unitListStringBuilder='' THEN SET unitListStringBuilder=CAST(unitId AS CHAR);
                        ELSE SET unitListStringBuilder=CONCAT(unitListStringBuilder, ',', CAST(unitId AS CHAR)); END IF;
                    END IF;
                    SET i = i + 1;
                END WHILE;
                IF LENGTH(unitListStringBuilder) > 0 THEN
                    SET stringCondition = CONCAT(' AND c.unit_id IN (', unitListStringBuilder, ')');
                END IF;
            END IF;
        END IF;
        DROP TEMPORARY TABLE IF EXISTS app_bin.customer_inactivity_report;
        SET @sqlCommand = CONCAT("
            CREATE TEMPORARY TABLE app_bin.customer_inactivity_report
            SELECT e.entity_id, COALESCE(e.entity_name,'') AS entity_name, c.unit_id,
                u.description AS unit_name, MAX(p.invoice_date) AS last_order_date,
                CASE WHEN MAX(p.invoice_date) IS NOT NULL THEN DATEDIFF(CURDATE(), MAX(p.invoice_date)) ELSE NULL END AS days_since_last_order
            FROM entities_udf_and_views.entity_name e
            LEFT JOIN point_of_sales_ar.pos_invoices p ON e.entity_id=p.entity_id AND p.entity_id IS NOT NULL AND p.walk_in=0 AND DATE(p.invoice_date) <= '", dateTo, "'
            LEFT JOIN application_users_point_of_sales_ar.application_users c ON p.posted_by=c.user_id
            INNER JOIN subscriber_common_tables.units u ON c.unit_id=u.unit_id
            LEFT JOIN application_users_point_of_sales_ar.subscribers_applications_user sau ON sau.user_id=c.user_id
            LEFT JOIN application_users_point_of_sales_ar.subscribers_users su ON su.subscriber_user_id=sau.subscriber_user_id
            WHERE (p.invoice_id IS NULL OR DATE(p.invoice_date) < '", dateFrom, "') AND c.unit_id IS NOT NULL ", stringCondition, "
            GROUP BY e.entity_id, e.entity_name, c.unit_id, u.description
            HAVING last_order_date IS NULL OR last_order_date < '", dateFrom, "'
        ");
        PREPARE query_statement FROM @sqlCommand; EXECUTE query_statement; DEALLOCATE PREPARE query_statement;
        SELECT JSON_OBJECT('success', TRUE, 'message', 'Records retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT(
            'entity_id', entity_id, 'entity_name', entity_name, 'unit_id', unit_id, 'unit_name', unit_name,
            'last_order_date', IFNULL(DATE_FORMAT(last_order_date, '%m/%d/%Y'), ''),
            'days_since_last_order', IFNULL(days_since_last_order, '')
        ))) AS response
        FROM app_bin.customer_inactivity_report ORDER BY last_order_date;
    ELSE
        SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON input', 'json_data', NULL) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getDeliveriesReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getDeliveriesReport`(
    IN jsonParams JSON
)
BEGIN
    DECLARE dateFrom DATE;
    DECLARE dateTo DATE;
    DECLARE unitsJSON JSON;
    DECLARE charUnitList VARCHAR(1000);
    DECLARE bolWithCost BOOLEAN;
    DECLARE dateTemp DATE;
    DECLARE stringCondition VARCHAR(2000);
    DECLARE stringOrderBy VARCHAR(1000);
    DECLARE stringFields VARCHAR(4000);
    DECLARE sqlCommand LONGTEXT;
    DECLARE finalQuery LONGTEXT;
    DECLARE done INT DEFAULT FALSE;
    DECLARE idx INT DEFAULT 0;
    DECLARE cnt INT DEFAULT 0;
    DECLARE unitVal VARCHAR(50);
    DECLARE unitsCSV VARCHAR(1000) DEFAULT '';

    IF JSON_VALID(jsonParams) THEN
        SET dateFrom = JSON_VALUE(jsonParams, '$.dateFrom');
        SET dateTo = JSON_VALUE(jsonParams, '$.dateTo');
        SET unitsJSON = JSON_EXTRACT(jsonParams, '$.units');
        SET bolWithCost = JSON_VALUE(jsonParams, '$.withCost');

        IF dateFrom > dateTo THEN
            SET dateTemp = dateFrom;
            SET dateFrom = dateTo;
            SET dateTo = dateTemp;
        END IF;

        SET cnt = JSON_LENGTH(unitsJSON);
        WHILE idx < cnt DO
            SET unitVal = JSON_VALUE(unitsJSON, CONCAT('$[', idx, ']'));
            IF idx = 0 THEN
                SET unitsCSV = unitVal;
            ELSE
                SET unitsCSV = CONCAT(unitsCSV, ',', unitVal);
            END IF;
            SET idx = idx + 1;
        END WHILE;
        SET charUnitList = unitsCSV;

        SET stringCondition = CONCAT("DATE(b.delivery_date) BETWEEN '", dateFrom, "' AND '", dateTo, "'");
        IF LENGTH(TRIM(charUnitList)) > 0 THEN
            SET stringCondition = CONCAT(stringCondition, " AND g.unit_id IN (", charUnitList, ")");
        END IF;

        SET stringOrderBy = " ORDER BY delivery_date, receiving_unit, b.delivery_reference, CONCAT(model_description, item_size, item_ratio, item_thread_pattern, item_valve_type, item_part_description, item_part_number)";

        IF bolWithCost THEN
            SET stringFields = "SELECT JSON_OBJECT('success', TRUE, 'message', 'Records retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT(
                'fmt_delivery_date', DATE_FORMAT(b.delivery_date,'%Y %b %d'),
                'receiving_unit', g.description,
                'delivery_reference', b.delivery_reference,
                'category', i.category,
                'brand', i.brand,
                'item', CONCAT(model_description, item_size, item_ratio, item_thread_pattern, item_valve_type, item_part_description, item_part_number),
                'quantity', CONCAT(FORMAT(a.quantity,2),' ',TRIM(i.stocking_unit)),
                'unit_cost', FORMAT(a.unit_cost,2),
                'total_cost', FORMAT(a.total_cost,2),
                'supplier', f.entity_name,
                'po_reference', LPAD(e.po_id,6,0),
                'delivery_date', DATE(b.delivery_date),
                'item_id', i.item_id
            ))) AS response ";
        ELSE
            SET stringFields = "SELECT JSON_OBJECT('success', TRUE, 'message', 'Records retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT(
                'fmt_delivery_date', DATE_FORMAT(b.delivery_date,'%Y %b %d'),
                'receiving_unit', g.description,
                'delivery_reference', b.delivery_reference,
                'category', i.category,
                'brand', i.brand,
                'item', CONCAT(model_description, item_size, item_ratio, item_thread_pattern, item_valve_type, item_part_description, item_part_number),
                'quantity', CONCAT(FORMAT(a.quantity,2),' ',TRIM(i.stocking_unit)),
                'supplier', f.entity_name,
                'po_reference', LPAD(e.po_id,6,0),
                'delivery_date', DATE(b.delivery_date),
                'item_id', i.item_id
            ))) AS response ";
        END IF;

        SET sqlCommand = "\n        FROM purchases_ap.deliveries_details a\n        INNER JOIN purchases_ap.deliveries b ON a.delivery_id=b.delivery_id\n        INNER JOIN purchases_ap.for_deliveries c ON b.for_delivery_id=c.for_delivery_id\n        INNER JOIN purchases_ap.po_main e ON e.po_id=c.po_id\n        INNER JOIN entities_udf_and_views.entity_name f ON e.supplier_id=f.entity_id\n        INNER JOIN subscriber_common_tables.units g ON e.receiving_unit=g.unit_id\n        INNER JOIN inventory.inventory_units_items h ON a.unit_item_id=h.unit_item_id\n        INNER JOIN (\n            SELECT aaa.item_id,\n                   bbb.description category,\n                   CONCAT(' ', ccc.description) brand,\n                   CONCAT(' ', TRIM(aaa.model_description)) model_description,\n                   COALESCE(CONCAT(' ', ddd.description), '') item_size,\n                   COALESCE(CONCAT(' ', eee.description), '') item_ratio,\n                   COALESCE(CONCAT(' ', fff.description), '') item_thread_pattern,\n                   COALESCE(CONCAT(' ', ggg.description), '') item_valve_type,\n                   COALESCE(CONCAT(' ', hhh.description), '') item_part_description,\n                   COALESCE(CONCAT(' ', iii.description), '') item_part_number,\n                   aaa.stocking_unit, aaa.retail_unit, aaa.rtu_over_stu,\n                   aaa.item_category_id, aaa.brand_id\n            FROM inventory.inventory_items aaa\n            INNER JOIN inventory.items_categories bbb ON aaa.item_category_id=bbb.item_category_id\n            INNER JOIN inventory.brands ccc ON aaa.brand_id=ccc.brand_id\n            LEFT JOIN inventory.sizes ddd ON aaa.size_id=ddd.size_id\n            LEFT JOIN inventory.ratios eee ON aaa.ratio_id=eee.ratio_id\n            LEFT JOIN inventory.thread_patterns fff ON aaa.pattern_id=fff.pattern_id\n            LEFT JOIN inventory.valve_types ggg ON aaa.valve_id=ggg.valve_id\n            LEFT JOIN inventory.vehicle_parts hhh ON aaa.part_id=hhh.part_id\n            LEFT JOIN inventory.vehicle_part_numbers iii ON aaa.part_number_id=iii.part_number_id\n        ) i ON h.item_id=i.item_id\n        WHERE ";

        SET finalQuery = CONCAT(stringFields, sqlCommand, stringCondition, stringOrderBy);

        PREPARE stmt FROM finalQuery;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON input', 'json_data', NULL) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getEmployeeName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getEmployeeName`(
    IN jsnEmployee JSON
)
BEGIN
    IF JSON_VALID(jsnEmployee) THEN
        SET @bolGetOne = JSON_VALUE(jsnEmployee, '$.bol_getone');
        SET @intEmployeeId = JSON_VALUE(jsnEmployee, '$.employee_id');
        SET @charEmployeeName = JSON_VALUE(jsnEmployee, '$.employee_name');

        IF @bolGetOne THEN
            SET @whereCredentials = CONCAT(' AND a.employee_id = ', @intEmployeeId);
        ELSE
            IF @charEmployeeName <> '' THEN
                SET @whereCredentials = CONCAT(" AND LOWER(a.employee_name) LIKE CONCAT('%',LOWER('", @charEmployeeName, "'),'%')");
            ELSE
                SET @whereCredentials = '';
            END IF;
        END IF;

        SET @sqlCommand = CONCAT("
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'Employee name retrieved successfully.',
                'json_data', COALESCE(
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'employee_id', employee_id,
                            'employee_name', employee_name
                        ) ORDER BY employee_name
                    ),
                    JSON_ARRAY()
                )
            ) AS response
            FROM (
                SELECT
                    a.employee_id,
                    a.employee_name
                FROM
                    employees_profile_udf_and_views.employee_name a
                INNER JOIN
                    employees_profile.employees_status b ON a.employee_id = b.employee_id
                INNER JOIN
                    employees_profile.employment_status c ON b.status_id = c.status_id
                WHERE
                    c.cessation_status = 0",
        @whereCredentials,
        ") AS combined");

        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON input.',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getEmptyUnitBin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getEmptyUnitBin`(
		IN jsnEmptyUnitBin JSON
	)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE bolGetOne BOOLEAN;
	DECLARE intBinId INT;
	DECLARE intUnitId INT;
	DECLARE charDescription VARCHAR(100);

	IF JSON_VALID(jsnEmptyUnitBin) THEN
		SET bolProceed = TRUE;
	END IF;

	IF bolProceed THEN
		SET bolGetOne = JSON_VALUE(jsnEmptyUnitBin, '$.bol_getone');
		SET intBinId = JSON_VALUE(jsnEmptyUnitBin, '$.bin_id');
		SET intUnitId = JSON_VALUE(jsnEmptyUnitBin, '$.unit_id');
		SET charDescription = JSON_VALUE(jsnEmptyUnitBin, '$.description');

		IF bolGetOne THEN
			SET whereCredentials = CONCAT("WHERE ISNULL(iui.bin_id) AND ub.unit_id = ",intUnitId," AND ub.bin_id = ",intBinId);
		ELSE
			IF charDescription <> '' THEN
				SET whereCredentials = CONCAT("WHERE ISNULL(iui.bin_id) AND ub.unit_id = ",intUnitId," AND LOWER(ub.description) LIKE CONCAT('%',LOWER('",charDescription,"'),'%')");
			ELSE
				SET whereCredentials = CONCAT("WHERE ISNULL(iui.bin_id) AND ub.unit_id = ",intUnitId);
			END IF;
		END IF;

		SET @sqlCommand =  CONCAT("
							SELECT 
								JSON_OBJECT(
									'success', TRUE,
									'message', 'Records retrieved successfully.',
									'json_data', JSON_ARRAYAGG(
									    JSON_OBJECT(
									    	'bin_id', ub.bin_id,
									    	'description', ub.description,
									    	'unit_id', ub.unit_id,
									    	'unit', u.description,
									    	'created_by', ub.created_by,
									    	'creator', au.user_login_name,
									    	'datetime_created', ub.datetime_created,
									    	'frmt_datetime_created', DATE_FORMAT(ub.datetime_created, '%Y %b %d %a'),
									    	'modified_by', ub.modified_by,
									    	'modifier', au2.user_login_name,
									    	'datetime_modified', ub.datetime_modified,
									    	'frmt_datetime_modified', DATE_FORMAT(ub.datetime_modified , '%Y %b %d %a')
									    ) ORDER BY ub.datetime_created, ub.description
									)
								) AS response
							FROM 
								inventory.unit_bins ub
							INNER JOIN
								subscriber_common_tables.units u 
							ON
								ub.unit_id = u.unit_id
							INNER JOIN 
								application_users_inventory.application_users au 
							ON
								ub.created_by = au.user_id 
							LEFT JOIN 
								application_users_inventory.application_users au2 
							ON
								ub.modified_by = au2.user_id
							LEFT JOIN
								inventory.inventory_units_items iui
							ON
								ub.bin_id = iui.bin_id
							",whereCredentials,";");
		PREPARE query_statement FROM @sqlCommand;
		EXECUTE query_statement;
		DEALLOCATE PREPARE query_statement;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON input', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getExpiriesAndPastDue` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getExpiriesAndPastDue`(
    IN jsonUnitList JSON
)
BEGIN 
    DECLARE charUnitListStr VARCHAR(255);
    DECLARE stringCondition TEXT DEFAULT '';

    -- Extract charUnitList and instantly clean up array brackets so "[1,2]" safely becomes "1,2"
    SET charUnitListStr = JSON_UNQUOTE(JSON_EXTRACT(jsonUnitList, '$.units'));
    SET charUnitListStr = REPLACE(REPLACE(charUnitListStr, '[', ''), ']', '');

    -- Build the base condition (From Version 1)
    SET stringCondition = ' WHERE a.on_term AND a.invoice_running_balance > 0 ';

    -- Add unit filter condition if units were provided and not zero/empty
    IF charUnitListStr IS NOT NULL AND charUnitListStr NOT IN ('', '0', 'null') THEN
        SET stringCondition = CONCAT(stringCondition, ' AND d.unit_id IN (', charUnitListStr, ')');
    END IF;

    -- Setup Time Variables for Bucket Calculations
    SET @firstMonth = EXTRACT(YEAR_MONTH FROM CURDATE());
    SET @secondMonth = EXTRACT(YEAR_MONTH FROM DATE_ADD(CURDATE(), INTERVAL 1 MONTH));
    SET @thirdMonth = EXTRACT(YEAR_MONTH FROM DATE_ADD(CURDATE(), INTERVAL 2 MONTH));
    SET @fourthMonth = EXTRACT(YEAR_MONTH FROM DATE_ADD(CURDATE(), INTERVAL 3 MONTH));

    DROP TEMPORARY TABLE IF EXISTS app_bin.expiries;

    -- Create temporary table using accurate Version 1 joins and calculations
    SET @sqlCommand = CONCAT(
        "CREATE TEMPORARY TABLE app_bin.expiries AS
        SELECT 
            unit,
            DATE_FORMAT(invoice_date, '%Y %b %d') AS fmt_invoice_date,
            client,
            invoice_reference,
            invoice_amount,
            DATE_FORMAT(ar_due_date, '%Y %b %d') AS fmt_ar_due_date,
            IF(EXTRACT(YEAR_MONTH FROM ar_due_date)=@firstMonth, a.invoice_running_balance, 0.00) AS month_1,
            IF(EXTRACT(YEAR_MONTH FROM ar_due_date)=@secondMonth, a.invoice_running_balance, 0.00) AS month_2,
            IF(EXTRACT(YEAR_MONTH FROM ar_due_date)=@thirdMonth, a.invoice_running_balance, 0.00) AS month_3,
            IF(EXTRACT(YEAR_MONTH FROM ar_due_date)=@fourthMonth, a.invoice_running_balance, 0.00) AS month_4,
            IF(DATEDIFF(CURDATE(), ar_due_date) BETWEEN 1 AND 30, a.invoice_running_balance, 0.00) AS past_due_1_30,
            IF(DATEDIFF(CURDATE(), ar_due_date) BETWEEN 31 AND 60, a.invoice_running_balance, 0.00) AS past_due_31_60,
            IF(DATEDIFF(CURDATE(), ar_due_date) BETWEEN 61 AND 90, a.invoice_running_balance, 0.00) AS past_due_61_90,
            IF(DATEDIFF(CURDATE(), ar_due_date) > 90, a.invoice_running_balance, 0.00) AS past_due_over_90,
            invoice_date,
            ar_due_date,
            unit_id
        FROM
            (
                SELECT 
                    d.description AS unit,
                    DATE(a.invoice_date) AS invoice_date,
                    b.entity_name AS client,
                    a.invoice_reference,
                    a.net_amount_due AS invoice_amount, 
                    a.term_in_days,
                    DATE(a.ar_due_date) AS ar_due_date,
                    a.invoice_running_balance,
                    d.unit_id
                FROM 
                    point_of_sales_ar.pos_invoices a 
                INNER JOIN
                    entities_udf_and_views.entity_name b 
                ON 
                    a.entity_id=b.entity_id 
                INNER JOIN 
                    application_users_point_of_sales_ar.application_users c 
                ON
                    a.posted_by=c.user_id 
                INNER JOIN 
                    subscriber_common_tables.units d 
                ON
                    c.unit_id=d.unit_id ",
                stringCondition,
            " ) a"
    );

    PREPARE query_statement FROM @sqlCommand;
    EXECUTE query_statement;
    DEALLOCATE PREPARE query_statement;

    -- Select and convert to JSON array with safe wrapper and sub-total logic
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Expiries and past due records retrieved successfully.',
        'json_data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'unit', unit,
                    'fmt_invoice_date', COALESCE(fmt_invoice_date, ''),
                    'client', client,
                    'invoice_reference', COALESCE(invoice_reference, ''),
                    'invoice_amount', FORMAT(invoice_amount, 2),
                    'fmt_ar_due_date', COALESCE(fmt_ar_due_date, ''),
                    'month_1', FORMAT(month_1, 2),
                    'month_2', FORMAT(month_2, 2),
                    'month_3', FORMAT(month_3, 2),
                    'month_4', FORMAT(month_4, 2),
                    'past_due_1_30', FORMAT(past_due_1_30, 2),
                    'past_due_31_60', FORMAT(past_due_31_60, 2),
                    'past_due_61_90', FORMAT(past_due_61_90, 2),
                    'past_due_over_90', FORMAT(past_due_over_90, 2),
                    'unit_id', unit_id,
                    'invoice_date', IFNULL(DATE_FORMAT(invoice_date, '%Y-%m-%d'), ''),
                    'ar_due_date', IFNULL(DATE_FORMAT(ar_due_date, '%Y-%m-%d'), ''),
                    'entry_identifier', entry_identifier
                )
            ),
            JSON_ARRAY() -- Safely returns an empty array if no records match
        )
    ) AS response FROM
    (
        SELECT 
            unit,
            fmt_invoice_date, 
            client,
            invoice_reference,
            invoice_amount,
            fmt_ar_due_date, 
            month_1,
            month_2,
            month_3,
            month_4,
            past_due_1_30,
            past_due_31_60,
            past_due_61_90, 
            past_due_over_90,
            unit_id, 
            invoice_date, 
            ar_due_date,
            0 entry_identifier
        FROM 
            app_bin.expiries 

        UNION ALL

        SELECT 
            unit,
            '' AS fmt_invoice_date,
            CONCAT(unit, ' Sub-Total ') AS client, 
            '' AS invoice_reference, 
            SUM(invoice_amount) AS invoice_amount,
            '' AS fmt_ar_due_date, 
            SUM(month_1) AS month_1,
            SUM(month_2) AS month_2,
            SUM(month_3) AS month_3, 
            SUM(month_4) AS month_4, 
            SUM(past_due_1_30) AS past_due_1_30, 
            SUM(past_due_31_60) AS past_due_31_60,
            SUM(past_due_61_90) AS past_due_61_90, 
            SUM(past_due_over_90) AS past_due_over_90, 
            unit_id,
            NULL AS invoice_date,
            NULL AS ar_due_date,
            99 AS entry_identifier
        FROM 
            app_bin.expiries
        GROUP BY
            unit_id
    ) combined_results
    ORDER BY 
        unit, entry_identifier, client, invoice_date;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getImportItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getImportItems`(
		IN jsnImportItems JSON
	)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE charItemDescription VARCHAR(100);
	DECLARE intUnitId INT;
	SET @sampleJSON='{
						"unit_id":10,
						"item_description":"James"
					}';	
	IF JSON_VALID(jsnImportItems) THEN
		SET bolProceed = TRUE;
	END IF;
	IF bolProceed THEN
		SET charItemDescription = JSON_VALUE(jsnImportItems, '$.item_description');	
		SET intUnitId = JSON_VALUE(jsnImportItems, '$.unit_id');	
		IF bolProceed THEN
			IF charItemDescription <> '' THEN
				SET whereCredentials = CONCAT(" AND LOWER(iic.item_description) LIKE CONCAT('%',LOWER('",charItemDescription,"'),'%')");
			ELSE
				SET whereCredentials = "";
			END IF;
			SET @sqlCommand =  CONCAT("
								SELECT 
									JSON_OBJECT(
										'success', TRUE,
										'message', 'Records retrieved successfully.',
										'json_data', JSON_ARRAYAGG(
										    JSON_OBJECT(
										    	'item_id', iic.item_id,
												'unit_item_id', aa.unit_item_id,
												'unit', aa.unit,
										    	'item_description', iic.item_description
										    ) ORDER BY iic.item_description
										)
									) AS response
								FROM 
									inventory_udf_and_views.inventory_item_concat iic
								LEFT JOIN
									(
										SELECT 
											iui.item_id,
											iui.unit_item_id,
											IF(COALESCE(iu.warehouse,FALSE),ii.stocking_unit,ii.retail_unit) AS unit
										FROM 
											inventory.inventory_units_items iui
										INNER JOIN
											inventory.inventory_units iu
										ON
											iui.unit_id = iu.unit_id
										INNER JOIN
											inventory.inventory_items ii
										ON
											iui.item_id = ii.item_id
										WHERE 
											iui.unit_id = ?
									) AS aa
								ON
									iic.item_id = aa.item_id
								LEFT JOIN 
									inventory.inventory_empty_cases iec 
								ON 
									iec.empty_item_id = iic.item_id
								",whereCredentials,";");
			PREPARE query_statement FROM @sqlCommand;
			EXECUTE query_statement USING intUnitId;
			DEALLOCATE PREPARE query_statement;
		END IF;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON input', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInstransitReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInstransitReport`(IN jsnInput JSON)
BEGIN
    DECLARE search VARCHAR(255) COLLATE utf8_general_ci;
    SET search = JSON_UNQUOTE(JSON_EXTRACT(jsnInput, '$.search'));

    DROP TEMPORARY TABLE IF EXISTS purchases_ap.po_in_transits;
    CREATE TEMPORARY TABLE purchases_ap.po_in_transits
    (INDEX po_id (`po_id`))
    SELECT fd.po_id, pm.supplier_id
    FROM purchases_ap.for_deliveries fd 
    INNER JOIN purchases_ap.po_main pm ON fd.po_id = pm.po_id 
    LEFT JOIN purchases_ap.deliveries d ON fd.for_delivery_id = d.for_delivery_id 
    WHERE fd.confirmed AND ISNULL(d.for_delivery_id);

    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Records retrieved successfully.',
        'json_data', JSON_ARRAYAGG(response)
    ) AS response
    FROM (
        SELECT JSON_OBJECT(
            'po_id', LPAD(pm.po_id , 8 , '0'),
            'entity_name', en.entity_name,
            'deliver_to', u.description,
            'item_id', iic.item_id,
            'unit_item_id', iui.unit_item_id,
            'item_description', iic.item_description,
            'date_confirmed', DATE_FORMAT(fd.date_confirmed, '%m/%d/%Y'),
            'quantity', CASE WHEN iu.warehouse THEN CONCAT(fdd.quantity, ' ', ii.stocking_unit) ELSE CONCAT(fdd.quantity, ' ', ii.retail_unit) END,
            'unit_cost', fdd.unit_cost,
            'total_cost', fdd.total_cost
        ) AS response
        FROM purchases_ap.for_deliveries_details fdd 
        INNER JOIN purchases_ap.for_deliveries fd ON fdd.for_delivery_id = fd.for_delivery_id 
        INNER JOIN purchases_ap.po_details pd ON (fd.po_id, fdd.unit_item_id) = (pd.po_id, pd.unit_item_id)
        INNER JOIN purchases_ap.po_in_transits pm ON fd.po_id = pm.po_id
        INNER JOIN entities_udf_and_views.entity_name en ON pm.supplier_id = en.entity_id
        INNER JOIN inventory.inventory_units_items iui ON fdd.unit_item_id = iui.unit_item_id 
        INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iui.item_id = iic.item_id
        INNER JOIN subscriber_common_tables.units u ON iui.unit_id = u.unit_id
        LEFT JOIN purchases_ap.deliveries d ON fd.for_delivery_id = d.for_delivery_id
        LEFT JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id 
        LEFT JOIN inventory.inventory_items ii ON iui.item_id = ii.item_id 
        WHERE ISNULL(d.for_delivery_id)
        AND (search = '' OR en.entity_name LIKE CONCAT('%', search, '%') OR iic.item_description LIKE CONCAT('%', search, '%') OR u.description COLLATE utf8_general_ci LIKE CONCAT('%', search, '%'))
        GROUP BY pm.po_id, en.entity_name, u.description, iic.item_id, iui.unit_item_id, iic.item_description, fd.date_confirmed, fdd.for_delivery_id
        ORDER BY fd.date_confirmed
    ) AS json_data;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInternalStocksMovementsReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInternalStocksMovementsReport`(IN inputJson JSON)
BEGIN
    DECLARE dateFrom DATE;
    DECLARE dateTo DATE;
    DECLARE dateTemp DATE;
    DECLARE unitListJSON JSON;
    DECLARE charUnitList VARCHAR(255);
    DECLARE stringCondition VARCHAR(1000);
    DECLARE stringOrderBy VARCHAR(255);
    DECLARE i INT DEFAULT 0;
    DECLARE arrayLength INT;
    DECLARE onlyZeroUnit BOOLEAN DEFAULT FALSE;

    SET dateFrom = STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(inputJson, '$.start_date')), '%Y-%m-%d');
    SET dateTo = STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(inputJson, '$.end_date')), '%Y-%m-%d');

    IF dateFrom > dateTo THEN
        SET dateTemp = dateFrom;
        SET dateFrom = dateTo;
        SET dateTo = dateTemp;
    END IF;

    SET unitListJSON = JSON_EXTRACT(inputJson, '$.units');
    SET arrayLength = JSON_LENGTH(unitListJSON);

    IF (arrayLength = 1 AND JSON_UNQUOTE(JSON_EXTRACT(unitListJSON, '$[0]')) = '0') OR arrayLength = 0 THEN
        SET onlyZeroUnit = TRUE;
    END IF;

    SET charUnitList = NULL;
    WHILE i < arrayLength DO
        SET charUnitList = CONCAT_WS(',', charUnitList, JSON_UNQUOTE(JSON_EXTRACT(unitListJSON, CONCAT('$[', i, ']'))));
        SET i = i + 1;
    END WHILE;

    SET stringCondition = CONCAT("DATE(a.adjustment_date) BETWEEN '", dateFrom, "' AND '", dateTo, "' ");

    IF onlyZeroUnit = FALSE AND charUnitList IS NOT NULL AND LENGTH(TRIM(charUnitList)) > 0 THEN
        SET stringCondition = CONCAT(stringCondition, " AND (dd.unit_id IN (", charUnitList, ") OR f.unit_id IN (", charUnitList, ")) ");
    END IF;

    SET stringOrderBy = " ORDER BY receiving_unit, a.adjustment_date, category, brand, item";

    DROP TEMPORARY TABLE IF EXISTS app_bin.internal_stocks_movements;

    SET @sqlCommand = CONCAT("CREATE TEMPORARY TABLE app_bin.internal_stocks_movements SELECT
            DATE_FORMAT(a.adjustment_date, '%Y %b %d') fmt_entry_date,
            COALESCE(dd.description, '') receiving_unit,
            b.description,
            COALESCE(d.category, h.category) category,
            COALESCE(d.brand, h.brand) brand,
            COALESCE(
                TRIM(CONCAT(d.model_description, d.item_size, d.item_ratio, d.item_thread_pattern, d.item_valve_type, d.item_part_description, d.item_part_number)),
                TRIM(CONCAT(h.model_description, h.item_size, h.item_ratio, h.item_thread_pattern, h.item_valve_type, h.item_part_description, h.item_part_number))
            ) item,
            a.quantity,
            CASE WHEN isu.warehouse = 1 THEN COALESCE(d.stocking_unit, h.stocking_unit) ELSE COALESCE(d.retail_unit, h.retail_unit) END AS stocking_unit,
            COALESCE(f.description, '') source_unit,
            a.remarks,
            su.full_name posted_by,
            a.adjustment_date,
            COALESCE(c.item_id, e.item_id) AS item_id
        FROM inventory.items_adjustments a
        INNER JOIN inventory.items_adjustments_templates b ON a.template_id = b.template_id
        LEFT JOIN inventory.inventory_units_items c ON a.destination_id = c.unit_item_id
        LEFT JOIN (
            SELECT aa.item_id,
                bb.description category,
                CONCAT(' ', cc.description) brand,
                CONCAT(' ', TRIM(aa.model_description)) model_description,
                COALESCE(CONCAT(' ', dd.description), '') item_size,
                COALESCE(CONCAT(' ', ee.description), '') item_ratio,
                COALESCE(CONCAT(' ', ff.description), '') item_thread_pattern,
                COALESCE(CONCAT(' ', gg.description), '') item_valve_type,
                COALESCE(CONCAT(' ', hh.description), '') item_part_description,
                COALESCE(CONCAT(' ', ii.description), '') item_part_number,
                aa.stocking_unit,
                aa.retail_unit
            FROM inventory.inventory_items aa
            INNER JOIN inventory.items_categories bb ON aa.item_category_id = bb.item_category_id
            INNER JOIN inventory.brands cc ON aa.brand_id = cc.brand_id
            LEFT JOIN inventory.sizes dd ON aa.size_id = dd.size_id
            LEFT JOIN inventory.ratios ee ON aa.ratio_id = ee.ratio_id
            LEFT JOIN inventory.thread_patterns ff ON aa.pattern_id = ff.pattern_id
            LEFT JOIN inventory.valve_types gg ON aa.valve_id = gg.valve_id
            LEFT JOIN inventory.vehicle_parts hh ON aa.part_id = hh.part_id
            LEFT JOIN inventory.vehicle_part_numbers ii ON aa.part_number_id = ii.part_number_id
        ) d ON c.item_id = d.item_id
        LEFT JOIN subscriber_common_tables.units dd ON c.unit_id = dd.unit_id
        LEFT JOIN inventory.inventory_units_items e ON a.source_id = e.unit_item_id
        LEFT JOIN subscriber_common_tables.units f ON e.unit_id = f.unit_id
        LEFT JOIN application_users_cerpsys_point_of_sales_ar.application_users g ON a.created_by = g.user_id
        LEFT JOIN (
            SELECT aa.item_id,
                bb.description category,
                CONCAT(' ', cc.description) brand,
                CONCAT(' ', TRIM(aa.model_description)) model_description,
                COALESCE(CONCAT(' ', dd.description), '') item_size,
                COALESCE(CONCAT(' ', ee.description), '') item_ratio,
                COALESCE(CONCAT(' ', ff.description), '') item_thread_pattern,
                COALESCE(CONCAT(' ', gg.description), '') item_valve_type,
                COALESCE(CONCAT(' ', hh.description), '') item_part_description,
                COALESCE(CONCAT(' ', ii.description), '') item_part_number,
                aa.stocking_unit,
                aa.retail_unit
            FROM inventory.inventory_items aa
            INNER JOIN inventory.items_categories bb ON aa.item_category_id = bb.item_category_id
            INNER JOIN inventory.brands cc ON aa.brand_id = cc.brand_id
            LEFT JOIN inventory.sizes dd ON aa.size_id = dd.size_id
            LEFT JOIN inventory.ratios ee ON aa.ratio_id = ee.ratio_id
            LEFT JOIN inventory.thread_patterns ff ON aa.pattern_id = ff.pattern_id
            LEFT JOIN inventory.valve_types gg ON aa.valve_id = gg.valve_id
            LEFT JOIN inventory.vehicle_parts hh ON aa.part_id = hh.part_id
            LEFT JOIN inventory.vehicle_part_numbers ii ON aa.part_number_id = ii.part_number_id
        ) h ON e.item_id = h.item_id
        LEFT JOIN inventory.inventory_units idu ON dd.unit_id = idu.unit_id
        LEFT JOIN inventory.inventory_units isu ON f.unit_id = isu.unit_id
        INNER JOIN application_users_inventory.subscribers_applications_user sau ON sau.user_id = g.user_id
        INNER JOIN application_users_inventory.subscribers_users su ON su.subscriber_user_id = sau.subscriber_user_id
        WHERE ", stringCondition, stringOrderBy);

    PREPARE query_statement FROM @sqlCommand;
    EXECUTE query_statement;
    DEALLOCATE PREPARE query_statement;

    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Records retrieved successfully.',
        'json_data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'fmt_entry_date', fmt_entry_date,
                    'receiving_unit', receiving_unit,
                    'description', description,
                    'category', category,
                    'brand', brand,
                    'item', item,
                    'quantity', FORMAT(quantity, 2),
                    'stocking_unit', stocking_unit,
                    'source_unit', source_unit,
                    'remarks', remarks,
                    'posted_by', posted_by,
                    'adjustment_date', adjustment_date,
                    'item_id', item_id
                )
            ),
            JSON_ARRAY()
        )
    ) AS response
    FROM app_bin.internal_stocks_movements;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInTransitItemsInvoices` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInTransitItemsInvoices`(IN jsnInTransitItemsInvoices JSON)
BEGIN
	DECLARE bolGetOne BOOLEAN;
	DECLARE intInvoiceId INT;
	DECLARE intUserId INT;
	DECLARE charInvoiceReference VARCHAR(100);
	DECLARE whereCredentials VARCHAR(500);

	IF JSON_VALID(jsnInTransitItemsInvoices) THEN
		SET bolGetOne = JSON_VALUE(jsnInTransitItemsInvoices, "$.bol_getone");
		SET intInvoiceId = JSON_VALUE(jsnInTransitItemsInvoices, "$.invoice_id");
		SET intUserId = JSON_VALUE(jsnInTransitItemsInvoices, "$.user_id");
		SET charInvoiceReference = JSON_UNQUOTE(JSON_EXTRACT(jsnInTransitItemsInvoices, "$.invoice_reference"));

		IF bolGetOne THEN
			SET whereCredentials = CONCAT("AND pi2.invoice_id = ",intInvoiceId);
		ELSE
			IF charInvoiceReference <> '' THEN
				SET whereCredentials = CONCAT("AND LOWER(invoice_reference) LIKE CONCAT('%',LOWER('",charInvoiceReference,"'),'%')");
			ELSE
				SET whereCredentials = "";
			END IF;
		END IF;

		SET @query_statement = CONCAT("
			SELECT JSON_OBJECT(
				'success', TRUE,
				'message', 'In-transit item invoices retrieved successfully.',
				'json_data', JSON_ARRAYAGG(
					JSON_OBJECT(
						'invoice_id', aa.invoice_id,
						'invoice_reference', aa.invoice_reference,
						'in_transit_items', aa.in_transit_items
					) ORDER BY aa.invoice_reference
				)
			) AS response
			FROM (
				SELECT
					pi2.invoice_id,
					pi2.invoice_reference,
					JSON_ARRAYAGG(
						JSON_OBJECT(
							'item_id', iti.item_id,
							'unit_item_id', iti.unit_item_id,
							'item_description', iic.item_description,
							'total_running_quantity', iti.total_running_quantity
						)
					) AS in_transit_items
				FROM purchases_ap.pos_invoices pi2
				INNER JOIN inventory.in_transit_items iti ON iti.invoice_id = pi2.invoice_id
				INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iic.unit_item_id = iti.unit_item_id
				INNER JOIN applications_users.application_users au ON au.user_id = ",intUserId,"
				WHERE iti.total_running_quantity > 0
					AND au.unit_id IN (
						SELECT unit_id FROM applications_users.application_users WHERE user_id = ?
					)
					",whereCredentials,"
				GROUP BY pi2.invoice_id, pi2.invoice_reference
			) aa
		");

		PREPARE query_statement FROM @query_statement;
		EXECUTE query_statement USING intUserId;
		DEALLOCATE PREPARE query_statement;
	ELSE
		SELECT JSON_OBJECT(
			'success', FALSE,
			'message', 'Invalid JSON parameter.',
			'json_data', NULL
		) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInTransitReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInTransitReport`()
BEGIN
	DROP TEMPORARY TABLE IF EXISTS purchases_ap.po_in_transits;
	CREATE TEMPORARY TABLE purchases_ap.po_in_transits (
		po_id INT,
		INDEX po_in_transits_po_id (po_id)
	)
	SELECT DISTINCT fd.po_id
	FROM purchases_ap.for_deliveries fd
	LEFT JOIN purchases_ap.deliveries d ON d.for_delivery_id = fd.for_delivery_id
	WHERE ISNULL(d.for_delivery_id);

	SELECT JSON_OBJECT(
		'success', TRUE,
		'message', 'In-transit report retrieved successfully.',
		'json_data', JSON_ARRAYAGG(
			JSON_OBJECT(
				'po_id', pm.po_id,
				'entity_name', en.entity_name,
				'deliver_to', u.description,
				'item_id', iic.item_id,
				'unit_item_id', iui.unit_item_id,
				'item_description', iic.item_description,
				'date_confirmed', fd.date_confirmed,
				'quantity', fdd.quantity,
				'unit_cost', fdd.unit_cost,
				'total_cost', fdd.total_cost
			)
		)
	) AS response
	FROM purchases_ap.for_deliveries_details fdd
	INNER JOIN purchases_ap.for_deliveries fd ON fd.for_delivery_id = fdd.for_delivery_id
	INNER JOIN purchases_ap.po_main pm ON pm.po_id = fd.po_id
	INNER JOIN entities.entity_name en ON en.entity_id = pm.entity_id
	INNER JOIN applications_users.units u ON u.unit_id = pm.unit_id
	INNER JOIN inventory.inventory_unit_items iui ON iui.unit_item_id = fdd.unit_item_id
	INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iic.unit_item_id = iui.unit_item_id
	LEFT JOIN purchases_ap.deliveries d ON d.for_delivery_id = fd.for_delivery_id
	WHERE ISNULL(d.for_delivery_id);
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryItem`(
    IN jsnInventoryItem JSON
)
BEGIN
    DECLARE whereCredentials VARCHAR(500);
    DECLARE bolProceed BOOLEAN DEFAULT FALSE;

    DECLARE bolGetOne BOOLEAN;
    DECLARE intItemCategoryId INT;
    DECLARE intItemId INT;
    DECLARE charItemDescription VARCHAR(100);
    DECLARE charBarcode VARCHAR(100) DEFAULT NULL;
    DECLARE bolExactMatchExists BOOLEAN DEFAULT FALSE;
    DECLARE bolBypassImageFilter BOOLEAN DEFAULT FALSE;

    
    
    
    
    
    
    
    

    
    SET SESSION group_concat_max_len = 104857600;

    IF JSON_VALID(jsnInventoryItem) THEN
        SET bolProceed = TRUE;
    END IF;

    IF bolProceed THEN
        SET bolGetOne = JSON_VALUE(jsnInventoryItem, '$.bol_getone');
        
        SET intItemCategoryId = NULLIF(JSON_VALUE(jsnInventoryItem, '$.item_category_id'), 0);
        SET intItemId = JSON_VALUE(jsnInventoryItem, '$.item_id');
        SET charItemDescription = JSON_VALUE(jsnInventoryItem, '$.item_description');	
        
        
        SET charBarcode = JSON_UNQUOTE(JSON_EXTRACT(jsnInventoryItem, '$.barcode'));
        IF charBarcode = '' OR charBarcode = 'null' THEN SET charBarcode = NULL; END IF;
        
        SET bolBypassImageFilter = COALESCE(JSON_VALUE(jsnInventoryItem, '$.bypass_image_filter'), FALSE);
    
        
        IF bolGetOne THEN
            SET whereCredentials = CONCAT('WHERE ii.item_id = ', intItemId);
            IF intItemCategoryId IS NOT NULL THEN
                SET whereCredentials = CONCAT(whereCredentials, ' AND ii.item_category_id = ', intItemCategoryId);
            END IF;
        ELSE
            
            SET whereCredentials = 'WHERE 1=1';

            IF charBarcode IS NOT NULL THEN
                
                SET bolExactMatchExists = FALSE;
                SELECT EXISTS(
                    SELECT 1 
                    FROM inventory.inventory_item_barcodes 
                    WHERE barcode_value = charBarcode COLLATE utf8mb4_general_ci 
                       OR barcode_value = CONCAT(charBarcode, '-CASE') COLLATE utf8mb4_general_ci
                ) INTO bolExactMatchExists;

                IF bolExactMatchExists THEN
                    SET whereCredentials = CONCAT(whereCredentials, ' AND (bc.all_barcodes LIKE ''%', charBarcode, '%'')');
                ELSE
                    
                    
                    IF LENGTH(charBarcode) = 13 THEN
                        SET @barcodePrefix = LEFT(charBarcode, 12);
                        SET whereCredentials = CONCAT(whereCredentials, ' AND (bc.all_barcodes LIKE ''%', charBarcode, '%'' OR bc.all_barcodes LIKE ''%', @barcodePrefix, '%'')');
                    
                    ELSEIF LENGTH(charBarcode) = 12 THEN
                        SET @barcodePrefix = LEFT(charBarcode, 11);
                        SET whereCredentials = CONCAT(whereCredentials, ' AND (bc.all_barcodes LIKE ''%', charBarcode, '%'' OR bc.all_barcodes LIKE ''%', @barcodePrefix, '%'')');
                    
                    ELSEIF LENGTH(charBarcode) = 8 THEN
                        SET @barcodePrefix = LEFT(charBarcode, 7);
                        SET whereCredentials = CONCAT(whereCredentials, ' AND (bc.all_barcodes LIKE ''%', charBarcode, '%'' OR bc.all_barcodes LIKE ''%', @barcodePrefix, '%'')');
                    ELSE
                        SET whereCredentials = CONCAT(whereCredentials, ' AND bc.all_barcodes LIKE ''%', charBarcode, '%''');
                    END IF;
                END IF;
            END IF;

            IF charItemDescription <> '' THEN
                SET whereCredentials = CONCAT(whereCredentials, ' AND LOWER(iic.item_description) LIKE CONCAT(\'%\', LOWER(\'', charItemDescription, '\'), \'%\')');
            END IF;
            
            IF intItemCategoryId IS NOT NULL THEN
                SET whereCredentials = CONCAT(whereCredentials, ' AND ii.item_category_id = ', intItemCategoryId);
            ELSE
                
                IF charBarcode IS NULL AND (charItemDescription IS NULL OR charItemDescription = '') AND NOT bolBypassImageFilter THEN
                    SET whereCredentials = CONCAT(whereCredentials, ' AND (img.item_id IS NULL OR img.image IS NULL OR CAST(img.image AS CHAR) = '''')');
                END IF;
            END IF;
        END IF;
    
        SET @sqlCommand = CONCAT('
            SELECT JSON_OBJECT(
                \'success\', TRUE,
                \'message\', \'Inventory items retrieved successfully.\',
                \'json_data\', JSON_ARRAYAGG(
                    JSON_OBJECT(
                        \'item_id\', ii.item_id,
                        \'item_description\', iic.item_description,
                        \'item_category_id\', ii.item_category_id,
                        \'item_category\', ic.description,
                        \'brand_id\', ii.brand_id,
                        \'brand\', b.description,
                        \'model_description\', ii.model_description,
                        \'part_id\', ii.part_id,
                        \'vehicle_parts\', vp.description,
                        \'part_number_id\', ii.part_number_id,
                        \'vehicle_part_number\', vpn.description,
                        \'size_id\', ii.size_id,
                        \'size\', s.description,
                        \'valve_id\', ii.valve_id,
                        \'valve_type\', vt.description,
                        \'ratio_id\', ii.ratio_id,
                        \'ratio\', r.description,
                        \'pattern_id\', ii.pattern_id,
                        \'thread_pattern\', tp.description,
                        \'stocking_unit\', ii.stocking_unit,
                        \'retail_unit\', ii.retail_unit,
                        \'rtu_over_stu\', ii.rtu_over_stu,
                        \'wtd_ave_cost\', ii.wtd_ave_cost,
                        \'markup_rate\', (ii.markup_rate * 100),
                        \'selling_price\', FORMAT(ii.selling_price,2),
                        \'last_highest_in_unit_cost\', ii.last_highest_in_unit_cost,
                        \'whole_quantity\', COALESCE(wq.whole_quantity, CONCAT(\'0.00 \', ii.stocking_unit, \' & 0.00 \', ii.retail_unit)),
                        \'in_unit_item\', !ISNULL(wq.item_id),
                        \'created_by\', ii.created_by,
                        \'datetime_created\', ii.datetime_created,
                        \'modified_by\', ii.modified_by,
                        \'datetime_modified\', ii.datetime_modified,
                        \'is_empty_case\', iec.empty_item_id,
                        \'image\', CAST(img.image AS CHAR),
                        \'barcodes\', bc.barcodes_json
                    ) ORDER BY ii.datetime_created DESC, iic.item_description
                )
            ) AS response
            FROM 
                inventory.inventory_items ii
            LEFT JOIN
                inventory_udf_and_views.inventory_item_concat iic 
            ON
                ii.item_id = iic.item_id
            LEFT JOIN
                inventory.items_categories ic
            ON
                ii.item_category_id = ic.item_category_id 
            LEFT JOIN 	
                inventory.brands b 
            ON
                ii.brand_id = b.brand_id 
            LEFT JOIN 	
                inventory.sizes s 
            ON
                ii.size_id = s.size_id 
            LEFT JOIN 
                inventory.ratios r 
            ON
                ii.ratio_id = r.ratio_id 
            LEFT JOIN 
                inventory.thread_patterns tp 
            ON
                ii.pattern_id = tp.pattern_id 
            LEFT JOIN 
                inventory.valve_types vt 
            ON
                ii.valve_id = vt.valve_id 
            LEFT JOIN 
                inventory.vehicle_parts vp 
            ON
                ii.part_id = vp.part_id 
            LEFT JOIN 
                inventory.vehicle_part_numbers vpn 
            ON
                ii.part_number_id = vpn.part_number_id
            LEFT JOIN
                inventory.item_images img
            ON
                ii.item_id = img.item_id
            LEFT JOIN 
                (
                    SELECT 
                        item_id,
                        JSON_ARRAYAGG(JSON_OBJECT(\'barcode_value\', barcode_value, \'barcode_type\', barcode_type)) AS barcodes_json,
                        GROUP_CONCAT(barcode_value) as all_barcodes
                    FROM 
                        inventory.inventory_item_barcodes
                    GROUP BY 
                        item_id
                ) AS bc
            ON 
                ii.item_id = bc.item_id
            LEFT JOIN 
                (
                    SELECT 
                        iui.item_id,
                        CONCAT(FORMAT(SUM(IF(iu.warehouse, COALESCE(iui.ending_quantity, 0), 0)), 2), \' \', ii.stocking_unit, \' & \', FORMAT(SUM(IF(iu.warehouse, 0, COALESCE(iui.ending_quantity, 0))), 2), \' \', ii.retail_unit) AS whole_quantity
                    FROM 
                        inventory.inventory_units_items iui
                    INNER JOIN
                        inventory.inventory_items ii 
                    ON
                        iui.item_id = ii.item_id 
                    INNER JOIN
                        inventory.inventory_units iu 
                    ON
                        iui.unit_id = iu.unit_id
                    GROUP BY
                        iui.item_id
                ) AS wq
            ON
                ii.item_id = wq.item_id
            LEFT JOIN 
                inventory.inventory_empty_cases iec 
            ON 
                iec.empty_item_id = ii.item_id 
            ', whereCredentials, ';'
        );
        
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement;
        DEALLOCATE PREPARE query_statement;
        
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON parameter.',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryItemAdjustment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryItemAdjustment`(
	IN jsnInventoryItemAdjustment JSON
)
BEGIN
	IF JSON_VALID(jsnInventoryItemAdjustment) THEN
		SET @bolGetOne = JSON_VALUE(jsnInventoryItemAdjustment, "$.bol_getone");
		SET @intAdjustmentId = JSON_VALUE(jsnInventoryItemAdjustment, "$.adjustment_id");
		SET @dteDateFrom = JSON_VALUE(jsnInventoryItemAdjustment, "$.date_from");
		SET @dteDateTo = JSON_VALUE(jsnInventoryItemAdjustment, "$.date_to");

		IF @bolGetOne THEN
			SET @whereCredentials = CONCAT("WHERE ia.adjustment_id = ",@intAdjustmentId);
		ELSE
			SET @whereCredentials = CONCAT("WHERE DATE(ia.adjustment_date) BETWEEN '",@dteDateFrom,"' AND '",@dteDateTo,"'");
		END IF;

		SET @sqlStmt = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory item adjustments retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('adjustment_id', ia.adjustment_id, 'adjustment_date', ia.adjustment_date, 'frmt_adjustment_date', DATE_FORMAT(ia.adjustment_date, '%Y %b %d %a'), 'template_id', ia.template_id, 'template', iat.description, 'destination_id', ia.destination_id, 'destination_unit', u.description, 'source_id', ia.source_id, 'source_unit', u2.description, 'item_id', ia.item_id, 'item_description', iic.item_description, 'quantity', FORMAT(ia.quantity,2), 'unit_cost', FORMAT(ia.unit_cost,2), 'total_cost', FORMAT((ia.unit_cost * ia.quantity),2), 'remarks', ia.remarks, 'created_by', ia.created_by, 'datetime_created', ia.datetime_created, 'batch_id', ia.batch_id) ORDER BY ia.adjustment_date)) AS response FROM inventory.items_adjustments ia INNER JOIN inventory.items_adjustments_templates iat ON ia.template_id = iat.template_id LEFT JOIN inventory.inventory_units_items iui ON ia.destination_id = iui.unit_item_id LEFT JOIN subscriber_common_tables.units u ON iui.unit_id = u.unit_id LEFT JOIN inventory.inventory_units_items iui2 ON ia.source_id = iui2.unit_item_id LEFT JOIN subscriber_common_tables.units u2 ON iui2.unit_id = u2.unit_id LEFT JOIN inventory_udf_and_views.inventory_item_concat iic ON ia.item_id = iic.item_id ",@whereCredentials,";");

		PREPARE stmt FROM @sqlStmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryItemAdjustmentTemplate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryItemAdjustmentTemplate`(
	IN jsnInventoryItemAdjustmentTemplate JSON
)
BEGIN
	IF JSON_VALID(jsnInventoryItemAdjustmentTemplate) THEN
		SET @bolGetOne = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, "$.bol_getone");
		SET @intTemplateId = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, "$.template_id");
		SET @charDescription = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, "$.description");

		IF @bolGetOne THEN
			SET @whereCredentials = CONCAT("WHERE iat.template_id = ",@intTemplateId);
		ELSEIF @charDescription <> '' THEN
			SET @whereCredentials = CONCAT("WHERE LOWER(iat.description) LIKE CONCAT('%',LOWER('",@charDescription,"'),'%')");
		ELSE
			SET @whereCredentials = "";
		END IF;

		SET @sqlStmt = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory item adjustment templates retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('deleteable', ISNULL(ia.adjustment_id), 'template_id', iat.template_id, 'template_ind', CASE WHEN iat.add_to_quantity AND iat.require_destination_and_source THEN 0 WHEN iat.add_to_quantity AND !iat.require_destination_and_source THEN 1 WHEN !iat.add_to_quantity AND !iat.require_destination_and_source THEN 2 ELSE 99 END, 'description', iat.description, 'add_to_quantity', iat.add_to_quantity, 'add_to_quantity_desc', IF(iat.add_to_quantity, 'Yes', 'No'), 'require_destination_and_source', iat.require_destination_and_source, 'require_destination_and_source_desc', IF(iat.require_destination_and_source, 'Yes', 'No'), 'created_by', iat.created_by, 'creator', au.user_login_name, 'datetime_created', iat.datetime_created, 'frmt_datetime_created', DATE_FORMAT(iat.datetime_created, '%Y %b %d %a'), 'modified_by', iat.modified_by, 'modifier', au2.user_login_name, 'datetime_modified', iat.datetime_modified, 'frmt_datetime_modified', DATE_FORMAT(iat.datetime_modified , '%Y %b %d %a')) ORDER BY iat.datetime_created ,iat.description)) AS response FROM inventory.items_adjustments_templates iat INNER JOIN application_users_inventory.application_users au ON iat.created_by = au.user_id LEFT JOIN application_users_inventory.application_users au2 ON iat.modified_by = au2.user_id LEFT JOIN ( SELECT ia.template_id, ia.adjustment_id FROM inventory.items_adjustments ia GROUP BY ia.template_id ) AS ia ON iat.template_id = ia.template_id ",@whereCredentials,";");

		PREPARE stmt FROM @sqlStmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryItemCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryItemCategory`(
	IN jsnInventoryItemCategory JSON
)
BEGIN
	IF JSON_VALID(jsnInventoryItemCategory) THEN
		SET @bolGetOne = JSON_VALUE(jsnInventoryItemCategory, "$.bol_getone");
		SET @intItemCategoryId = JSON_VALUE(jsnInventoryItemCategory, "$.item_category_id");
		SET @charDescription = JSON_VALUE(jsnInventoryItemCategory, "$.description");

		IF @bolGetOne THEN
			SET @whereCredentials = CONCAT("WHERE ic.item_category_id = ",@intItemCategoryId);
		ELSEIF @charDescription <> '' THEN
			SET @whereCredentials = CONCAT("WHERE LOWER(ic.description) LIKE CONCAT('%',LOWER('",@charDescription,"'),'%')");
		ELSE
			SET @whereCredentials = "WHERE !ic.predefined"; 
		END IF;

		SET @sqlStmt = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory item categories retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('predefined', ic.predefined, 'item_category_id', ic.item_category_id, 'description', ic.description, 'glsl_id', icgi.glsl_item, 'glsl_item_elab', sac.account, 'glsl_item', sac.search_account) ORDER BY ic.predefined DESC, ic.description)) AS response FROM inventory.items_categories ic LEFT JOIN inventory.item_category_glsl_item icgi ON ic.item_category_id = icgi.item_category_id LEFT JOIN accounting.selectable_account_concatenated sac ON icgi.glsl_item = sac.glsl_id ",@whereCredentials,";");

		PREPARE stmt FROM @sqlStmt;
		EXECUTE stmt;
		DEALLOCATE PREPARE stmt;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryItemNoUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryItemNoUnit`(
		IN jsnInventoryItemNoUnit JSON
	)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE intUnitId INT;
	DECLARE intItemCategoryId INT;
	DECLARE charItemDescription VARCHAR(100);
	SET @sampleJSON="{ \"unit_id\":1, \"item_category_id\":1, \"item_description\":\"James\" }";	
	IF JSON_VALID(jsnInventoryItemNoUnit) THEN
		SET bolProceed = TRUE;
	END IF;
	IF bolProceed THEN
		SET intUnitId = JSON_VALUE(jsnInventoryItemNoUnit, '$.unit_id');
		SET intItemCategoryId = JSON_VALUE(jsnInventoryItemNoUnit, '$.item_category_id');
		SET charItemDescription = JSON_VALUE(jsnInventoryItemNoUnit, '$.item_description');	
		IF bolProceed THEN		
			SET @sqlCommand =  "SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory items without unit retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT(
			    'item_id', ii.item_id,
			    'item_description', iic.item_description,
			    'item_category_id', ii.item_category_id
			) ORDER BY iic.item_description)) AS response
			FROM inventory.inventory_items ii
			INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON ii.item_id = iic.item_id
			WHERE ii.item_category_id = ? AND LOWER(iic.item_description) LIKE CONCAT('%',LOWER(?),'%') AND ii.item_id NOT IN (
				SELECT iui.item_id FROM inventory.inventory_units_items iui WHERE unit_id = ?
			);";
			PREPARE query_statement FROM @sqlCommand;
			EXECUTE query_statement USING intItemCategoryId, charItemDescription, intUnitId;
			DEALLOCATE PREPARE query_statement;
		END IF;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryList`(
    IN jsonParams JSON
)
BEGIN
    DECLARE charUnitList VARCHAR(255);
    DECLARE bolWithCost BOOLEAN;
    DECLARE stringCondition VARCHAR(255);
    DECLARE stringOrderBy VARCHAR(255);
    DECLARE stringFields VARCHAR(1024);

    
    SET charUnitList = JSON_UNQUOTE(JSON_EXTRACT(jsonParams, '$.units'));
    SET charUnitList = REPLACE(REPLACE(charUnitList, '[', ''), ']', '');

    SET bolWithCost = IFNULL(JSON_EXTRACT(jsonParams, '$.withCost'), FALSE);

    SET stringCondition = "";
    
    
    IF charUnitList IS NOT NULL AND charUnitList NOT IN ('', '0', 'null') THEN
        SET stringCondition = CONCAT(" AND b.unit_id IN (", charUnitList, ")");
    END IF;

    SET stringOrderBy = " ORDER BY warehouse_store, category, brand, item";

    
    IF bolWithCost THEN
        SET stringFields = "CREATE TEMPORARY TABLE app_bin.master_inventory_list
            SELECT 
                COALESCE(u.description, '') AS warehouse_store, 
                COALESCE(ic.description, '') AS category, 
                COALESCE(br.description, '') AS brand, 
                COALESCE(iic.item_description, '') AS item, 
                a.ending_quantity, 
                IF(b.warehouse = 1, ii.stocking_unit, ii.retail_unit) AS unit, 
                a.ending_cost AS inventory_cost, 
                ii.rtu_over_stu, 
                ii.stocking_unit, 
                ii.retail_unit, 
                b.unit_id, 
                ii.item_category_id, 
                ii.brand_id, 
                ii.item_id ";
    ELSE
        SET stringFields = "CREATE TEMPORARY TABLE app_bin.master_inventory_list
            SELECT 
                COALESCE(u.description, '') AS warehouse_store, 
                COALESCE(ic.description, '') AS category, 
                COALESCE(br.description, '') AS brand, 
                COALESCE(iic.item_description, '') AS item, 
                a.ending_quantity, 
                IF(b.warehouse = 1, ii.stocking_unit, ii.retail_unit) AS unit, 
                0.00 AS inventory_cost, 
                ii.rtu_over_stu, 
                ii.stocking_unit, 
                ii.retail_unit, 
                b.unit_id, 
                ii.item_category_id, 
                ii.brand_id, 
                ii.item_id ";
    END IF;

    DROP TEMPORARY TABLE IF EXISTS app_bin.master_inventory_list;

    
    SET @sqlCommand = " FROM inventory.inventory_units_items a
        INNER JOIN inventory.inventory_units b ON a.unit_id = b.unit_id
        LEFT JOIN subscriber_common_tables.units u ON b.unit_id = u.unit_id
        INNER JOIN inventory.inventory_items ii ON a.item_id = ii.item_id
        INNER JOIN inventory.items_categories ic ON ii.item_category_id = ic.item_category_id
        INNER JOIN inventory.brands br ON ii.brand_id = br.brand_id
        INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON a.item_id = iic.item_id
        WHERE a.ending_quantity <> 0 ";

    SET @sqlQueryFinal = CONCAT(stringFields, @sqlCommand, stringCondition, stringOrderBy);
    PREPARE query_statement FROM @sqlQueryFinal;
    EXECUTE query_statement;
    DEALLOCATE PREPARE query_statement;

    
    SELECT JSON_OBJECT(
        'success', TRUE, 
        'message', 'Inventory list retrieved successfully.', 
        'json_data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'warehouse_store', warehouse_store,
                    'category', category,
                    'brand', brand,
                    'item', item,
                    'ending_quantity', FORMAT(ending_quantity, 2),
                    'unit', unit,
                    'inventory_cost', FORMAT(inventory_cost, 2),
                    'rtu_over_stu', FORMAT(rtu_over_stu, 2),
                    'retail_unit', retail_unit,
                    'stocking_unit', stocking_unit,
                    'unit_id', unit_id,
                    'category_id', item_category_id,
                    'brand_id', brand_id,
                    'item_id', item_id
                )
            ), 
            JSON_ARRAY()
        )
    ) AS response 
    FROM app_bin.master_inventory_list;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryUnit`(
		IN jsnInventoryUnit JSON
	)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE bolGetOne BOOLEAN;
	DECLARE intUnitId INT;
	DECLARE charDescription VARCHAR(100);

	IF JSON_VALID(jsnInventoryUnit) THEN
		SET bolProceed = TRUE;
	END IF;

	IF bolProceed THEN
		SET bolGetOne = JSON_EXTRACT(jsnInventoryUnit, '$.bol_getone');
		SET intUnitId = JSON_EXTRACT(jsnInventoryUnit, '$.unit_id');
		SET charDescription = JSON_UNQUOTE(JSON_EXTRACT(jsnInventoryUnit, '$.description'));

		IF bolGetOne THEN
			SET whereCredentials = CONCAT("WHERE aa.unit_id = ", intUnitId);
		ELSE
			IF charDescription <> '' THEN
				SET whereCredentials = CONCAT("WHERE LOWER(aa.unit) LIKE CONCAT('%', LOWER('", charDescription, "'), '%')");
			ELSE
				SET whereCredentials = "";
			END IF;
		END IF;

		SET @sqlCommand = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory unit retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('unit_id', aa.unit_id, 'unit', aa.unit, 'warehouse', aa.warehouse, 'is_warehouse', aa.is_warehouse, 'person_in_charge_id', aa.person_in_charge_id, 'person_in_charge', aa.person_in_charge) ORDER BY aa.unit)) AS response FROM (SELECT iu.unit_id, u.description AS unit, iu.warehouse, IF(iu.warehouse, 'Yes', 'No') AS is_warehouse, iu.person_in_charge AS person_in_charge_id, IF(!ISNULL(en.entity_name), en.entity_name, iu.person_name) AS person_in_charge FROM inventory.inventory_units iu INNER JOIN subscriber_common_tables.units u ON iu.unit_id = u.unit_id LEFT JOIN employees_profile.employees e ON iu.person_in_charge = e.employee_id LEFT JOIN entities_udf_and_views.entity_name en ON e.entity_id = en.entity_id) AS aa ", whereCredentials, ";");

		PREPARE query_statement FROM @sqlCommand;
		EXECUTE query_statement;
		DEALLOCATE PREPARE query_statement;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryUnitBin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryUnitBin`(
		IN jsnInventoryUnitBin JSON
	)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE bolGetOne BOOLEAN;
	DECLARE intBinId INT;
	DECLARE intUnitId INT;
	DECLARE charDescription VARCHAR(100);

	IF JSON_VALID(jsnInventoryUnitBin) THEN
		SET bolProceed = TRUE;
	END IF;

	IF bolProceed THEN
		SET bolGetOne = JSON_EXTRACT(jsnInventoryUnitBin, '$.bol_getone');
		SET intBinId = JSON_EXTRACT(jsnInventoryUnitBin, '$.bin_id');
		SET intUnitId = JSON_EXTRACT(jsnInventoryUnitBin, '$.unit_id');
		SET charDescription = JSON_UNQUOTE(JSON_EXTRACT(jsnInventoryUnitBin, '$.description'));

		IF bolGetOne THEN
			SET whereCredentials = CONCAT("WHERE ub.unit_id = ", intUnitId, " AND ub.bin_id = ", intBinId);
		ELSE
			IF charDescription <> '' THEN
				SET whereCredentials = CONCAT("WHERE ub.unit_id = ", intUnitId, " AND LOWER(ub.description) LIKE CONCAT('%', LOWER('", charDescription, "'), '%')");
			ELSE
				SET whereCredentials = CONCAT("WHERE ub.unit_id = ", intUnitId);
			END IF;
		END IF;

		SET @sqlCommand = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory unit bin retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('bin_id', ub.bin_id, 'description', ub.description, 'unit_id', ub.unit_id, 'unit', u.description, 'created_by', ub.created_by, 'creator', au.user_login_name, 'datetime_created', ub.datetime_created, 'frmt_datetime_created', DATE_FORMAT(ub.datetime_created, '%Y %b %d %a'), 'modified_by', ub.modified_by, 'modifier', au2.user_login_name, 'datetime_modified', ub.datetime_modified, 'frmt_datetime_modified', DATE_FORMAT(ub.datetime_modified, '%Y %b %d %a')) ORDER BY ub.datetime_created, ub.description)) AS response FROM inventory.unit_bins ub INNER JOIN subscriber_common_tables.units u ON ub.unit_id = u.unit_id INNER JOIN application_users_inventory.application_users au ON ub.created_by = au.user_id LEFT JOIN application_users_inventory.application_users au2 ON ub.modified_by = au2.user_id ", whereCredentials, ";");

		PREPARE query_statement FROM @sqlCommand;
		EXECUTE query_statement;
		DEALLOCATE PREPARE query_statement;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getInventoryUnitItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getInventoryUnitItem`(
		IN jsnInventoryUnitItem JSON
	)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE bolGetOne BOOLEAN;
	DECLARE intUnitId INT;
	DECLARE intItemCategoryId INT;
	DECLARE intUnitItemId INT;
	DECLARE charItemDescription VARCHAR(100);

	IF JSON_VALID(jsnInventoryUnitItem) THEN 
        SET bolProceed = TRUE; 
    END IF;

	IF bolProceed THEN
		SET bolGetOne = JSON_VALUE(jsnInventoryUnitItem, '$.bol_getone');
        
		-- FIX: Using NULLIF to convert 0 to NULL. 
        -- This allows the ISNULL() checks below to safely skip the filters.
		SET intUnitId = NULLIF(JSON_VALUE(jsnInventoryUnitItem, '$.unit_id'), 0);
		SET intItemCategoryId = NULLIF(JSON_VALUE(jsnInventoryUnitItem, '$.item_category_id'), 0);
        
		SET intUnitItemId = JSON_VALUE(jsnInventoryUnitItem, '$.unit_item_id');
		SET charItemDescription = JSON_VALUE(jsnInventoryUnitItem, '$.item_description');

		IF bolGetOne THEN
			SET whereCredentials = CONCAT("WHERE ", IF(ISNULL(intUnitId), "", CONCAT("u.unit_id = ", intUnitId, " AND ")), IF(ISNULL(intItemCategoryId), "", CONCAT("ii.item_category_id = ", intItemCategoryId, " AND ")), "iui.unit_item_id = ", intUnitItemId);
		ELSE
			IF charItemDescription <> '' THEN
				SET whereCredentials = CONCAT("WHERE ", IF(ISNULL(intUnitId), "", CONCAT("u.unit_id = ", intUnitId, " AND ")), IF(ISNULL(intItemCategoryId), "", CONCAT("ii.item_category_id = ", intItemCategoryId, " AND ")), "LOWER(iic.item_description) LIKE CONCAT('%', LOWER('", charItemDescription, "'), '%')");
			ELSE
				SET whereCredentials = CONCAT(IF(!ISNULL(intUnitId) OR !ISNULL(intItemCategoryId), "WHERE ", ""), IF(ISNULL(intUnitId), "", CONCAT("u.unit_id = ", intUnitId, IF(ISNULL(intItemCategoryId), "", " AND "))), IF(ISNULL(intItemCategoryId), "", CONCAT("ii.item_category_id = ", intItemCategoryId)));
			END IF;
		END IF;

		SET @sqlCommand = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Inventory unit item retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('unit_item_id', iui.unit_item_id, 'is_used', IF(uic.unit_item_id IS NOT NULL, 1, 0), 'item_id', iui.item_id, 'item_description', iic.item_description, 'item_category_id', ii.item_category_id, 'item_category', ic.description, 'unit_id', iui.unit_id, 'unit', u.description, 'bin_id', ub.bin_id, 'bin', ub.description, 'starting_period', iui.starting_period, 'last_entry', iui.last_entry, 'starting_quantity', FORMAT(iui.starting_quantity, 2), 'quantity_in', FORMAT(iui.quantity_in, 2), 'quantity_out', FORMAT(iui.quantity_out, 2), 'ending_quantity', FORMAT(iui.ending_quantity, 2), 'starting_cost', FORMAT(iui.starting_cost, 2), 'cost_in', FORMAT(iui.cost_in, 2), 'cost_out', FORMAT(iui.cost_out, 2), 'ending_cost', FORMAT(iui.ending_cost, 2), 'unit_cost', FORMAT(iui.unit_cost, 2), 'last_highest_in_unit_cost', FORMAT(iui.last_highest_in_unit_cost, 2), 'created_by', iui.created_by, 'datetime_created', iui.datetime_created, 'modified_by', iui.modified_by, 'datetime_modified', iui.datetime_modified) ORDER BY iui.datetime_created, u.description, iic.item_description)) AS response FROM inventory.inventory_units_items iui INNER JOIN subscriber_common_tables.units u ON iui.unit_id = u.unit_id INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iui.item_id = iic.item_id INNER JOIN inventory.inventory_items ii ON iui.item_id = ii.item_id INNER JOIN inventory.items_categories ic ON ii.item_category_id = ic.item_category_id INNER JOIN inventory.unit_bins ub ON iui.bin_id = ub.bin_id LEFT JOIN inventory_udf_and_views.unit_item_checking uic ON iui.unit_item_id = uic.unit_item_id LEFT JOIN inventory.inventory_empty_cases iec ON iec.empty_item_id = ii.item_id ", whereCredentials, ";");
		
        PREPARE query_statement FROM @sqlCommand; 
        EXECUTE query_statement; 
        DEALLOCATE PREPARE query_statement;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getItemForAdjustment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getItemForAdjustment`(
		IN jsnItemForAdjustment JSON
	)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE intTemplateId INT;
	DECLARE intSourceUnitId INT;
	DECLARE intDestinationUnitId INT;
	DECLARE charItemDescription VARCHAR(100);
	IF JSON_VALID(jsnItemForAdjustment) THEN SET bolProceed = TRUE; END IF;
	IF bolProceed THEN
		SET intTemplateId = JSON_VALUE(jsnItemForAdjustment, '$.template_id');
		SET intSourceUnitId = JSON_VALUE(jsnItemForAdjustment, '$.source_unit_id');
		SET intDestinationUnitId = JSON_VALUE(jsnItemForAdjustment, '$.destination_unit_id');
		SET charItemDescription = JSON_VALUE(jsnItemForAdjustment, '$.item_description');
		SET @TempInd = NULL;
		SET @UnitId = 0;
		SET @sqlCommand = "SELECT CASE WHEN add_to_quantity AND require_destination_and_source THEN 0 WHEN add_to_quantity AND !require_destination_and_source THEN 1 WHEN !add_to_quantity AND !require_destination_and_source THEN 2 ELSE 99 END INTO @TempInd FROM inventory.items_adjustments_templates WHERE template_id = ?;";
		PREPARE query_statement FROM @sqlCommand; EXECUTE query_statement USING intTemplateId; DEALLOCATE PREPARE query_statement;
		IF @TempInd = 1 THEN SET @UnitId = intDestinationUnitId; ELSE SET @UnitId = intSourceUnitId; END IF;
		IF bolProceed THEN
			SET @sqlCommand = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Items for adjustment retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('item_id', iui.item_id, 'item_description', iic.item_description, 'unit', IF(iu.warehouse,ii.stocking_unit,ii.retail_unit), 'unit_cost', iui.unit_cost, 'quantity_cap', CASE WHEN !iu.warehouse AND ",IF(@TempInd = 0,"aa.warehouse","NULL")," THEN ii.rtu_over_stu ELSE 1 END) ORDER BY iic.item_description)) AS response FROM inventory.inventory_units_items iui INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iui.item_id = iic.item_id INNER JOIN inventory.inventory_items ii ON iic.item_id = ii.item_id INNER JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id ", IF(@TempInd = 0, CONCAT(" INNER JOIN ( SELECT iui.item_id, iu.warehouse FROM inventory.inventory_units_items iui INNER JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id WHERE iui.unit_id = ",intDestinationUnitId," ) AS aa ON iui.item_id = aa.item_id "), "")," WHERE iui.unit_id = ? AND LOWER(iic.item_description) LIKE CONCAT('%',LOWER(?),'%') AND iui.ending_quantity > 0;");
			PREPARE query_statement FROM @sqlCommand; EXECUTE query_statement USING @UnitId, charItemDescription; DEALLOCATE PREPARE query_statement;
		END IF;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getItemImage` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getItemImage`(
		IN jsnItemImage JSON
	)
BEGIN
	DECLARE bolProceed BOOLEAN DEFAULT TRUE;
	DECLARE intItemId INT;
	DECLARE strImage LONGTEXT;
	IF JSON_VALID(jsnItemImage) = 0 THEN
		SET bolProceed = FALSE;
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON format', 'json_data', NULL) AS response;
	END IF;
	IF bolProceed THEN
		SET intItemId = JSON_VALUE(jsnItemImage, '$.item_id');
		IF intItemId IS NULL OR intItemId = 0 THEN
			SET bolProceed = FALSE;
			SELECT JSON_OBJECT('success', FALSE, 'message', 'item_id is required', 'json_data', NULL) AS response;
		END IF;
	END IF;
	IF bolProceed THEN
		SELECT image INTO strImage FROM inventory.item_images WHERE item_id = intItemId LIMIT 1;
		IF strImage IS NOT NULL AND strImage != '' THEN
			SELECT JSON_OBJECT('success', TRUE, 'message', 'Item image retrieved successfully.', 'json_data', JSON_OBJECT('item_id', intItemId, 'image', CAST(strImage AS CHAR))) AS response;
		ELSE
			SELECT JSON_OBJECT('success', FALSE, 'message', 'No image found', 'json_data', JSON_OBJECT('item_id', intItemId)) AS response;
		END IF;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getItemImportList` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getItemImportList`(
    IN jsnItemImportList JSON
)
BEGIN
    SET @importList = '[{"import_name":"Brand","import_type":"brand"},{"import_name":"Size","import_type":"size"},{"import_name":"Part Description","import_type":"vehiclePart"},{"import_name":"Part Number","import_type":"vehiclePartNumber"}]';
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Item import list retrieved successfully.',
        'json_data', JSON_QUERY(@importList, '$')
    ) AS response;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getItemImports` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getItemImports`(
		IN jsnItemImports JSON
	)
BEGIN
	DECLARE whereCredentials VARCHAR(250);
	DECLARE bolProceed BOOLEAN DEFAULT FALSE;
	DECLARE bolGetOne BOOLEAN;
	DECLARE charImportType VARCHAR(20);
	DECLARE intId INT;
	DECLARE charDescription VARCHAR(100);
	DECLARE charImportId VARCHAR(40);
	DECLARE charImportTable VARCHAR(40);
	IF JSON_VALID(jsnItemImports) THEN SET bolProceed = TRUE; END IF;
	IF bolProceed THEN
		SET charImportType = JSON_VALUE(jsnItemImports, '$.import_type');
		SET bolGetOne = JSON_VALUE(jsnItemImports, '$.bol_getone');
		SET intId = JSON_VALUE(jsnItemImports, '$.id');
		SET charDescription = JSON_VALUE(jsnItemImports, '$.description');
		IF charImportType = 'brand' THEN
			SET charImportId = 'brand_id'; SET charImportTable = 'brands';
		ELSEIF charImportType = 'ratio' THEN
			SET charImportId = 'ratio_id'; SET charImportTable = 'ratios';
		ELSEIF charImportType = 'size' THEN
			SET charImportId = 'size_id'; SET charImportTable = 'sizes';
		ELSEIF charImportType = 'threadPattern' THEN
			SET charImportId = 'pattern_id'; SET charImportTable = 'thread_patterns';
		ELSEIF charImportType = 'valveType' THEN
			SET charImportId = 'valve_id'; SET charImportTable = 'valve_types';
		ELSEIF charImportType = 'vehiclePart' THEN
			SET charImportId = 'part_id'; SET charImportTable = 'vehicle_parts';
		ELSEIF charImportType = 'vehiclePartNumber' THEN
			SET charImportId = 'part_number_id'; SET charImportTable = 'vehicle_part_numbers';
		ELSE
			SET bolProceed = FALSE;
			SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
		END IF;
		IF bolProceed THEN
			IF bolGetOne THEN
				SET whereCredentials = CONCAT("WHERE ",charImportId," = ",intId);
			ELSEIF charDescription <> '' THEN
				SET whereCredentials = CONCAT("WHERE LOWER(description) LIKE CONCAT('%',LOWER('",charDescription,"'),'%')");
			ELSE
				SET whereCredentials = "";
			END IF;
			SET @sqlCommand = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Item imports retrieved successfully.', 'json_data', JSON_ARRAYAGG(JSON_OBJECT('id', ",charImportId,", 'description', description) ORDER BY description)) AS response FROM inventory.",charImportTable," ",whereCredentials,";");
			PREPARE query_statement FROM @sqlCommand; EXECUTE query_statement; DEALLOCATE PREPARE query_statement;
		END IF;
	ELSE
		SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid JSON parameter.', 'json_data', NULL) AS response;
	END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getJSONPayablesAndTransactionsWithSuppliers` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getJSONPayablesAndTransactionsWithSuppliers`(IN jsonParams JSON)
BEGIN
    DECLARE intSupplierID INT DEFAULT 0;
    DECLARE dteStartingPeriod DATE DEFAULT NULL;
    DECLARE dteEndingPeriod DATE DEFAULT NULL;
    DECLARE bolForOnTermOnly BOOLEAN DEFAULT FALSE;
    DECLARE dteBegDate DATE;
    DECLARE dteEndDate DATE;
    DECLARE bolProceedTask BOOLEAN DEFAULT TRUE;

    IF JSON_VALID(jsonParams) THEN
        SET intSupplierID = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonParams, '$.supplier_id')) AS UNSIGNED);
        SET dteStartingPeriod = STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(jsonParams, '$.start_date')), '%Y-%m-%d');
        SET dteEndingPeriod = STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(jsonParams, '$.end_date')), '%Y-%m-%d');
        SET bolForOnTermOnly = CAST(JSON_EXTRACT(jsonParams, '$.onterm') AS UNSIGNED);

        IF dteStartingPeriod IS NULL OR dteStartingPeriod = '1900-01-01'
            OR dteEndingPeriod IS NULL OR dteEndingPeriod = '1900-01-01' THEN
            SET bolProceedTask = FALSE;
        ELSE
            IF dteStartingPeriod <= dteEndingPeriod THEN
                SET dteBegDate = dteStartingPeriod;
                SET dteEndDate = dteEndingPeriod;
            ELSE
                SET dteBegDate = dteEndingPeriod;
                SET dteEndDate = dteStartingPeriod;
            END IF;
        END IF;
    ELSE
        SET bolProceedTask = FALSE;
    END IF;

    IF bolProceedTask THEN
        DROP TEMPORARY TABLE IF EXISTS app_bin.source_supplier_ledger;
        SET @runningBalance = 0;

        IF intSupplierID > 0 THEN
            SET @sqlCommand = "CREATE TEMPORARY TABLE app_bin.source_supplier_ledger
                SELECT * FROM (
                    SELECT aaa.invoice_date AS entry_date, aaa.reference AS reference, ccc.entity_name AS entity_name,
                        0 AS ap_debit, aaa.invoice_amount AS ap_credit, 0 AS end_balance, '' AS col_balance,
                        '' AS payment_for, aaa.due_date AS ap_due_date, 0 AS paid_in_cash, 0 AS paid_in_non_cash,
                        '' AS non_cash_payment, 1 AS entry_identifier
                    FROM purchases_ap.invoices aaa
                    INNER JOIN purchases_ap.for_deliveries bbb ON bbb.for_delivery_id = aaa.for_delivery_id
                    INNER JOIN purchases_ap.po_main ccc_po ON ccc_po.po_id = bbb.po_id
                    INNER JOIN entities_udf_and_views.entity_name ccc ON ccc.entity_id = ccc_po.entity_id
                    WHERE (ccc_po.entity_id = ? OR ? = 0) AND aaa.invoice_date <= ? AND IF(?, bbb.on_term, TRUE)
                    UNION ALL
                    SELECT ddd.date_paid AS entry_date, ddd.reference AS reference, fff.entity_name AS entity_name,
                        ddd.payment_amount AS ap_debit, 0 AS ap_credit, 0 AS end_balance, '' AS col_balance,
                        ddd.payment_for AS payment_for, '1900-01-01' AS ap_due_date,
                        IF(ggg.payment_mode = 'CASH', ddd.payment_amount, 0) AS paid_in_cash,
                        IF(ggg.payment_mode <> 'CASH', ddd.payment_amount, 0) AS paid_in_non_cash,
                        ggg.payment_mode AS non_cash_payment, 0 AS entry_identifier
                    FROM purchases_ap.for_deliveries ddd_fd
                    INNER JOIN purchases_ap.ap_payments ddd ON ddd.for_delivery_id = ddd_fd.for_delivery_id
                    INNER JOIN purchases_ap.po_main eee ON eee.po_id = ddd_fd.po_id
                    INNER JOIN entities_udf_and_views.entity_name fff ON fff.entity_id = eee.entity_id
                    LEFT JOIN purchases_ap.payment_modes ggg ON ggg.payment_mode_id = ddd.payment_mode_id
                    WHERE (eee.entity_id = ? OR ? = 0) AND ddd.date_paid <= ? AND IF(?, ddd_fd.on_term, TRUE)
                ) aa ORDER BY entry_date, entry_identifier, reference";
            PREPARE stmt FROM @sqlCommand;
            EXECUTE stmt USING intSupplierID, intSupplierID, dteEndDate, bolForOnTermOnly, intSupplierID, intSupplierID, dteEndDate, bolForOnTermOnly;
            DEALLOCATE PREPARE stmt;
        ELSE
            SET @sqlCommand = "CREATE TEMPORARY TABLE app_bin.source_supplier_ledger
                SELECT * FROM (
                    SELECT aaa.invoice_date AS entry_date, aaa.reference AS reference, ccc.entity_name AS entity_name,
                        0 AS ap_debit, aaa.invoice_amount AS ap_credit, 0 AS end_balance, '' AS col_balance,
                        '' AS payment_for, aaa.due_date AS ap_due_date, 0 AS paid_in_cash, 0 AS paid_in_non_cash,
                        '' AS non_cash_payment, 1 AS entry_identifier
                    FROM purchases_ap.invoices aaa
                    INNER JOIN purchases_ap.for_deliveries bbb ON bbb.for_delivery_id = aaa.for_delivery_id
                    INNER JOIN purchases_ap.po_main ccc_po ON ccc_po.po_id = bbb.po_id
                    INNER JOIN entities_udf_and_views.entity_name ccc ON ccc.entity_id = ccc_po.entity_id
                    WHERE aaa.invoice_date <= ?
                    UNION ALL
                    SELECT aaa.date_paid AS entry_date, aaa.reference AS reference, fff.entity_name AS entity_name,
                        aaa.payment_amount AS ap_debit, 0 AS ap_credit, 0 AS end_balance, '' AS col_balance,
                        aaa.payment_for AS payment_for, '1900-01-01' AS ap_due_date,
                        IF(ggg.payment_mode = 'CASH', aaa.payment_amount, 0) AS paid_in_cash,
                        IF(ggg.payment_mode <> 'CASH', aaa.payment_amount, 0) AS paid_in_non_cash,
                        ggg.payment_mode AS non_cash_payment, 0 AS entry_identifier
                    FROM purchases_ap.for_deliveries ddd
                    INNER JOIN purchases_ap.ap_payments aaa ON aaa.for_delivery_id = ddd.for_delivery_id
                    INNER JOIN purchases_ap.po_main eee ON eee.po_id = ddd.po_id
                    INNER JOIN entities_udf_and_views.entity_name fff ON fff.entity_id = eee.entity_id
                    LEFT JOIN purchases_ap.payment_modes ggg ON ggg.payment_mode_id = aaa.payment_mode_id
                    WHERE aaa.date_paid <= ? AND IF(?, bbb.on_term, TRUE)
                ) aa ORDER BY entry_date, entry_identifier, reference";
            PREPARE stmt FROM @sqlCommand;
            EXECUTE stmt USING dteEndDate, dteEndDate, bolForOnTermOnly;
            DEALLOCATE PREPARE stmt;
        END IF;

        SET @sqlCommand = "SELECT COALESCE(COUNT(reference),0), COALESCE(SUM(ap_credit - ap_debit),0)
            INTO @numberOfEntries, @forwardedBalance FROM app_bin.source_supplier_ledger WHERE entry_date < ?";
        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt USING dteBegDate;
        DEALLOCATE PREPARE stmt;

        IF @numberOfEntries > 0 THEN
            SET @runningBalance = @forwardedBalance;
            SET @sqlCommand = "SELECT JSON_OBJECT('success', TRUE, 'message', 'Payables and transactions retrieved successfully.', 'json_data', CAST(CONCAT('[', GROUP_CONCAT(JSON_OBJECT('entry_date', entry_date, 'reference', reference, 'supplier', entity_name, 'ap_debit', FORMAT(ap_debit,2), 'ap_credit', FORMAT(ap_credit,2), 'end_balance', FORMAT(end_balance,2), 'col_balance', col_balance, 'payment_for', payment_for, 'ap_due_date', ap_due_date, 'paid_in_cash', paid_in_cash, 'paid_in_non_cash', paid_in_non_cash, 'non_cash_payment', non_cash_payment) ORDER BY entry_date, entry_identifier, reference), ']') AS JSON)) AS response
                FROM (
                    SELECT DATE_SUB(?, INTERVAL 1 DAY) AS entry_date, 'BALFWD' AS reference, '' AS entity_name,
                        IF(@forwardedBalance < 0, ABS(@forwardedBalance), 0) AS ap_debit,
                        IF(@forwardedBalance > 0, @forwardedBalance, 0) AS ap_credit,
                        ABS(@forwardedBalance) AS end_balance,
                        CASE WHEN @forwardedBalance < 0 THEN 'Dr' WHEN @forwardedBalance > 0 THEN 'Cr' ELSE '' END AS col_balance,
                        '' AS payment_for, '1900-01-01' AS ap_due_date, 0 AS paid_in_cash, 0 AS paid_in_non_cash,
                        '' AS non_cash_payment, 0 AS entry_identifier
                    UNION ALL
                    SELECT entry_date, reference, entity_name, ap_debit, ap_credit,
                        (@runningBalance := @runningBalance + (ap_credit - ap_debit)) AS end_balance,
                        CASE WHEN @runningBalance > 0 THEN 'Cr' WHEN @runningBalance < 0 THEN 'Dr' ELSE '' END AS col_balance,
                        payment_for, ap_due_date, paid_in_cash, paid_in_non_cash, non_cash_payment, entry_identifier
                    FROM app_bin.source_supplier_ledger WHERE entry_date >= ?
                ) AS combined_data";
            PREPARE stmt FROM @sqlCommand;
            EXECUTE stmt USING dteBegDate, dteBegDate;
            DEALLOCATE PREPARE stmt;
        ELSE
            SET @runningBalance = 0;
            SET @sqlCommand = "SELECT JSON_OBJECT('success', TRUE, 'message', 'Payables and transactions retrieved successfully.', 'json_data', CAST(CONCAT('[', GROUP_CONCAT(JSON_OBJECT('entry_date', entry_date, 'reference', reference, 'supplier', entity_name, 'ap_debit', FORMAT(ap_debit,2), 'ap_credit', FORMAT(ap_credit,2), 'end_balance', FORMAT((@runningBalance := @runningBalance + (ap_credit - ap_debit)),2), 'col_balance', CASE WHEN @runningBalance > 0 THEN 'Cr' WHEN @runningBalance < 0 THEN 'Dr' ELSE '' END, 'payment_for', payment_for, 'ap_due_date', ap_due_date, 'paid_in_cash', paid_in_cash, 'paid_in_non_cash', paid_in_non_cash, 'non_cash_payment', non_cash_payment)), ']') AS JSON)) AS response
                FROM app_bin.source_supplier_ledger ORDER BY entry_date, entry_identifier, reference";
            PREPARE stmt FROM @sqlCommand;
            EXECUTE stmt;
            DEALLOCATE PREPARE stmt;
        END IF;
    ELSE
        SELECT JSON_OBJECT('success', FALSE, 'message', 'Invalid or incomplete JSON parameter.', 'json_data', NULL) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getJSONStockCard` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getJSONStockCard`(
    IN jsonInput TEXT
)
BEGIN  
    DECLARE intItemID INT;
    DECLARE dteStartingDate DATE;
    DECLARE dteEndingDate DATE;
    DECLARE dteBegDate DATE;
    DECLARE dteEndDate DATE;
    DECLARE bolProceedTask BOOLEAN DEFAULT FALSE;
    DECLARE charMessage VARCHAR(250);

    SET intItemID = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.unit_id')) AS UNSIGNED);
    SET dteStartingDate = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.start_date')) AS DATE);
    SET dteEndingDate = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.end_date')) AS DATE);

    IF intItemID IS NULL THEN 
        SET bolProceedTask = FALSE;
        SET charMessage = "Provide unit stock inventory ID!";
    ELSEIF dteStartingDate IS NULL OR dteStartingDate = '1900-01-01' THEN 
        SET bolProceedTask = FALSE;
        SET charMessage = "Provide valid starting date!";
    ELSEIF dteEndingDate IS NULL OR dteEndingDate = '1900-01-01' THEN 
        SET bolProceedTask = FALSE;
        SET charMessage = "Provide valid ending date!";
    ELSE
        SET bolProceedTask = TRUE;
        
        IF dteStartingDate > dteEndingDate THEN
            SET dteBegDate = dteEndingDate;
            SET dteEndDate = dteStartingDate;
        ELSE
            SET dteBegDate = dteStartingDate;
            SET dteEndDate = dteEndingDate;
        END IF;
    END IF;

    IF bolProceedTask THEN
        DROP TEMPORARY TABLE IF EXISTS app_bin.source_stockcard;
        DROP TEMPORARY TABLE IF EXISTS app_bin.stockcard;

        SET @unitItem = intItemID;
        SET @runningBalance = 0;

		SET @sqlCommand = "
		    CREATE TEMPORARY TABLE app_bin.source_stockcard 
		    SELECT 
		        entry_date, 
		        reference COLLATE utf8mb4_unicode_ci AS reference,
		        qty_in AS item_in,
		        qty_out AS item_out,
		        description COLLATE utf8mb4_unicode_ci AS description,
		        COALESCE(bb.user_login_name, '') AS posted_by, 
		        remark COLLATE utf8mb4_unicode_ci AS remark,
		        unit_item_id
		    FROM (
		        -- INBOUND ADJUSTMENT
		        SELECT 
		            DATE(aaa.adjustment_date) AS entry_date, 
		            CONCAT('ADJ', LPAD(adjustment_id, 6, 0)) COLLATE utf8mb4_unicode_ci AS reference,
		            destination_id AS unit_item_id,
		            quantity AS qty_in,
		            0 AS qty_out,
		            CONCAT(
		                bbb.description COLLATE utf8mb4_unicode_ci,
		                COALESCE(CONCAT(' - From: ', ddd.description COLLATE utf8mb3_unicode_ci), '')
		            ) AS description,
		            aaa.remarks COLLATE utf8mb4_unicode_ci AS remark,
		            aaa.created_by AS posted_by
		        FROM inventory.items_adjustments aaa 
		        INNER JOIN inventory.items_adjustments_templates bbb ON aaa.template_id = bbb.template_id 
		        LEFT JOIN inventory.inventory_units_items ccc ON aaa.source_id = ccc.unit_item_id 
		        LEFT JOIN subscriber_common_tables.units ddd ON ccc.unit_id = ddd.unit_id 
		        WHERE (
		            bbb.require_destination_and_source = 1
		            OR (bbb.require_destination_and_source = 0 AND bbb.add_to_quantity = 1)
		        )
		        AND destination_id IS NOT NULL
		        AND (COALESCE(destination_id, 0) = ? OR ? = 0)
		
		        UNION
		
		        -- OUTBOUND ADJUSTMENT
		        SELECT 
		            DATE(aaa.adjustment_date) AS entry_date, 
		            CONCAT('ADJ', LPAD(adjustment_id, 6, 0)) COLLATE utf8mb4_unicode_ci AS reference,
		            source_id AS unit_item_id,
		            0 AS qty_in,
		            quantity AS qty_out,
		            CONCAT(
		                bbb.description COLLATE utf8mb4_unicode_ci,
		                COALESCE(CONCAT(' - To: ', ddd.description COLLATE utf8mb3_unicode_ci), '')
		            ) AS description,
		            aaa.remarks COLLATE utf8mb4_unicode_ci AS remark,
		            aaa.created_by AS posted_by
		        FROM inventory.items_adjustments aaa 
		        INNER JOIN inventory.items_adjustments_templates bbb ON aaa.template_id = bbb.template_id 
		        LEFT JOIN inventory.inventory_units_items ccc ON aaa.destination_id = ccc.unit_item_id 
		        LEFT JOIN subscriber_common_tables.units ddd ON ccc.unit_id = ddd.unit_id 
		        WHERE (
		            bbb.require_destination_and_source = 1
		            OR (bbb.require_destination_and_source = 0 AND bbb.add_to_quantity = 0)
		        )
		        AND source_id IS NOT NULL
		        AND (COALESCE(source_id, 0) = ? OR ? = 0)
		
		        UNION
		
		        -- DELIVERIES
		        SELECT 
		            DATE(bbb.delivery_date) AS entry_date,
		            COALESCE(bbb.delivery_reference COLLATE utf8mb4_unicode_ci, '-') AS reference,
		            aaa.unit_item_id,
		            aaa.quantity AS qty_in,
		            0 AS qty_out,
		            'Delivery' AS description, 
		            CONCAT('From ', eee.supplier COLLATE utf8mb4_unicode_ci, ' per P.O. Reference ', LPAD(ddd.po_id, 8, 0)) AS remark,
		            bbb.posted_by
		        FROM purchases_ap.deliveries_details aaa 
		        INNER JOIN purchases_ap.deliveries bbb ON aaa.delivery_id = bbb.delivery_id 
		        INNER JOIN purchases_ap.for_deliveries ccc ON bbb.for_delivery_id = ccc.for_delivery_id 
		        INNER JOIN purchases_ap.po_main ddd ON ccc.po_id = ddd.po_id 
		        INNER JOIN purchases_ap.suppliers eee ON ddd.supplier_id = eee.entity_id
		        WHERE (aaa.unit_item_id = ? OR ? = 0)
		
		        UNION
		
		        -- POS SALES
		        SELECT 
		            DATE(bbb.invoice_date) AS entry_date,
		            bbb.invoice_reference COLLATE utf8mb4_unicode_ci AS reference, 
		            aaa.unit_item_id,
		            0 AS qty_in,
		            quantity AS qty_out,
		            CONCAT('Sales', IF(bbb.walk_in, ' Walk-In', COALESCE(CONCAT(' to ', ccc.entity_name COLLATE utf8mb4_unicode_ci), ''))) AS description,
		            '' AS remark,
		            bbb.posted_by
		        FROM point_of_sales_ar.inventory_item_sales aaa
		        INNER JOIN point_of_sales_ar.pos_invoices bbb ON aaa.invoice_id = bbb.invoice_id 
		        LEFT JOIN entities_udf_and_views.entity_name ccc ON bbb.entity_id = ccc.entity_id 
		        WHERE (aaa.unit_item_id = ? OR ? = 0)
		
		        UNION
		
		        -- JOB ORDER SALES
		        SELECT 
		            DATE(IF(aaa.entry_date = '1900-01-01 00:00:00', bbb.start_date, aaa.entry_date)) AS entry_date, 
		            bbb.job_order_reference COLLATE utf8mb4_unicode_ci AS reference, 
		            aaa.unit_item_id,
		            0 AS qty_in, 
		            quantity AS qty_out, 
		            CONCAT('JO Sales to ', ccc.entity_name COLLATE utf8mb4_unicode_ci) AS description, 
		            '' AS remark,
		            CASE 
		                WHEN aaa.posted_by IS NULL THEN bbb.posted_by
		                WHEN aaa.posted_by = 0 THEN bbb.posted_by
		                ELSE aaa.posted_by
		            END AS posted_by
		        FROM point_of_sales_ar.inventory_items_job_order aaa 
		        INNER JOIN point_of_sales_ar.job_orders bbb ON aaa.job_order_id = bbb.job_order_id 
		        INNER JOIN entities_udf_and_views.entity_name ccc ON bbb.entity_id = ccc.entity_id 
		        WHERE (aaa.unit_item_id = ? OR ? = 0)
		    ) aa 
		    LEFT JOIN application_users_inventory.application_users bb ON aa.posted_by = bb.user_id 
		    WHERE aa.entry_date <= ?
		    ORDER BY 
		        entry_date, 
		        reference,
		        CASE 
		            WHEN qty_in > 0 THEN 1
		            WHEN qty_out > 0 THEN 2
		            ELSE 3
		        END
		";
		
		PREPARE query_statement FROM @sqlCommand;
		EXECUTE query_statement USING 
		    @unitItem, @unitItem,  
		    @unitItem, @unitItem,  
		    @unitItem, @unitItem,  
		    @unitItem, @unitItem,  
		    @unitItem, @unitItem,  
		    dteEndDate;
		DEALLOCATE PREPARE query_statement;

        SET @runningBalance = 0;
        SET @sqlCommand = "CREATE TEMPORARY TABLE app_bin.stockcard
                            SELECT
                                entry_date,
                                reference,
                                item_in,
                                item_out,
                                (@runningBalance := @runningBalance + (item_in - item_out)) ending_quantity,
                                description,
                                posted_by,
                                remark,
                                unit_item_id
                            FROM 
                                app_bin.source_stockcard  
                            ORDER BY 
                                entry_date, 
                                reference,
                                CASE 
                                    WHEN item_in > 0 THEN 1
                                    WHEN item_out > 0 THEN 2
                                    ELSE 3
                                END";

        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement;
        DEALLOCATE PREPARE query_statement;

        DROP TEMPORARY TABLE IF EXISTS app_bin.source_stockcard;

        SELECT 
            COALESCE(COUNT(reference), 0)
        INTO
            @numberOfEntries
        FROM 
            app_bin.stockcard
        WHERE 
            entry_date < dteBegDate;

        IF @numberOfEntries > 0 THEN 
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'Stock card retrieved successfully.',
                'json_data', COALESCE(
                    (
                        SELECT JSON_ARRAYAGG(
                            -- THE FIX: Added 'a.' prefix to all fields to prevent the Ambiguous Column error
                            JSON_OBJECT(
                                'entry_date', DATE_FORMAT(a.entry_date, '%Y %b %d'),
                                'reference', a.reference,
                                'item_in', FORMAT(a.item_in, 2),
                                'item_out', FORMAT(a.item_out, 2),
                                'ending_quantity', FORMAT(a.ending_quantity, 2),
                                'description', a.description,
                                'posted_by', a.posted_by,
                                'remark', a.remark,
                                'unit_item_id', a.unit_item_id,
                                'item_id', iui.item_id,
                                'item_description', iic.item_description
                            )
                        ) 
                        FROM (
                            
                            SELECT 
                                DATE_SUB(dteBegDate, INTERVAL 1 DAY) AS entry_date,
                                'QTYFWD' AS reference, 
                                SUM(item_in) AS item_in,
                                SUM(item_out) AS item_out,
                                SUM(item_in - item_out) AS ending_quantity,
                                'Forwarded quantity balance' AS description,
                                '' AS posted_by,
                                '' AS remark,
                                0 AS sort_order,
                                0 AS unit_item_id
                            FROM 
                                app_bin.stockcard 
                            WHERE 
                                entry_date < dteBegDate
                                
                            UNION ALL
                            
                            SELECT
                                entry_date,
                                reference, 
                                item_in,
                                item_out,
                                ending_quantity,
                                description, 
                                posted_by,
                                remark,
                                CASE 
                                    WHEN item_in > 0 THEN 1
                                    WHEN item_out > 0 THEN 2
                                    ELSE 3
                                END AS sort_order,
                                unit_item_id
                            FROM 
                                app_bin.stockcard
                            WHERE 
                                entry_date >= dteBegDate
                            ORDER BY 
                                entry_date, 
                                reference,
                                sort_order
                        ) a
                        LEFT JOIN inventory.inventory_units_items iui ON a.unit_item_id = iui.unit_item_id
                        LEFT JOIN inventory_udf_and_views.inventory_item_concat iic ON iui.item_id = iic.item_id
                    ), JSON_ARRAY()
                )
            ) AS response;
        ELSE
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'Stock card retrieved successfully.',
                'json_data', COALESCE(
                    (
                        SELECT JSON_ARRAYAGG(
                            -- THE FIX: Added 'b.' prefix to all fields here as well
                            JSON_OBJECT(
                                'entry_date', DATE_FORMAT(b.entry_date, '%Y %b %d'),
                                'reference', b.reference,
                                'item_in', FORMAT(b.item_in, 2),
                                'item_out', FORMAT(b.item_out, 2),
                                'ending_quantity', FORMAT(b.ending_quantity, 2),
                                'description', b.description,
                                'posted_by', b.posted_by,
                                'remark', b.remark,
                                'unit_item_id', b.unit_item_id,
                                'item_id', iui.item_id,
                                'item_description', iic.item_description
                            )
                        )
                        FROM (
                            SELECT *,
                                CASE 
                                    WHEN item_in > 0 THEN 1
                                    WHEN item_out > 0 THEN 2
                                    ELSE 3
                                END AS sort_order
                            FROM app_bin.stockcard
                            ORDER BY entry_date, reference, sort_order
                        ) b
                        LEFT JOIN inventory.inventory_units_items iui ON b.unit_item_id = iui.unit_item_id
                        LEFT JOIN inventory_udf_and_views.inventory_item_concat iic ON iui.item_id = iic.item_id
                    ), JSON_ARRAY()
                )
            ) AS response;
        END IF;

    ELSE
        
        SELECT JSON_OBJECT(
            'success', FALSE, 
            'message', charMessage, 
            'json_data', JSON_ARRAY()
        ) AS response;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getNotification` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getNotification`(
    IN notification JSON
)
BEGIN
    SET @column_recorded_by = "(SELECT su.full_name FROM application_users_accounting.subscribers_applications_user sau INNER JOIN application_users_accounting.subscribers_users su ON su.subscriber_user_id = sau.subscriber_user_id WHERE sau.user_id = rjr.requested_by LIMIT 1)";
    SET @column_executed_by = "IFNULL((SELECT su.full_name FROM application_users_accounting.subscribers_applications_user sau INNER JOIN application_users_accounting.subscribers_users su ON su.subscriber_user_id = sau.subscriber_user_id WHERE sau.user_id = rjr.approved_by LIMIT 1), '-')";

    SET @sqlCommand = "SELECT fp.transaction_date INTO @transaction_date FROM funds.funds_parms fp LIMIT 1";
    PREPARE query_statement FROM @sqlCommand;
    EXECUTE query_statement;
    DEALLOCATE PREPARE query_statement;

    SET @sqlCommand = CONCAT("SELECT JSON_OBJECT('success', TRUE, 'message', 'Notifications retrieved successfully.', 'json_data', CAST(COALESCE(CONCAT('[', GROUP_CONCAT(JSON_OBJECT('transaction_date', DATE_FORMAT(rjr.entry_date, '%m/%d/%Y'), 'item', 'Journal References', 'status', IF(rjr.approved_by IS NULL, 'For Approval', 'Approved'), 'recorded_by', ", @column_recorded_by, ", 'executed_by', ", @column_executed_by, ", 'datetime_recorded', IFNULL(DATE_FORMAT(rjr.datetime_requested, '%m/%d/%Y %H:%i'), '-'), 'datetime_executed', IFNULL(DATE_FORMAT(rjr.datetime_approved, '%m/%d/%Y %H:%i'), '-'), 'transaction_date_executed', IFNULL(DATE_FORMAT(rjr.datetime_approved, '%m/%d/%Y'), '-'), 'redirect_url', (SELECT f.url FROM application_users_accounting.functionalities f WHERE f.function_id = 9 LIMIT 1), 'amount', '-', 'remarks', rjr.brief_remark) ORDER BY rjr.entry_date DESC), ']'), '[]') AS JSON)) response
        FROM accounting.request_journal_references rjr
        WHERE IF(rjr.approved_by IS NULL, TRUE, DATE_FORMAT(rjr.entry_date, '%Y-%m') BETWEEN DATE_FORMAT(?, '%Y-%m') AND DATE_FORMAT(?, '%Y-%m'))
        ORDER BY rjr.entry_date DESC");
    PREPARE query_statement FROM @sqlCommand;
    EXECUTE query_statement USING @transaction_date, @transaction_date;
    DEALLOCATE PREPARE query_statement;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getPayablesToSuppliersJSON` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getPayablesToSuppliersJSON`(IN jsonInput TEXT)
BEGIN 
    DECLARE dteBaseDate DATE;
    
    SET dteBaseDate = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.date')) AS DATE);
    DROP TEMPORARY TABLE IF EXISTS app_bin.payables_source;
    CREATE TEMPORARY TABLE app_bin.payables_source 
    SELECT 
        e.entity_name,
        a.invoice_reference,
        a.invoice_amount,
        a.invoice_balance,
        e.entity_id,
        DATE(a.invoice_date) AS invoice_date, 
        DATE(DATE_ADD(a.invoice_date, INTERVAL a.term_in_days DAY)) AS due_date
    FROM purchases_ap.invoices a 
    INNER JOIN purchases_ap.deliveries b ON a.delivery_id = b.delivery_id 
    INNER JOIN purchases_ap.for_deliveries c ON b.for_delivery_id = c.for_delivery_id 
    INNER JOIN purchases_ap.po_main d ON c.po_id = d.po_id 
    INNER JOIN entities_udf_and_views.entity_name e ON d.supplier_id = e.entity_id 
    WHERE a.on_term AND a.invoice_balance > 0
    ORDER BY e.entity_id, invoice_date, invoice_reference;
    
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Payables to suppliers retrieved successfully.',
        'json_data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'entity_name', entity_name,
                    'invoice_reference', invoice_reference,
                    'invoice_amount', FORMAT(invoice_amount, 2),
                    'invoice_balance', FORMAT(invoice_balance, 2),
                    'entity_id', entity_id,
                    'invoice_date', DATE_FORMAT(invoice_date, '%Y/%m/%d'),
                    'due_date', DATE_FORMAT(due_date, '%Y/%m/%d')
                )
            ),
            JSON_ARRAY()
        )
    ) AS response
    FROM app_bin.payables_source;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getPurchasesReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getPurchasesReport`(
    IN jsonParams JSON
)
BEGIN 
    DECLARE dateFrom DATE;
    DECLARE dateTo DATE;
    DECLARE charSupplierList VARCHAR(250);
    DECLARE bolWithCost BOOLEAN;
    DECLARE dateTemp DATE;
    DECLARE stringCondition VARCHAR(255);
    DECLARE stringOrderBy VARCHAR(255);
    DECLARE stringFields VARCHAR(3000);

    
    SET dateFrom = JSON_UNQUOTE(JSON_EXTRACT(jsonParams, '$.start_date'));
    SET dateTo = JSON_UNQUOTE(JSON_EXTRACT(jsonParams, '$.end_date'));
    
    
    SET charSupplierList = JSON_UNQUOTE(JSON_EXTRACT(jsonParams, '$.client_id'));
    SET charSupplierList = REPLACE(REPLACE(charSupplierList, '[', ''), ']', '');
    
    SET bolWithCost = IFNULL(JSON_EXTRACT(jsonParams, '$.withCost'), FALSE);

    
    IF dateFrom > dateTo THEN
        SET dateTemp = dateFrom;
        SET dateFrom = dateTo;
        SET dateTo = dateTemp;
    END IF;

    
    SET stringCondition = CONCAT("DATE(a.po_date) BETWEEN '", dateFrom, "' AND '", dateTo, "'");
    
    
    IF charSupplierList IS NOT NULL AND charSupplierList NOT IN ('', '0', 'null') THEN
        SET stringCondition = CONCAT(stringCondition, " AND a.supplier_id IN (", charSupplierList, ")");
    END IF;

    SET stringOrderBy = "ORDER BY \n                            a.po_date, a.po_reference, item";

    DROP TEMPORARY TABLE IF EXISTS app_bin.purchases;
    
    IF bolWithCost THEN
        SET stringFields = "CREATE TEMPORARY TABLE app_bin.purchases
                            SELECT 
                                a.fmt_po_date, \n                                a.po_reference,\n                                a.entity_name,\n                                category,\n                                brand,\n                                item,\n                                CONCAT(FORMAT(po_quantity, 2), ' ', TRIM(stocking_unit)) po_quantity,\n                                po_unitcost,\n                                po_total_cost,\n                                CONCAT(FORMAT(COALESCE(b.quantity_delivered, 0), 2), ' ', TRIM(stocking_unit)) quantity_delivered,\n                                COALESCE(b.total_cost_delivered, 0.00) total_cost_delivered,\n                                CONCAT(FORMAT((po_quantity - COALESCE(b.quantity_delivered, 0)), 2), ' ', TRIM(stocking_unit)) quantity_undelivered,\n                                CONCAT(FORMAT(COALESCE(c.quantity_in_transit, 0), 2), ' ', TRIM(stocking_unit)) quantity_in_transit, \n                                COALESCE(c.total_cost_in_transit, 0.00) total_cost_in_transit,\n                                a.warehouse_store,\n                                warehouse_store_id,\n                                a.supplier_id,\n                                po_date, \n                                a.item_id ";
    ELSE
        SET stringFields = "CREATE TEMPORARY TABLE app_bin.purchases
                            SELECT \n                                a.fmt_po_date, \n                                a.po_reference,\n                                a.entity_name,\n                                category,\n                                brand,\n                                item,\n                                CONCAT(FORMAT(po_quantity, 2), ' ', TRIM(stocking_unit)) po_quantity,\n                                0.00 po_unitcost,\n                                0.00 po_total_cost,\n                                CONCAT(FORMAT(COALESCE(b.quantity_delivered, 0), 2), ' ', TRIM(stocking_unit)) quantity_delivered,\n                                0.00 total_cost_delivered,\n                                CONCAT(FORMAT((po_quantity - COALESCE(b.quantity_delivered, 0)), 2), ' ', TRIM(stocking_unit)) quantity_undelivered,\n                                CONCAT(FORMAT(COALESCE(c.quantity_in_transit, 0), 2), ' ', TRIM(stocking_unit)) quantity_in_transit, \n                                0.00 total_cost_in_transit,\n                                a.warehouse_store,\n                                warehouse_store_id,\n                                a.supplier_id,\n                                po_date, \n                                a.item_id ";
    END IF;

    SET @sqlCommand = "FROM \n                        (\n                            SELECT \n                                DATE_FORMAT(bb.date_requested, '%Y %b %d') fmt_po_date,\n                                bb.po_id po_reference,\n                                ff.entity_name, \n                                dd.category,\n                                dd.brand,\n                                CONCAT(dd.model_description, item_size, item_ratio, item_thread_pattern, item_valve_type, item_part_description, item_part_number) item,\n                                dd.stocking_unit, \n                                aa.quantity po_quantity,\n                                aa.unit_cost po_unitcost,\n                                aa.total_cost po_total_cost,\n                                ee.unit_id warehouse_store_id,\n                                ee.description warehouse_store,\n                                CONCAT(RPAD(aa.po_id, 8, 0), LPAD(aa.unit_item_id, 8, 0)) po_item_id, \n                                DATE(bb.date_requested) po_date,\n                                ff.entity_id supplier_id,\n                                dd.item_id\n                            FROM \n                                purchases_ap.po_details aa\n                            INNER JOIN\n                                purchases_ap.po_main bb \n                            ON \n                                aa.po_id=bb.po_id \n                            INNER JOIN \n                                inventory.inventory_units_items cc \n                            ON\n                                aa.unit_item_id=cc.unit_item_id \n                            INNER JOIN \n                                (\n                                    SELECT \n                                        aaa.item_id,\n                                        bbb.description category,\n                                        CONCAT(' ', ccc.description) brand, \n                                        CONCAT(' ', TRIM(aaa.model_description)) model_description,\n                                        COALESCE(CONCAT(' ', ddd.description), '') item_size,\n                                        COALESCE(CONCAT(' ', eee.description), '') item_ratio,\n                                        COALESCE(CONCAT(' ', fff.description), '') item_thread_pattern, \n                                        COALESCE(CONCAT(' ', ggg.description), '') item_valve_type, \n                                        COALESCE(CONCAT(' ', hhh.description), '') item_part_description, \n                                        COALESCE(CONCAT(' ', iii.description), '') item_part_number, \n                                        aaa.stocking_unit, \n                                        aaa.retail_unit,\n                                        aaa.rtu_over_stu,\n                                        aaa.item_category_id,\n                                        aaa.brand_id\n                                    FROM \n                                        inventory.inventory_items aaa \n                                    INNER JOIN \n                                        inventory.items_categories bbb \n                                    ON \n                                        aaa.item_category_id=bbb.item_category_id \n                                    INNER JOIN \n                                        inventory.brands ccc \n                                    ON\n                                        aaa.brand_id=ccc.brand_id\n                                    LEFT JOIN \n                                        inventory.sizes ddd \n                                    ON\n                                        aaa.size_id=ddd.size_id \n                                    LEFT JOIN \n                                        inventory.ratios eee \n                                    ON \n                                        aaa.ratio_id=eee.ratio_id \n                                    LEFT JOIN \n                                        inventory.thread_patterns fff \n                                    ON \n                                        aaa.pattern_id=fff.pattern_id \n                                    LEFT JOIN \n                                        inventory.valve_types ggg \n                                    ON \n                                        aaa.valve_id=ggg.valve_id \n                                    LEFT JOIN \n                                        inventory.vehicle_parts hhh \n                                    ON \n                                        aaa.part_id=hhh.part_id \n                                    LEFT JOIN \n                                        inventory.vehicle_part_numbers iii\n                                    ON \n                                        aaa.part_number_id=iii.part_number_id\n                                ) dd \n                            ON \n                                cc.item_id=dd.item_id \n                            INNER JOIN     \n                                subscriber_common_tables.units ee \n                            ON \n                                cc.unit_id=ee.unit_id \n                            INNER JOIN \n                                entities_udf_and_views.entity_name ff \n                            ON \n                                bb.supplier_id=ff.entity_id\n                        ) a \n                    LEFT JOIN \n                        (\n                            SELECT \n                                po_item, \n                                SUM(quantity) quantity_delivered,\n                                SUM(total_cost) total_cost_delivered\n                            FROM \n                                (\n                                    SELECT \n                                        CONCAT(RPAD(ccc.po_id, 8, 0), LPAD(aaa.unit_item_id, 8, 0)) po_item,\n                                        aaa.quantity,\n                                        aaa.total_cost, \n                                        DATE(bbb.delivery_date) delivery_date,\n                                        DATE(ddd.datetime_posted) po_date,\n                                        ddd.supplier_id \n                                    FROM\n                                        purchases_ap.deliveries_details aaa \n                                    INNER JOIN \n                                        purchases_ap.deliveries bbb \n                                    ON\n                                        aaa.delivery_id=bbb.delivery_id \n                                    INNER JOIN \n                                        purchases_ap.for_deliveries ccc\n                                    ON\n                                        bbb.for_delivery_id=ccc.for_delivery_id \n                                    INNER JOIN \n                                        purchases_ap.po_main ddd \n                                    ON\n                                        ccc.po_id=ddd.po_id \n                                ) aa \n                            GROUP BY \n                                po_item\n                        ) b \n                    ON \n                        a.po_item_id=b.po_item\n                    LEFT JOIN \n                        (\n                            SELECT \n                                po_item, \n                                SUM(quantity_in_transit) quantity_in_transit,\n                                SUM(total_cost_in_transit) total_cost_in_transit\n                            FROM \n                                (\n                                    SELECT \n                                        CONCAT(RPAD(ccc.po_id, 8, 0), LPAD(aaa.unit_item_id, 8, 0)) po_item,\n                                        aaa.quantity quantity_in_transit,\n                                        aaa.total_cost total_cost_in_transit,\n                                        DATE(bbb.date_confirmed) transit_date,\n                                        DATE(ccc.date_requested) po_date,\n                                        ccc.supplier_id \n                                    FROM \n                                        purchases_ap.for_deliveries_details aaa \n                                    INNER JOIN\n                                        purchases_ap.for_deliveries bbb \n                                    ON\n                                        aaa.for_delivery_id=bbb.for_delivery_id \n                                    INNER JOIN \n                                        purchases_ap.po_main ccc \n                                    ON\n                                        bbb.po_id=ccc.po_id \n                                    LEFT JOIN \n                                        purchases_ap.deliveries ddd \n                                    ON \n                                        bbb.for_delivery_id=ddd.for_delivery_id \n                                    WHERE \n                                        ddd.delivery_reference IS NULL\n                                ) aa \n                            GROUP BY \n                                po_item\n                        ) c \n                    ON \n                        a.po_item_id=c.po_item\n                    WHERE ";

    SET @sqlQueryFinal = CONCAT(stringFields, @sqlCommand, stringCondition, stringOrderBy);
    PREPARE query_statement FROM @sqlQueryFinal;
    EXECUTE query_statement;
    DEALLOCATE PREPARE query_statement;

    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Purchases report retrieved successfully.',
        'json_data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'fmt_po_date', fmt_po_date,
                    'po_reference', LPAD(po_reference, 8, 0),
                    'supplier', entity_name,
                    'category', category,
                    'brand', brand,
                    'item', item,
                    'po_quantity', po_quantity, 
                    'po_unitcost', FORMAT(po_unitcost, 2),
                    'po_total_cost', FORMAT(po_total_cost, 2),
                    'quantity_delivered', quantity_delivered,
                    'total_cost_delivered', FORMAT(total_cost_delivered, 2),
                    'quantity_undelivered', quantity_undelivered,
                    'quantity_in_transit', quantity_in_transit,
                    'total_cost_in_transit', total_cost_in_transit,
                    'warehouse_store', warehouse_store,
                    'warehouse_store_id', warehouse_store_id,
                    'supplier_id', supplier_id, 
                    'po_date', po_date,
                    'entry_identifier', 0,
                    'item_id', item_id
                )
            ),
            JSON_ARRAY()
        )
    ) AS response
    FROM 
        app_bin.purchases;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getSalesReceivablesCollectionsJSON` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getSalesReceivablesCollectionsJSON`(IN jsonInput TEXT)
BEGIN
    DECLARE dateFrom DATE;
    DECLARE dateTo DATE;
    DECLARE charUnitList VARCHAR(255);
    DECLARE dateTemp DATE;
    DECLARE stringCondition TEXT;
    DECLARE stringOrderBy VARCHAR(255);

    SET dateFrom = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.start_date')) AS DATE);
    SET dateTo = CAST(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.end_date')) AS DATE);

    SELECT GROUP_CONCAT(unit SEPARATOR ',') INTO charUnitList
    FROM JSON_TABLE(jsonInput, '$.units[*]' COLUMNS (unit VARCHAR(50) PATH '$')) jt;

    IF dateFrom > dateTo THEN
        SET dateTemp = dateFrom;
        SET dateFrom = dateTo;
        SET dateTo = dateTemp;
    END IF;

    SET stringCondition = CONCAT("DATE(a.payment_date) BETWEEN '", dateFrom, "' AND '", dateTo, "'");

    IF charUnitList IS NOT NULL AND charUnitList <> '' THEN
        SET stringCondition = CONCAT(stringCondition, " AND e.unit_id IN (", charUnitList, ")");
    END IF;

    SET stringOrderBy = " ORDER BY e.description, payment_date, customer";

    DROP TEMPORARY TABLE IF EXISTS app_bin.source_collections;

    SET @sqlCommand = CONCAT("CREATE TEMPORARY TABLE app_bin.source_collections AS SELECT DATE(a.payment_date) AS payment_date, c.entity_name AS customer, a.payment_reference, b.invoice_reference, a.amount_paid, e.description AS unit, e.unit_id FROM point_of_sales_ar.ar_payments a INNER JOIN point_of_sales_ar.pos_invoices b ON a.invoice_id = b.invoice_id INNER JOIN entities_udf_and_views.entity_name c ON a.entity_id = c.entity_id INNER JOIN application_users_point_of_sales_ar.application_users d ON b.posted_by = d.user_id INNER JOIN subscriber_common_tables.units e ON d.unit_id = e.unit_id WHERE ", stringCondition, stringOrderBy);

    PREPARE stmt FROM @sqlCommand;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;

    SET @jsonQuery = CONCAT(
        'SELECT JSON_OBJECT(',
            '\'success\', TRUE, ',
            '\'message\', \'Sales receivables collections retrieved successfully.\', ',
            '\'json_data\', COALESCE(JSON_ARRAYAGG(JSON_OBJECT(',
                '\'payment_date\', DATE_FORMAT(payment_date, "%Y-%m-%d"), ',
                '\'customer\', customer, ',
                '\'payment_reference\', payment_reference, ',
                '\'invoice_reference\', invoice_reference, ',
                '\'amount_paid\', FORMAT(amount_paid, 2), ',
                '\'unit\', unit, ',
                '\'unit_id\', unit_id',
            ')), JSON_ARRAY())',
        ') AS response FROM app_bin.source_collections'
    );

    PREPARE stmt2 FROM @jsonQuery;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getSalesReport` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getSalesReport`(
    IN jsonInput JSON
)
BEGIN 
    DECLARE dateFrom DATE;
    DECLARE dateTo DATE;
    DECLARE charUnitListStr VARCHAR(255);
    DECLARE dateTemp DATE;
    DECLARE stringCondition VARCHAR(1000);

    -- Extract values from JSON input and format dates securely
    SET dateFrom = STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.start_date')), '%Y-%m-%d');
    SET dateTo = STR_TO_DATE(JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.end_date')), '%Y-%m-%d');
    
    -- Extract charUnitList and instantly clean up array brackets so "[1,2]" safely becomes "1,2"
    SET charUnitListStr = JSON_UNQUOTE(JSON_EXTRACT(jsonInput, '$.charUnitList'));
    SET charUnitListStr = REPLACE(REPLACE(charUnitListStr, '[', ''), ']', '');

    -- Swap dates if dateFrom is greater than dateTo
    IF dateFrom > dateTo THEN
        SET dateTemp = dateFrom;
        SET dateFrom = dateTo;
        SET dateTo = dateTemp;
    END IF;

    -- Build the base string condition for the date range
    SET stringCondition = CONCAT("DATE(a.invoice_date) BETWEEN '", dateFrom, "' AND '", dateTo, "'");

    -- Add unit filter condition if units were provided and not zero/empty
    IF charUnitListStr IS NOT NULL AND charUnitListStr NOT IN ('', '0', 'null') THEN
        SET stringCondition = CONCAT(stringCondition, ' AND d.unit_id IN (', charUnitListStr, ')');
    END IF;

    -- Drop temporary table if it exists
    DROP TEMPORARY TABLE IF EXISTS app_bin.sales_report;

    -- Create temporary table with accurate sales report schema (From Version 1)
    SET @sqlCommand = "CREATE TEMPORARY TABLE app_bin.sales_report
                       SELECT 
					        COALESCE(d.description, '') AS warehouse_store,
					        DATE_FORMAT(a.invoice_date, '%Y %b %d') AS invoice_date,
					        a.invoice_reference AS invoice,
					        IF(a.walk_in, a.walk_in_name, COALESCE(e.entity_name, '')) AS client,
					        (a.total_amount - COALESCE(b.service_cost, 0.00)) AS sales_inventory,
					        COALESCE(b.service_cost, 0.00) AS sales_service,
					        a.total_amount AS gross_sales,
					        a.discount,
					        (a.total_amount - a.discount) AS net_sales,
					        a.net_amount_due,
					        su.full_name AS posted_by,
					        0 AS entry_identifier, 
                            COALESCE(d.unit_id, 0) AS unit_id, 
                            DATE(a.invoice_date) AS inv_date
                       FROM 
					        point_of_sales_ar.pos_invoices a
                       LEFT JOIN
					        (
						        SELECT 
							        cc.invoice_id,
							        SUM(aa.service_cost) AS service_cost
						        FROM 
							        point_of_sales_ar.services_job_order aa
						        INNER JOIN 
							        point_of_sales_ar.services bb ON aa.service_id=bb.service_id
						        INNER JOIN
							        point_of_sales_ar.job_orders cc ON aa.job_order_id=cc.job_order_id
						        WHERE 
							        cc.job_order_closed AND NOT cc.invoice_id IS NULL
						        GROUP BY 
							        cc.invoice_id
					        ) b ON a.invoice_id=b.invoice_id
                       LEFT JOIN 
					        application_users_point_of_sales_ar.application_users c ON a.posted_by=c.user_id
                       LEFT JOIN 
					        subscriber_common_tables.units d ON c.unit_id=d.unit_id
                       LEFT JOIN 
					        entities_udf_and_views.entity_name e ON a.entity_id=e.entity_id 
					   INNER JOIN 
					   		application_users_point_of_sales_ar.subscribers_applications_user sau ON sau.user_id = c.user_id 
					   INNER JOIN 
					   		application_users_point_of_sales_ar.subscribers_users su ON su.subscriber_user_id = sau.subscriber_user_id 
                       WHERE ";
                       
    SET @sqlQueryFinal = CONCAT(@sqlCommand, stringCondition);
    PREPARE query_statement FROM @sqlQueryFinal;
    EXECUTE query_statement;
    DEALLOCATE PREPARE query_statement;

    -- Select results and return as safe JSON array
    SELECT JSON_OBJECT(
        'success', TRUE,
        'message', 'Sales report retrieved successfully.',
        'json_data', COALESCE(
            JSON_ARRAYAGG(
                JSON_OBJECT(
                    'warehouse_store', warehouse_store,
                    'invoice_date', invoice_date,
                    'invoice', invoice,
                    'client', client,
                    'sales_inventory', FORMAT(sales_inventory, 2),
                    'sales_service', FORMAT(sales_service, 2),
                    'gross_sales', FORMAT(gross_sales, 2),
                    'discount', FORMAT(discount, 2),
                    'net_sales', FORMAT(net_sales, 2),
                    'amount_paid', FORMAT(net_amount_due, 2),
                    'posted_by', posted_by,
                    'entry_identifier', entry_identifier,
                    'unit_id', unit_id,
                    'inv_date', DATE_FORMAT(inv_date, '%m/%d/%y')
                )
            ),
            JSON_ARRAY() -- Safe fallback if no records match
        )
    ) AS response
    FROM (
        SELECT *
        FROM app_bin.sales_report
        ORDER BY warehouse_store, entry_identifier, inv_date
    ) AS combined;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getSelectableGlslAccount` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getSelectableGlslAccount`(
    IN jsnSelectable JSON
)
BEGIN
    DECLARE v_glsl_id BIGINT DEFAULT 0;
    DECLARE v_account_desc VARCHAR(100) DEFAULT NULL;

    IF JSON_VALID(jsnSelectable) THEN
        SET v_glsl_id    = COALESCE(JSON_VALUE(jsnSelectable, '$.glsl_id'), 0);
        SET v_account_desc = JSON_VALUE(jsnSelectable, '$.account_description');

        SET @sqlCommand = CONCAT(
            "SELECT JSON_OBJECT(",
                "'success', TRUE, ",
                "'message', 'Selectable accounts fetched successfully.', ",
                "'json_data', IFNULL(JSON_ARRAYAGG(JSON_OBJECT(",
                    "'glsl_id', glsl_id, ",
                    "'account', account ",
                ") ORDER BY glsl_id), JSON_ARRAY()) ",
            ") AS response ",
            "FROM accounting.selectable_account_concatenated ",
            "WHERE glsl_id <> (SELECT IFNULL(cash_account, 0) FROM funds.funds_parms LIMIT 1) "
        );

        IF v_glsl_id > 0 THEN
            SET @sqlCommand = CONCAT(@sqlCommand,
                "AND glsl_id = ", v_glsl_id, " "
            );
        ELSEIF v_account_desc IS NOT NULL THEN
            SET @sqlCommand = CONCAT(@sqlCommand,
                "AND search_account LIKE '%", v_account_desc, "%' "
            );
        END IF;

        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement;
        DEALLOCATE PREPARE query_statement;

    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON input',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getUnit`(IN jsnUnit JSON)
BEGIN
    IF JSON_VALID(jsnUnit) THEN
        SET @whereCredentials = '';
        IF JSON_VALUE(jsnUnit, '$.unit_id') IS NOT NULL THEN
            SET @whereCredentials = CONCAT(' WHERE u.unit_id = ', JSON_VALUE(jsnUnit, '$.unit_id'));
        END IF;

        SET @sqlCommand = CONCAT("
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'Unit retrieved successfully.',
                'json_data', COALESCE(
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'unit_id', unit_id,
                            'description', description
                        )
                    ),
                    JSON_ARRAY()
                )
            ) AS response
            FROM (
                SELECT u.unit_id, u.description
                FROM subscriber_common_tables.units u",
            @whereCredentials,
            ") AS combined");

        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON input.',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getUnitBinExceptOne` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getUnitBinExceptOne`(IN jsnUnitBinExceptOne JSON)
BEGIN
    IF JSON_VALID(jsnUnitBinExceptOne) THEN
        SET @intUnitId = JSON_VALUE(jsnUnitBinExceptOne, '$.unit_id');
        SET @charDescription = CONCAT('%', JSON_VALUE(jsnUnitBinExceptOne, '$.description'), '%');
        SET @intBinId = JSON_VALUE(jsnUnitBinExceptOne, '$.bin_id');

        SET @sqlCommand = "
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'Unit bins retrieved successfully.',
                'json_data', COALESCE(
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'bin_id', bin_id,
                            'bin', bin
                        )
                    ),
                    JSON_ARRAY()
                )
            ) AS response
            FROM (
                SELECT ub.bin_id, ub.bin
                FROM inventory.unit_bins ub
                WHERE ub.unit_id = ?
                  AND ub.bin LIKE ?
                  AND ub.bin_id NOT IN (?)
            ) AS combined";

        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt USING @intUnitId, @charDescription, @intBinId;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON input.',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getUnitItemInfoByBin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getUnitItemInfoByBin`(IN jsnUnitItemInfoByBin JSON)
BEGIN
    IF JSON_VALID(jsnUnitItemInfoByBin) THEN
        SET @intBinId = JSON_VALUE(jsnUnitItemInfoByBin, '$.bin_id');

        SET @sqlCommand = "
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'Unit item info retrieved successfully.',
                'json_data', COALESCE(
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'unit_item_id', unit_item_id,
                            'item_description', item_description,
                            'from_bin_id', from_bin_id,
                            'from_bin', from_bin
                        )
                    ),
                    JSON_ARRAY()
                )
            ) AS response
            FROM (
                SELECT
                    uii.unit_item_id,
                    iic.item_description,
                    ub.bin_id AS from_bin_id,
                    ub.bin AS from_bin
                FROM inventory.inventory_units_items uii
                INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iic.item_id = uii.item_id
                INNER JOIN inventory.unit_bins ub ON ub.bin_id = uii.bin_id
                WHERE ub.bin_id = ?
            ) AS combined";

        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt USING @intBinId;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON input.',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getUnitName` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getUnitName`(IN jsnUnit JSON)
BEGIN
    IF JSON_VALID(jsnUnit) THEN
        SET @whereCredentials = '';
        IF JSON_VALUE(jsnUnit, '$.unit_id') IS NOT NULL THEN
            SET @whereCredentials = CONCAT(' AND u.unit_id = ', JSON_VALUE(jsnUnit, '$.unit_id'));
        END IF;

        SET @sqlCommand = CONCAT("
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'Unit name retrieved successfully.',
                'json_data', COALESCE(
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'unit_id', unit_id,
                            'description', description
                        )
                    ),
                    JSON_ARRAY()
                )
            ) AS response
            FROM (
                SELECT u.unit_id, u.description
                FROM subscriber_common_tables.units u
                WHERE 1 = 1",
            @whereCredentials,
            ") AS combined_units");

        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON input.',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getUserDesignatedUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getUserDesignatedUnit`(IN jsonParam JSON)
BEGIN
    DECLARE intTaskID INT;
    SET intTaskID = JSON_VALUE(jsonParam, '$.user_id');

    SET @sqlCommand = "
        SELECT JSON_OBJECT(
            'success', TRUE,
            'message', 'User designated unit retrieved successfully.',
            'json_data', COALESCE(
                JSON_ARRAYAGG(
                    JSON_OBJECT(
                        'user_id', user_id,
                        'unit', unit,
                        'head_office', head_office,
                        'unit_id', unit_id
                    )
                ),
                JSON_ARRAY()
            )
        ) AS response
        FROM (
            SELECT
                au.user_id,
                u.description AS unit,
                u.head_office,
                u.unit_id
            FROM subscriber_common_tables.units u
            INNER JOIN application_users_inventory.application_users au ON au.unit_id = u.unit_id";

    IF intTaskID IS NOT NULL THEN
        SET @sqlCommand = CONCAT(@sqlCommand, " WHERE au.user_id = ?) AS combined");
        SET @intTaskID = intTaskID;
        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt USING @intTaskID;
        DEALLOCATE PREPARE stmt;
    ELSE
        SET @sqlCommand = CONCAT(@sqlCommand, ") AS combined");
        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getUserUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getUserUnit`(in jsnUserUnit JSON)
BEGIN
    IF JSON_VALID(jsnUserUnit) THEN
        SET @intUserId = JSON_VALUE(jsnUserUnit, '$.user_id');
        SET @whereHeadOffice = '';
        IF JSON_VALUE(jsnUserUnit, '$.exclude_head_office') = 1 THEN
            SET @whereHeadOffice = ' AND !u.head_office';
        END IF;

        SET @selectUnit = CONCAT("
            SELECT COALESCE(au.unit_id, 0) INTO @unitId
            FROM application_users_accounting.application_users au
            INNER JOIN subscriber_common_tables.units u ON u.unit_id = au.unit_id
            WHERE au.user_id = ", @intUserId, @whereHeadOffice);
        PREPARE stmt1 FROM @selectUnit;
        EXECUTE stmt1;
        DEALLOCATE PREPARE stmt1;

        SET @sqlCommand = "
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'User unit retrieved successfully.',
                'json_data', COALESCE(
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'unit_id', unit_id,
                            'description', description
                        )
                    ),
                    JSON_ARRAY()
                )
            ) AS response
            FROM (
                SELECT u.unit_id, u.description
                FROM subscriber_common_tables.units u
                WHERE u.unit_id = ?
            ) AS combined";
        PREPARE stmt2 FROM @sqlCommand;
        EXECUTE stmt2 USING @unitId;
        DEALLOCATE PREPARE stmt2;
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON input.',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `getUserUnitArray` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `getUserUnitArray`(IN jsnUserUnitArray JSON)
BEGIN
    IF JSON_VALID(jsnUserUnitArray) THEN
        SET @intUserId = JSON_VALUE(jsnUserUnitArray, '$.user_id');

        SELECT COALESCE(au.unit_id, 0) INTO @unitId
        FROM application_users_inventory.application_users au
        INNER JOIN subscriber_common_tables.units u ON u.unit_id = au.unit_id
        WHERE au.user_id = @intUserId AND !u.head_office;

        IF @unitId IS NULL OR @unitId = 0 THEN
            SET @whereUnit = '';
        ELSE
            SET @whereUnit = CONCAT(' WHERE u.unit_id = ', @unitId);
        END IF;

        SET @sqlCommand = CONCAT("
            SELECT JSON_OBJECT(
                'success', TRUE,
                'message', 'User unit array retrieved successfully.',
                'json_data', COALESCE(
                    JSON_ARRAYAGG(
                        JSON_OBJECT(
                            'unit_id', unit_id,
                            'description', description
                        )
                    ),
                    JSON_ARRAY()
                )
            ) AS response
            FROM (
                SELECT u.unit_id, u.description
                FROM subscriber_common_tables.units u",
            @whereUnit,
            ") AS combined");
        PREPARE stmt FROM @sqlCommand;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE,
            'message', 'Invalid JSON input.',
            'json_data', NULL
        ) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postConfirmInTransitItems` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postConfirmInTransitItems`(
    IN jsnConfirmInTransitItems JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE intCount INT DEFAULT 0;

    DECLARE intUserId INT;
    DECLARE intInvoiceId INT;
    DECLARE jsnInTransitItems JSON;
    DECLARE jsnInTransitItemsLength INT DEFAULT 0;

    DECLARE intInTransitId INT;
    DECLARE dblQuantityConfirmed DOUBLE(9,2);

    IF JSON_VALID(jsnConfirmInTransitItems) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET intUserId = JSON_VALUE(jsnConfirmInTransitItems, '$.user_id');
        SET intInvoiceId = JSON_VALUE(jsnConfirmInTransitItems, '$.invoice_id');
        SET jsnInTransitItems = JSON_EXTRACT(jsnConfirmInTransitItems, '$.in_transit_items');

        IF JSON_VALID(jsnInTransitItems) THEN
            SET jsnInTransitItemsLength = JSON_LENGTH(jsnInTransitItems);
        ELSE
            SET bolProceed = FALSE;
            SET @responseMessage = 'Invalid in transit items value!';
        END IF;

        IF bolProceed THEN
            SET @countEntry = 0;
            SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM application_users_inventory.application_users WHERE user_id = ? LIMIT 1';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING intUserId;
            DEALLOCATE PREPARE query_statement;

            IF @countEntry = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'You have entered non-existing user!';
            END IF;
        END IF;

        IF bolProceed THEN
            SET @countEntry = 0;
            SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM application_users_inventory.application_users WHERE user_id = ? AND !ISNULL(unit_id) LIMIT 1';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING intUserId;
            DEALLOCATE PREPARE query_statement;

            IF @countEntry = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'Can not continue. Your user does not belong to any unit!';
            END IF;
        END IF;

        IF bolProceed THEN
            SET @countEntry = 0;
            SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM application_users_inventory.application_users au WHERE au.user_id = ? AND au.unit_id IN (SELECT COALESCE(au2.unit_id) FROM point_of_sales_ar.pos_invoices pi2 INNER JOIN application_users_inventory.application_users au2 ON pi2.posted_by = au2.user_id WHERE pi2.invoice_id = ?);';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING intUserId, intInvoiceId;
            DEALLOCATE PREPARE query_statement;

            IF @countEntry = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'You are not authorized to confirm in-transit items for this invoice!';
            END IF;
        END IF;

        IF bolProceed THEN
            CALL point_of_sales_ar_udf_and_views.getJSONSingleKeySum('quanttiy_confirmed', jsnInTransitItems, @response);

            IF JSON_VALUE(@response, '$.success') = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = JSON_VALUE(@response, '$.message');
            ELSE
                SET @itemTotalSales = CAST(JSON_VALUE(@response, '$.sum_total') AS DOUBLE);

                IF !(@itemTotalSales > 0) THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'You must confirm at least one item to continue!';
                END IF;
            END IF;
        END IF;

        SET autocommit = 0;
        START TRANSACTION;

        WHILE bolProceed AND intCount < jsnInTransitItemsLength DO
            SET intInTransitId = JSON_VALUE(jsnInTransitItems, CONCAT('$[', intCount, '].in_transit_id'));
            SET dblQuantityConfirmed = JSON_VALUE(jsnInTransitItems, CONCAT('$[', intCount, '].quanttiy_confirmed'));

            IF dblQuantityConfirmed > 0 THEN
                SET @unitItemId = 0;
                IF bolProceed THEN
                    SET @countEntry = 0;
                    SET @remainingQuantity = 0;
                    SET @sqlCommand = 'SELECT COUNT(*), COALESCE(unit_item_id,0), COALESCE(running_quantity,0) INTO @countEntry, @unitItemId, @remainingQuantity FROM inventory.in_transit_items iti WHERE iti.item_transit_id = ? AND invoice_id = ? LIMIT 1';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intInTransitId, intInvoiceId;
                    DEALLOCATE PREPARE query_statement;

                    IF @countEntry = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Invoice and in-transit items mismatched!';
                    ELSEIF CAST(@remainingQuantity AS DOUBLE) = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'An in-transit item that is fully confirmed is included!';
                    ELSEIF dblQuantityConfirmed > CAST(@remainingQuantity AS DOUBLE) THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Quantity to be confirmed\'s value exceeds the in-transit item\'s remaining quantity!';
                    END IF;
                END IF;

                IF bolProceed THEN
                    SET @last_id = 0;
                    SET @sqlCommand = 'INSERT inventory.confirmed_transit_items (item_transit_id, quantity_confirmed, confirmed_by) VALUES (?,?,?)';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intInTransitId, dblQuantityConfirmed, intUserId;
                    SET @last_id = LAST_INSERT_ID();
                    DEALLOCATE PREPARE query_statement;

                    IF @last_id = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Failed to confirm an in-transit item';
                    END IF;
                END IF;

                IF bolProceed THEN
                    SET @rows_affected = 0;
                    SET @sqlCommand = 'UPDATE inventory.in_transit_items SET running_quantity = running_quantity - ? WHERE item_transit_id = ?';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING dblQuantityConfirmed, intInTransitId;
                    SELECT ROW_COUNT() INTO @rows_affected;
                    DEALLOCATE PREPARE query_statement;

                    IF @rows_affected = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Failed to update running quantity of in-transit item';
                    END IF;
                END IF;

                IF bolProceed THEN
                    SET @rows_affected = 0;
                    SET @sqlCommand = CONCAT('UPDATE inventory.inventory_units_items SET float_cost = float_cost - ((float_cost/float_quantity) * ', dblQuantityConfirmed, '), ending_cost = ending_cost + ((float_cost/float_quantity) * ', dblQuantityConfirmed, '), float_quantity = float_quantity - ', dblQuantityConfirmed, ', ending_quantity = ending_quantity + ', dblQuantityConfirmed, ', unit_cost = ending_cost/ending_quantity WHERE unit_item_id=? LIMIT 1');
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING @unitItemId;
                    SELECT ROW_COUNT() INTO @rows_affected;
                    DEALLOCATE PREPARE query_statement;

                    IF @rows_affected = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Failed to update quantity balance of in-transit item';
                    END IF;
                END IF;
            END IF;

            SET intCount = intCount + 1;
        END WHILE;

    END IF;

    IF bolProceed THEN
        SET @responseMessage = 'In-transit items successfully confirmed!';
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', 0) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;

    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postInternalItemAdjustment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postInternalItemAdjustment`(
		IN jsnInternalItemAdjustment JSON,
		OUT jsnResponse JSON
	)
BEGIN
	DECLARE bolProceed BOOLEAN DEFAULT TRUE;

	DECLARE intTemplateId INT(11);
	DECLARE intSourceUnitId INT(11);
	DECLARE intDestinationUnitId INT(11);
	DECLARE intItemId INT(11);
	DECLARE dblQuantity DOUBLE(10, 2);
	DECLARE decUnitCost DECIMAL(12, 2);
	DECLARE charRemarks VARCHAR(250);
	DECLARE intUserid INT(11);

	SET @last_id = "";

	IF JSON_VALID(jsnInternalItemAdjustment) THEN
		SET @responseMessage = "";
	ELSE
		SET bolProceed = FALSE;
		SET @responseMessage = "Please enter a valid parameter to continue!";
	END IF;

	IF bolProceed THEN
		SET intTemplateId = JSON_VALUE(jsnInternalItemAdjustment, '$.template_id');
		SET intSourceUnitId = JSON_VALUE(jsnInternalItemAdjustment, '$.source_unit_id');
		SET intDestinationUnitId = JSON_VALUE(jsnInternalItemAdjustment, '$.destination_unit_id');
		SET intItemId = JSON_VALUE(jsnInternalItemAdjustment, '$.item_id');
		SET dblQuantity = JSON_VALUE(jsnInternalItemAdjustment, '$.quantity');
		SET decUnitCost = JSON_VALUE(jsnInternalItemAdjustment, '$.unit_cost');
		SET charRemarks = JSON_VALUE(jsnInternalItemAdjustment, '$.remarks');
		SET intUserId = JSON_VALUE(jsnInternalItemAdjustment, '$.user_id');
	
		SET @itemName = "";
		SET @rtuOverStu = 1;
		
        -- Kept this query ONLY to get @rtuOverStu for warehouse math. Category ID is ignored now.
		SET @sqlCommand =  "SELECT 
								iic.item_description,
								COALESCE(ii.rtu_over_stu,1)
							INTO
								@itemName, @rtuOverStu
							FROM
								inventory.inventory_items ii
							INNER JOIN
								inventory_udf_and_views.inventory_item_concat iic
							ON
								ii.item_id = iic.item_id
							WHERE 	
								ii.item_id = ?
							LIMIT 1";
		PREPARE query_statement FROM @sqlCommand;
		EXECUTE query_statement USING intItemId;
		DEALLOCATE PREPARE query_statement;
	
		SET @templateType = 0;
		SET @sqlCommand =  "SELECT 
								CASE 
									WHEN add_to_quantity AND require_destination_and_source THEN 0
									WHEN add_to_quantity AND !require_destination_and_source THEN 1
									WHEN !add_to_quantity AND !require_destination_and_source THEN 2
								END
							INTO 
								@templateType
							FROM
								inventory.items_adjustments_templates
							WHERE 	
								template_id = ?
							LIMIT 1";
		PREPARE query_statement FROM @sqlCommand;
		EXECUTE query_statement USING intTemplateId;
		DEALLOCATE PREPARE query_statement;
	
		IF bolProceed THEN
			IF @templateType = 0 AND (!(COALESCE(intSourceUnitId,0) > 0) OR !(COALESCE(intDestinationUnitId,0) > 0)) THEN
				SET bolProceed = FALSE;
				SET @responseMessage = "Both source and destination unit are required for the chosen adjustment template!";
			ELSEIF @templateType = 1 AND !(COALESCE(intDestinationUnitId,0) > 0) THEN 
				SET bolProceed = FALSE;
				SET @responseMessage = "Destination unit is required for the chosen adjustment template!";
			ELSEIF @templateType = 2 AND !(COALESCE(intSourceUnitId,0) > 0) THEN 
				SET bolProceed = FALSE;
				SET @responseMessage = "Source unit is required for the chosen adjustment template!";
			END IF;
		END IF;
	
		IF bolProceed THEN
			SET @intItemSourceId = 0;
			SET @dblItemSourceQuantity = 0;
			SET @bolSrcWarehouse = 0;
			SET @sqlCommand =  "SELECT 
									COALESCE(iui.unit_item_id, 0), 
									COALESCE(iui.ending_quantity, 0),
									COALESCE(iu.warehouse,0)
								INTO 
									@intItemSourceId, @dblItemSourceQuantity, @bolSrcWarehouse
								FROM 
									inventory.inventory_units_items iui
								LEFT JOIN
									inventory.inventory_units iu 
								ON
									iui.unit_id = iu.unit_id 
								WHERE 
									iui.item_id=? AND iui.unit_id=? 
								LIMIT 1";
			PREPARE query_statement FROM @sqlCommand;
			EXECUTE query_statement USING intItemId, intSourceUnitId;
			DEALLOCATE PREPARE query_statement;
			
			SET @intItemDestinationId = 0;
			SET @bolDesWarehouse = 0;
			SET @sqlCommand =  "SELECT 
									COALESCE(iui.unit_item_id, 0),
									COALESCE(iu.warehouse,0)  
								INTO 
									@intItemDestinationId, @bolDesWarehouse
								FROM 
									inventory.inventory_units_items iui
								LEFT JOIN
									inventory.inventory_units iu 
								ON
									iui.unit_id = iu.unit_id 
								WHERE 
									iui.item_id=? AND iui.unit_id=? 
								LIMIT 1";
			PREPARE query_statement FROM @sqlCommand;
			EXECUTE query_statement USING intItemId, intDestinationUnitId;
			DEALLOCATE PREPARE query_statement;
		
			SET @destinationQuantity = CASE 
				WHEN @bolSrcWarehouse = @bolDesWarehouse THEN dblQuantity
				WHEN @bolSrcWarehouse = 0 AND @bolDesWarehouse = 1 THEN dblQuantity / CAST(@rtuOverStu AS INT)
				WHEN @bolSrcWarehouse = 1 AND @bolDesWarehouse = 0 THEN dblQuantity * CAST(@rtuOverStu AS INT)
			END;
		
			SET @destinationUnitCost = CASE 
				WHEN @bolSrcWarehouse = 0 AND @bolDesWarehouse = 1 THEN (decUnitCost * dblQuantity) / @destinationQuantity
				WHEN @bolSrcWarehouse = 1 AND @bolDesWarehouse = 0 THEN decUnitCost / CAST(@rtuOverStu AS INT)
				ELSE decUnitCost
			END;
		
			IF (@intItemSourceId IS NULL OR @intItemSourceId <= 0) AND (@intItemDestinationId IS NULL OR @intItemDestinationId <= 0) THEN 
				SET @responseMessage = "Must provide at least a Destination or Source Unit or Inventory Item.";
				SET bolProceed = FALSE;
			ELSEIF dblQuantity IS NULL OR dblQuantity <= 0 THEN 
				SET @responseMessage = "Adjustment Quantity CANNOT BE NULL OR LESS THAN OR EQUAL TO ZERO!";
				SET bolProceed = FALSE;
			ELSEIF intTemplateId IS NULL OR intTemplateId <= 0 THEN
				SET @responseMessage = "Must provide a corresponding adjustment template!";
				SET bolProceed = FALSE;
			END IF;
		
			IF bolProceed AND @intItemSourceId > 0 THEN 	
				IF @dblItemSourceQuantity >= dblQuantity THEN
					SET @sqlSourceCommand = "UPDATE 
												inventory.inventory_units_items 
											 SET 
												quantity_out =  quantity_out + ?,
		                                        ending_quantity = ending_quantity - ?,
		                                        cost_out =  cost_out + (? * unit_cost),
		                                        ending_cost =  ending_cost - (? * unit_cost)
											 WHERE
												unit_item_id=? LIMIT 1";
					PREPARE sqlCommand FROM @sqlSourceCommand;
					EXECUTE sqlCommand USING dblQuantity, dblQuantity, dblQuantity, dblQuantity, @intItemSourceId;
					DEALLOCATE PREPARE sqlCommand;
				ELSE
					SET @responseMessage = "Quantity adjustment provided is GREATER THAN the available quantity balance!";
					SET bolProceed = FALSE;
				END IF;				
			END IF;
		
			IF bolProceed AND @intItemDestinationId > 0 THEN 
				SET @sqlSourceCommand = "UPDATE 
											inventory.inventory_units_items 
										 SET 
											quantity_in =  quantity_in + ?,
		                                    ending_quantity = ending_quantity + ?,
		                                    cost_in =  cost_in + ?,
		                                    ending_cost =  ending_cost + ?,
		                                    unit_cost = ending_cost/ending_quantity,
		                                    last_highest_in_unit_cost = if(last_highest_in_unit_cost>?,last_highest_in_unit_cost,?)
										 WHERE
											unit_item_id=? LIMIT 1";
				PREPARE sqlCommand FROM @sqlSourceCommand;
				EXECUTE sqlCommand USING @destinationQuantity, @destinationQuantity, (@destinationQuantity * @destinationUnitCost), (@destinationQuantity * @destinationUnitCost), @destinationUnitCost, @destinationUnitCost, @intItemDestinationId;
				DEALLOCATE PREPARE sqlCommand;
			
				SET @sqlSourceCommand = "UPDATE inventory.inventory_items i
		                                JOIN (
		                                    SELECT 
											    a.item_id,
											    (SELECT 
													SUM(iui.ending_cost) / SUM(IF(iu.warehouse,iui.ending_quantity*ii.rtu_over_stu,iui.ending_quantity)) 
											     FROM 
													inventory.inventory_units_items iui
												 INNER JOIN
													 inventory.inventory_items ii
												 ON
													 iui.item_id = ii.item_id
												 INNER JOIN
													 inventory.inventory_units iu
												 ON
												     iui.unit_id = iu.unit_id
											     WHERE 
													iui.item_id = a.item_id) AS unit_cost,
											    (SELECT 
													MAX(IF(iu.warehouse,(iui.last_highest_in_unit_cost/ii.rtu_over_stu),iui.last_highest_in_unit_cost)) 
											     FROM 
													inventory.inventory_units_items iui
												 INNER JOIN
													 inventory.inventory_items ii
												 ON
													 iui.item_id = ii.item_id
												 INNER JOIN
													 inventory.inventory_units iu
												 ON
												     iui.unit_id = iu.unit_id
											     WHERE 
													iui.item_id =  a.item_id) AS last_highest_in_unit_cost
											FROM 
											    inventory.inventory_units_items a
											WHERE 
											    a.unit_item_id = ?
											GROUP BY 
											    a.item_id
		                                ) u ON i.item_id = u.item_id
		                                SET 
		                                    i.wtd_ave_cost = u.unit_cost,
		                                    i.last_highest_in_unit_cost = if(i.last_highest_in_unit_cost > u.last_highest_in_unit_cost, i.last_highest_in_unit_cost, u.last_highest_in_unit_cost),
		                                    i.selling_price = if(i.last_highest_in_unit_cost>u.last_highest_in_unit_cost, i.selling_price, u.last_highest_in_unit_cost *(1+i.markup_rate))
										LIMIT 1;";
				PREPARE sqlCommand FROM @sqlSourceCommand;
				EXECUTE sqlCommand USING @intItemDestinationId;
				DEALLOCATE PREPARE sqlCommand;
			END IF; 
			
            -- The massive batch loop is gone. Every item just inserts normally now.
			IF bolProceed THEN
                SET @last_id = "";
                SET @sqlSourceCommand = "INSERT 
                                            inventory.items_adjustments 
                                            (
                                                adjustment_date, 
                                                template_id, 
                                                destination_id,
                                                source_id,
                                                item_id, 
                                                quantity,
                                                unit_cost,
                                                remarks,
                                                created_by,
                                                datetime_created
                                            ) 
                                        VALUES 
                                            (
                                                NOW(), ?, ?, ?, ?, ?, ?, ?, ?, NOW()
                                            )";
                PREPARE sqlCommand FROM @sqlSourceCommand;
                EXECUTE sqlCommand USING intTemplateId, IF(@intItemDestinationId=0,NULL,@intItemDestinationId), IF(@intItemSourceId=0,NULL, @intItemSourceId), intItemId, dblQuantity, decUnitCost, charRemarks, intUserId;  
                SET @last_id = LAST_INSERT_ID(); 
                DEALLOCATE PREPARE sqlCommand;
			END IF;
		END IF;
	END IF;

	IF bolProceed THEN
		SET @responseMessage = "The adjustment has been successfully applied.";
		SET jsnResponse = CONCAT('{\"success\": 1, \"message\": \"', @responseMessage, '\", \"json_data\": \"',@last_id, '\" }');
	ELSE
		SET jsnResponse = CONCAT('{\"success\": 0, \"message\": \"', @responseMessage, '\", \"json_data\": \"',@last_id, '\" }');
	END IF;
   
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postInventoryItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postInventoryItem`(
    IN jsnInventoryItem JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE processType INT;
    DECLARE error_msg TEXT DEFAULT '';

    DECLARE intItemId INT;
    DECLARE intItemCategoryId INT;
    DECLARE intBrandId INT;
    DECLARE charModelDescription VARCHAR(60);
    DECLARE intPartId INT;
    DECLARE intPartNumberId INT;
    DECLARE intSizeId INT;
    DECLARE intValveId INT;
    DECLARE intRatioId INT;
    DECLARE intPatternId INT;
    DECLARE charStockingUnit VARCHAR(20);
    DECLARE charRetailUnit VARCHAR(20);
    DECLARE dblRTUOverSTU DOUBLE(10,2);
    DECLARE dblWtdAveCost DOUBLE(12,2);
    DECLARE dblMarkUpRate DOUBLE(6,2);
    DECLARE dblSellingPrice DOUBLE(9,2);
    DECLARE dblSellingPriceEdit DOUBLE(9,2) DEFAULT NULL;
    DECLARE intUserId INT;
    DECLARE boolEmptyCase INT DEFAULT 0;
    DECLARE binImage LONGBLOB DEFAULT NULL;
    DECLARE charBarcode VARCHAR(100) DEFAULT NULL;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1
            @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO,
            @text = MESSAGE_TEXT;
        SET error_msg = CONCAT('SQL Error: ', @errno, ' (', @sqlstate, '): ', @text);
        ROLLBACK;
        SET bolProceed = FALSE;
        RESIGNAL;
    END;

    SET @item_id = 0;
    SET @responseMessage = '';

    IF JSON_VALID(jsnInventoryItem) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET processType = CAST(JSON_VALUE(jsnInventoryItem, '$.process_type') AS UNSIGNED);

        IF processType NOT BETWEEN 0 AND 2 THEN
            SET bolProceed = FALSE;
            SET @responseMessage = 'Please enter a valid process type!';
        END IF;

        IF bolProceed THEN
            SET intItemCategoryId = CAST(JSON_VALUE(jsnInventoryItem, '$.item_category_id') AS UNSIGNED);
            SET intBrandId = CASE WHEN JSON_EXTRACT(jsnInventoryItem, '$.brand_id') IS NULL THEN NULL ELSE CAST(JSON_VALUE(jsnInventoryItem, '$.brand_id') AS UNSIGNED) END;
            SET charModelDescription = JSON_VALUE(jsnInventoryItem, '$.model_description');
            SET intPartId = CASE WHEN JSON_EXTRACT(jsnInventoryItem, '$.part_id') IS NULL THEN NULL ELSE CAST(JSON_VALUE(jsnInventoryItem, '$.part_id') AS UNSIGNED) END;
            SET intPartNumberId = CASE WHEN JSON_EXTRACT(jsnInventoryItem, '$.part_number_id') IS NULL THEN NULL ELSE CAST(JSON_VALUE(jsnInventoryItem, '$.part_number_id') AS UNSIGNED) END;
            SET intSizeId = CASE WHEN JSON_EXTRACT(jsnInventoryItem, '$.size_id') IS NULL THEN NULL ELSE CAST(JSON_VALUE(jsnInventoryItem, '$.size_id') AS UNSIGNED) END;
            SET intValveId = CASE WHEN JSON_EXTRACT(jsnInventoryItem, '$.valve_id') IS NULL THEN NULL ELSE CAST(JSON_VALUE(jsnInventoryItem, '$.valve_id') AS UNSIGNED) END;
            SET intRatioId = CASE WHEN JSON_EXTRACT(jsnInventoryItem, '$.ratio_id') IS NULL THEN NULL ELSE CAST(JSON_VALUE(jsnInventoryItem, '$.ratio_id') AS UNSIGNED) END;
            SET intPatternId = CASE WHEN JSON_EXTRACT(jsnInventoryItem, '$.pattern_id') IS NULL THEN NULL ELSE CAST(JSON_VALUE(jsnInventoryItem, '$.pattern_id') AS UNSIGNED) END;
            SET charStockingUnit = JSON_VALUE(jsnInventoryItem, '$.stocking_unit');
            SET charRetailUnit = JSON_VALUE(jsnInventoryItem, '$.retail_unit');
            SET dblRTUOverSTU = CAST(JSON_VALUE(jsnInventoryItem, '$.rtu_over_stu') AS DECIMAL(10,2));
            SET dblWtdAveCost = CAST(JSON_VALUE(jsnInventoryItem, '$.wtd_ave_cost') AS DECIMAL(12,2));
            SET dblMarkUpRate = CAST(JSON_VALUE(jsnInventoryItem, '$.mark_up_rate') AS DECIMAL(6,2));
            SET dblSellingPriceEdit = CASE WHEN JSON_EXTRACT(jsnInventoryItem, '$.selling_price') IS NULL THEN NULL ELSE CAST(JSON_VALUE(jsnInventoryItem, '$.selling_price') AS DECIMAL(9,2)) END;
            SET intUserId = CAST(JSON_VALUE(jsnInventoryItem, '$.user_id') AS UNSIGNED);
            SET boolEmptyCase = CAST(JSON_VALUE(jsnInventoryItem, '$.has_empty_case') AS UNSIGNED);
            
            SET binImage = JSON_UNQUOTE(JSON_EXTRACT(jsnInventoryItem, '$.image'));
            IF binImage = '' OR binImage = 'null' THEN SET binImage = NULL; END IF;

            -- Extract the barcode if scanned from the frontend
            SET charBarcode = JSON_UNQUOTE(JSON_EXTRACT(jsnInventoryItem, '$.barcode'));
            IF charBarcode = '' OR charBarcode = 'null' THEN SET charBarcode = NULL; END IF;

            IF processType BETWEEN 1 AND 2 THEN
                SET intItemId = CAST(JSON_VALUE(jsnInventoryItem, '$.item_id') AS UNSIGNED);
            END IF;

            IF dblSellingPriceEdit IS NOT NULL THEN
                SET dblSellingPrice = dblSellingPriceEdit;
            ELSEIF processType = 0 THEN
                SET dblSellingPrice = (dblWtdAveCost + (dblWtdAveCost * (dblMarkUpRate / 100)));
            ELSEIF processType = 1 THEN
                SET @sqlCommand = 'SELECT selling_price INTO @dbSellingPrice FROM inventory.inventory_items WHERE item_id = ?;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intItemId;
                DEALLOCATE PREPARE query_statement;
                SET dblSellingPrice = COALESCE(@dbSellingPrice, 0);
            END IF;

            IF bolProceed AND processType <> 0 THEN
                SET @rowCount = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.inventory_items WHERE item_id = ?;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intItemId;
                DEALLOCATE PREPARE query_statement;

                IF @rowCount = 0 THEN
                    SET bolProceed = FALSE;
                    IF processType = 1 THEN
                        SET @responseMessage = 'Can not modify non-existent entry!';
                    ELSEIF processType = 2 THEN
                        SET @responseMessage = 'Can not delete non-existent entry!';
                    END IF;
                END IF;
            END IF;

            IF bolProceed THEN
                SET autocommit = 0;
                START TRANSACTION;

                IF processType = 0 THEN
                    SET @sqlCommand = 'INSERT INTO inventory.inventory_items (item_category_id, brand_id, model_description, part_id, part_number_id, size_id, valve_id, ratio_id, pattern_id, stocking_unit, retail_unit, rtu_over_stu, wtd_ave_cost, markup_rate, selling_price, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? / 100, ?, ?);';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intItemCategoryId, intBrandId, charModelDescription, intPartId, intPartNumberId, intSizeId, intValveId, intRatioId, intPatternId, charStockingUnit, charRetailUnit, dblRTUOverSTU, dblWtdAveCost, dblMarkUpRate, dblSellingPrice, intUserId;
                    SET @item_id = LAST_INSERT_ID();
                    SET @main_item_id = @item_id;
                    DEALLOCATE PREPARE query_statement;

                    IF @item_id = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Failed to save inventory item entry!';
                    END IF;

                    -- Insert Barcode for Main Item (Create)
                    IF bolProceed THEN
                        SET @barcodeValue = COALESCE(charBarcode, CONCAT('INV-', LPAD(@item_id, 6, '0')));
                        SET @barcodeType = IF(charBarcode IS NOT NULL, 'SCANNED', 'INTERNAL');

                        SET @sqlCommand = 'INSERT INTO inventory.inventory_item_barcodes (item_id, barcode_value, barcode_type, created_by) VALUES (?, ?, ?, ?);';
                        PREPARE stmt_bc FROM @sqlCommand;
                        EXECUTE stmt_bc USING @item_id, @barcodeValue, @barcodeType, intUserId;
                        DEALLOCATE PREPARE stmt_bc;
                    END IF;

                    IF bolProceed AND binImage IS NOT NULL THEN
                        SET @sqlCommand = 'INSERT INTO inventory.item_images (item_id, image) VALUES (?, ?);';
                        PREPARE stmt_img FROM @sqlCommand;
                        EXECUTE stmt_img USING @item_id, binImage;
                        DEALLOCATE PREPARE stmt_img;
                    END IF;

                    IF boolEmptyCase = 1 THEN
                        SET @modelWithCase = CONCAT(charModelDescription, ' - Case');
                        SET @sqlCommand = 'INSERT INTO inventory.inventory_items (item_category_id, brand_id, model_description, part_id, part_number_id, size_id, valve_id, ratio_id, pattern_id, stocking_unit, retail_unit, rtu_over_stu, wtd_ave_cost, markup_rate, selling_price, created_by) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ? / 100, ?, ?);';
                        PREPARE query_statement FROM @sqlCommand;
                        EXECUTE query_statement USING intItemCategoryId, intBrandId, @modelWithCase, intPartId, intPartNumberId, intSizeId, intValveId, intRatioId, intPatternId, charStockingUnit, charRetailUnit, dblRTUOverSTU, dblWtdAveCost, dblMarkUpRate, dblSellingPrice, intUserId;
                        SET @empty_item_id = LAST_INSERT_ID();
                        DEALLOCATE PREPARE query_statement;

                        IF @empty_item_id = 0 THEN
                            SET bolProceed = FALSE;
                            SET @responseMessage = 'Failed to save empty case inventory item entry!';
                        END IF;

                        -- Insert Barcode for Empty Case
                        IF bolProceed THEN
                            SET @emptyBarcodeValue = CONCAT('INV-', LPAD(@empty_item_id, 6, '0'), '-CASE');
                            SET @sqlCommand = 'INSERT INTO inventory.inventory_item_barcodes (item_id, barcode_value, barcode_type, created_by) VALUES (?, ?, ?, ?);';
                            PREPARE stmt_bc_empty FROM @sqlCommand;
                            EXECUTE stmt_bc_empty USING @empty_item_id, @emptyBarcodeValue, 'INTERNAL', intUserId;
                            DEALLOCATE PREPARE stmt_bc_empty;
                        END IF;

                        IF bolProceed THEN
                            SET @sqlCommand = 'INSERT INTO inventory.inventory_empty_cases (main_item_id, empty_item_id) VALUES (?, ?);';
                            PREPARE query_statement FROM @sqlCommand;
                            EXECUTE query_statement USING @main_item_id, @empty_item_id;
                            DEALLOCATE PREPARE query_statement;
                        END IF;
                    END IF;
                END IF;

                IF bolProceed AND processType = 1 THEN
                    SET @rows_affected = 0;
                    SET @sqlCommand = 'UPDATE inventory.inventory_items SET brand_id = ?, model_description = ?, part_id = ?, part_number_id = ?, size_id = ?, valve_id = ?, ratio_id = ?, pattern_id = ?, stocking_unit = ?, retail_unit = ?, rtu_over_stu = ?, wtd_ave_cost = ?, markup_rate = ? / 100, selling_price = ?, modified_by = ?, datetime_modified = NOW() WHERE item_id = ?;';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intBrandId, charModelDescription, intPartId, intPartNumberId, intSizeId, intValveId, intRatioId, intPatternId, charStockingUnit, charRetailUnit, dblRTUOverSTU, dblWtdAveCost, dblMarkUpRate, dblSellingPrice, intUserId, intItemId;
                    SELECT ROW_COUNT() INTO @rows_affected;
                    DEALLOCATE PREPARE query_statement;
                    SET @item_id = intItemId;

                    -- Update Barcode logic for existing items: DELETE OLD, INSERT NEW
                    IF charBarcode IS NOT NULL THEN
                        -- 1. Delete the existing barcode(s) for this item
                        SET @sqlCommand = 'DELETE FROM inventory.inventory_item_barcodes WHERE item_id = ?;';
                        PREPARE stmt_del_bc FROM @sqlCommand;
                        EXECUTE stmt_del_bc USING intItemId;
                        DEALLOCATE PREPARE stmt_del_bc;

                        -- 2. Insert the newly scanned barcode
                        SET @sqlCommand = 'INSERT INTO inventory.inventory_item_barcodes (item_id, barcode_value, barcode_type, created_by) VALUES (?, ?, ?, ?);';
                        PREPARE stmt_bc FROM @sqlCommand;
                        EXECUTE stmt_bc USING intItemId, charBarcode, 'SCANNED', intUserId;
                        DEALLOCATE PREPARE stmt_bc;
                    ELSE
                        -- No barcode scanned. Check if the item has ZERO barcodes. If so, auto-generate one!
                        SET @totalBarcodes = 0;
                        SET @sqlCommand = 'SELECT COUNT(*) INTO @totalBarcodes FROM inventory.inventory_item_barcodes WHERE item_id = ?;';
                        PREPARE stmt_check FROM @sqlCommand;
                        EXECUTE stmt_check USING intItemId;
                        DEALLOCATE PREPARE stmt_check;

                        IF @totalBarcodes = 0 THEN
                            SET @barcodeValue = CONCAT('INV-', LPAD(intItemId, 6, '0'));
                            SET @sqlCommand = 'INSERT INTO inventory.inventory_item_barcodes (item_id, barcode_value, barcode_type, created_by) VALUES (?, ?, ?, ?);';
                            PREPARE stmt_bc FROM @sqlCommand;
                            EXECUTE stmt_bc USING intItemId, @barcodeValue, 'INTERNAL', intUserId;
                            DEALLOCATE PREPARE stmt_bc;
                        END IF;
                    END IF;

                    IF binImage IS NOT NULL THEN
                        SET @sqlCommand = 'REPLACE INTO inventory.item_images (item_id, image) VALUES (?, ?);';
                        PREPARE stmt_img FROM @sqlCommand;
                        EXECUTE stmt_img USING intItemId, binImage;
                        DEALLOCATE PREPARE stmt_img;
                    END IF;
                END IF;

                IF bolProceed AND processType = 2 THEN
                    DELETE FROM inventory.inventory_units_items WHERE item_id = intItemId;
                    DELETE FROM inventory.item_images WHERE item_id = intItemId;
                    DELETE FROM inventory.inventory_empty_cases WHERE main_item_id = intItemId OR empty_item_id = intItemId;
                    DELETE FROM inventory.inventory_item_barcodes WHERE item_id = intItemId;

                    SET @rows_affected = 0;
                    SET @sqlCommand = 'DELETE FROM inventory.inventory_items WHERE item_id = ?';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intItemId;
                    SELECT ROW_COUNT() INTO @rows_affected;
                    DEALLOCATE PREPARE query_statement;

                    IF @rows_affected = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Failed to delete inventory item entry! Item may not exist or already deleted.';
                    ELSE
                        SET @item_id = intItemId;
                    END IF;
                END IF;

                IF bolProceed THEN
                    COMMIT;
                ELSE
                    ROLLBACK;
                END IF;

                SET autocommit = 1;
            END IF;
        END IF;
    END IF;

    IF bolProceed THEN
        IF processType = 0 THEN
            SET @responseMessage = 'Inventory Item Successfully Saved!';
            SET @json_data = @item_id;
            IF boolEmptyCase = 1 THEN
                SET @json_data = CONCAT(@item_id, ',', @empty_item_id);
            END IF;
        ELSEIF processType = 1 THEN
            SET @responseMessage = 'Inventory Item Successfully Updated!';
            SET @json_data = @item_id;
        ELSEIF processType = 2 THEN
            SET @responseMessage = 'Inventory Item Successfully Deleted!';
            SET @json_data = @item_id;
        END IF;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', @json_data) AS response;
    ELSE
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postInventoryItemAdjustment` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postInventoryItemAdjustment`(
    IN jsnInventoryItemAdjustment JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;

    DECLARE intTemplateId INT(11);
    DECLARE intSourceUnitId INT(11);
    DECLARE intDestinationUnitId INT(11);
    DECLARE intItemId INT(11);
    DECLARE dblQuantity DOUBLE(10, 2);
    DECLARE decUnitCost DECIMAL(12, 2);
    DECLARE charRemarks VARCHAR(250);
    DECLARE intUserId INT(11);

    SET @last_id = "";

    -- 1. Validation Logic
    IF JSON_VALID(jsnInventoryItemAdjustment) THEN
        SET @responseMessage = "";
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = "Please enter a valid parameter to continue!";
    END IF;

    IF bolProceed THEN
        SET intTemplateId = JSON_VALUE(jsnInventoryItemAdjustment, '$.template_id');
        SET intSourceUnitId = JSON_VALUE(jsnInventoryItemAdjustment, '$.source_unit_id');
        SET intDestinationUnitId = JSON_VALUE(jsnInventoryItemAdjustment, '$.destination_unit_id');
        SET intItemId = JSON_VALUE(jsnInventoryItemAdjustment, '$.item_id');
        SET dblQuantity = JSON_VALUE(jsnInventoryItemAdjustment, '$.quantity');
        SET decUnitCost = JSON_VALUE(jsnInventoryItemAdjustment, '$.unit_cost');
        SET charRemarks = JSON_VALUE(jsnInventoryItemAdjustment, '$.remarks');
        SET intUserId = JSON_VALUE(jsnInventoryItemAdjustment, '$.user_id');

        SET @itemName = "";
        SET @rtuOverStu = 1;

        SET @sqlCommand =  "SELECT 
                                iic.item_description,
                                COALESCE(ii.rtu_over_stu,1)
                            INTO
                                @itemName, @rtuOverStu
                            FROM
                                inventory.inventory_items ii
                            INNER JOIN
                                inventory_udf_and_views.inventory_item_concat iic
                            ON
                                ii.item_id = iic.item_id
                            WHERE 	
                                ii.item_id = ?
                            LIMIT 1";
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING intItemId;
        DEALLOCATE PREPARE query_statement;

        -- THE FIX: Grab the exact values from the template table
        SET @reqDestSrc = 0;
        SET @isAdd = 0;
        SET @sqlCommand =  "SELECT 
                                add_to_quantity,
                                require_destination_and_source
                            INTO 
                                @isAdd, @reqDestSrc
                            FROM
                                inventory.items_adjustments_templates
                            WHERE 	
                                template_id = ?
                            LIMIT 1";
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING intTemplateId;
        DEALLOCATE PREPARE query_statement;

        -- THE FIX: Clean validation mapping to 0, 1, 2, and 3
        IF bolProceed THEN
            IF @reqDestSrc = 3 AND (!(COALESCE(intSourceUnitId,0) > 0) OR !(COALESCE(intDestinationUnitId,0) > 0)) THEN
                SET bolProceed = FALSE;
                SET @responseMessage = "Both source and destination unit are required for the chosen adjustment template!";
            ELSEIF (@reqDestSrc = 2 OR (@reqDestSrc = 0 AND @isAdd = 1)) AND !(COALESCE(intDestinationUnitId,0) > 0) THEN 
                SET bolProceed = FALSE;
                SET @responseMessage = "Destination unit is required for the chosen adjustment template!";
            ELSEIF (@reqDestSrc = 1 OR (@reqDestSrc = 0 AND @isAdd = 0)) AND !(COALESCE(intSourceUnitId,0) > 0) THEN 
                SET bolProceed = FALSE;
                SET @responseMessage = "Source unit is required for the chosen adjustment template!";
            END IF;
        END IF;
    END IF;

    -- 2. Transaction Begins
    SET autocommit = 0;
    START TRANSACTION;

    IF bolProceed THEN
        SET @intItemSourceId = 0;
        SET @dblItemSourceQuantity = 0;
        SET @bolSrcWarehouse = 0;
        SET @sqlCommand =  "SELECT 
                                COALESCE(iui.unit_item_id, 0), 
                                COALESCE(iui.ending_quantity, 0),
                                COALESCE(iu.warehouse,0)
                            INTO 
                                @intItemSourceId, @dblItemSourceQuantity, @bolSrcWarehouse
                            FROM 
                                inventory.inventory_units_items iui
                            LEFT JOIN
                                inventory.inventory_units iu 
                            ON
                                iui.unit_id = iu.unit_id 
                            WHERE 
                                iui.item_id=? AND iui.unit_id=? 
                            LIMIT 1";
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING intItemId, intSourceUnitId;
        DEALLOCATE PREPARE query_statement;

        SET @intItemDestinationId = 0;
        SET @bolDesWarehouse = 0;
        SET @sqlCommand =  "SELECT 
                                COALESCE(iui.unit_item_id, 0),
                                COALESCE(iu.warehouse,0)  
                            INTO 
                                @intItemDestinationId, @bolDesWarehouse
                            FROM 
                                inventory.inventory_units_items iui
                            LEFT JOIN
                                inventory.inventory_units iu 
                            ON
                                iui.unit_id = iu.unit_id 
                            WHERE 
                                iui.item_id=? AND iui.unit_id=? 
                            LIMIT 1";
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING intItemId, intDestinationUnitId;
        DEALLOCATE PREPARE query_statement;

        SET @destinationQuantity = CASE 
            WHEN @bolSrcWarehouse = @bolDesWarehouse THEN dblQuantity
            WHEN @bolSrcWarehouse = 0 AND @bolDesWarehouse = 1 THEN dblQuantity / CAST(@rtuOverStu AS INT)
            WHEN @bolSrcWarehouse = 1 AND @bolDesWarehouse = 0 THEN dblQuantity * CAST(@rtuOverStu AS INT)
        END;

        SET @destinationUnitCost = CASE 
            WHEN @bolSrcWarehouse = 0 AND @bolDesWarehouse = 1 THEN (decUnitCost * dblQuantity) / @destinationQuantity
            WHEN @bolSrcWarehouse = 1 AND @bolDesWarehouse = 0 THEN decUnitCost / CAST(@rtuOverStu AS INT)
            ELSE decUnitCost
        END;

        IF (@intItemSourceId IS NULL OR @intItemSourceId <= 0) AND (@intItemDestinationId IS NULL OR @intItemDestinationId <= 0) THEN 
            SET @responseMessage = "Must provide at least a Destination or Source Unit or Inventory Item.";
            SET bolProceed = FALSE;
        ELSEIF dblQuantity IS NULL OR dblQuantity <= 0 THEN 
            SET @responseMessage = "Adjustment Quantity CANNOT BE NULL OR LESS THAN OR EQUAL TO ZERO!";
            SET bolProceed = FALSE;
        ELSEIF intTemplateId IS NULL OR intTemplateId <= 0 THEN
            SET @responseMessage = "Must provide a corresponding adjustment template!";
            SET bolProceed = FALSE;
        END IF;

        IF bolProceed AND @intItemSourceId > 0 THEN 	
            IF @dblItemSourceQuantity >= dblQuantity THEN
                SET @sqlSourceCommand = "UPDATE 
                                            inventory.inventory_units_items 
                                         SET 
                                            quantity_out =  quantity_out + ?,
                                            ending_quantity = ending_quantity - ?,
                                            cost_out =  cost_out + (? * unit_cost),
                                            ending_cost =  ending_cost - (? * unit_cost)
                                         WHERE
                                            unit_item_id=? LIMIT 1";
                PREPARE sqlCommand FROM @sqlSourceCommand;
                EXECUTE sqlCommand USING dblQuantity, dblQuantity, dblQuantity, dblQuantity, @intItemSourceId;
                DEALLOCATE PREPARE sqlCommand;
            ELSE
                SET @responseMessage = "Quantity adjustment provided is GREATER THAN the available quantity balance!";
                SET bolProceed = FALSE;
            END IF;				
        END IF;

        IF bolProceed AND @intItemDestinationId > 0 THEN 
            SET @sqlSourceCommand = "UPDATE 
                                        inventory.inventory_units_items 
                                     SET 
                                        quantity_in =  quantity_in + ?,
                                        ending_quantity = ending_quantity + ?,
                                        cost_in =  cost_in + ?,
                                        ending_cost =  ending_cost + ?,
                                        unit_cost = ending_cost/ending_quantity,
                                        last_highest_in_unit_cost = if(last_highest_in_unit_cost>?,last_highest_in_unit_cost,?)
                                     WHERE
                                        unit_item_id=? LIMIT 1";
            PREPARE sqlCommand FROM @sqlSourceCommand;
            EXECUTE sqlCommand USING @destinationQuantity, @destinationQuantity, (@destinationQuantity * @destinationUnitCost), (@destinationQuantity * @destinationUnitCost), @destinationUnitCost, @destinationUnitCost, @intItemDestinationId;
            DEALLOCATE PREPARE sqlCommand;

            SET @sqlSourceCommand = "UPDATE inventory.inventory_items i
                                    JOIN (
                                        SELECT 
                                            a.item_id,
                                            (SELECT 
                                                SUM(iui.ending_cost) / SUM(IF(iu.warehouse,iui.ending_quantity*ii.rtu_over_stu,iui.ending_quantity)) 
                                             FROM 
                                                inventory.inventory_units_items iui
                                             INNER JOIN
                                                 inventory.inventory_items ii
                                             ON
                                                 iui.item_id = ii.item_id
                                             INNER JOIN
                                                 inventory.inventory_units iu
                                             ON
                                                 iui.unit_id = iu.unit_id
                                             WHERE 
                                                iui.item_id = a.item_id) AS unit_cost,
                                            (SELECT 
                                                MAX(IF(iu.warehouse,(iui.last_highest_in_unit_cost/ii.rtu_over_stu),iui.last_highest_in_unit_cost)) 
                                             FROM 
                                                inventory.inventory_units_items iui
                                             INNER JOIN
                                                 inventory.inventory_items ii
                                             ON
                                                 iui.item_id = ii.item_id
                                             INNER JOIN
                                                 inventory.inventory_units iu
                                             ON
                                                 iui.unit_id = iu.unit_id
                                             WHERE 
                                                iui.item_id =  a.item_id) AS last_highest_in_unit_cost
                                        FROM 
                                            inventory.inventory_units_items a
                                        WHERE 
                                            a.unit_item_id = ?
                                        GROUP BY 
                                            a.item_id
                                    ) u ON i.item_id = u.item_id
                                    SET 
                                        i.wtd_ave_cost = u.unit_cost,
                                        i.last_highest_in_unit_cost = if(i.last_highest_in_unit_cost > u.last_highest_in_unit_cost, i.last_highest_in_unit_cost, u.last_highest_in_unit_cost),
                                        i.selling_price = if(i.last_highest_in_unit_cost>u.last_highest_in_unit_cost, i.selling_price, u.last_highest_in_unit_cost *(1+i.markup_rate))
                                    LIMIT 1;";
            PREPARE sqlCommand FROM @sqlSourceCommand;
            EXECUTE sqlCommand USING @intItemDestinationId;
            DEALLOCATE PREPARE sqlCommand;
        END IF; 

        IF bolProceed THEN
            SET @last_id = "";
            SET @sqlSourceCommand = "INSERT 
                                        inventory.items_adjustments 
                                        (
                                            adjustment_date, 
                                            template_id, 
                                            destination_id,
                                            source_id,
                                            item_id, 
                                            quantity,
                                            unit_cost,
                                            remarks,
                                            created_by,
                                            datetime_created
                                        ) 
                                    VALUES 
                                        (
                                            NOW(), ?, ?, ?, ?, ?, ?, ?, ?, NOW()
                                        )";
            PREPARE sqlCommand FROM @sqlSourceCommand;
            EXECUTE sqlCommand USING intTemplateId, IF(@intItemDestinationId=0,NULL,@intItemDestinationId), IF(@intItemSourceId=0,NULL, @intItemSourceId), intItemId, dblQuantity, decUnitCost, charRemarks, intUserId;  
            SET @last_id = LAST_INSERT_ID(); 
            DEALLOCATE PREPARE sqlCommand;
        END IF;
    END IF;

    -- 3. Standardized Return
    IF bolProceed THEN
        SET @responseMessage = "The adjustment has been successfully applied.";
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', IF(@last_id = "", NULL, @last_id)) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;

    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postInventoryItemAdjustmentTemplate` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postInventoryItemAdjustmentTemplate`(
    IN jsnInventoryItemAdjustmentTemplate JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE processType INT;

    DECLARE charDescription VARCHAR(45);
    DECLARE intTemplateId INT;
    DECLARE bolRequireDestinationAndSource BOOLEAN;
    DECLARE bolAddToQuantity BOOLEAN;
    DECLARE intUserId INT;

    SET @template_id = 0;

    IF JSON_VALID(jsnInventoryItemAdjustmentTemplate) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET processType = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, '$.process_type');

        IF processType NOT BETWEEN 0 AND 2 THEN
            SET bolProceed = FALSE;
            SET @responseMessage = 'Please enter a valid process type!';
        END IF;

        IF bolProceed THEN
            SET charDescription = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, '$.description');
            SET bolRequireDestinationAndSource = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, '$.require_destination_and_source');
            SET bolAddToQuantity = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, '$.add_to_quantity');
            SET intUserId = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, '$.user_id');

            IF processType BETWEEN 1 AND 2 THEN
                SET intTemplateId = JSON_VALUE(jsnInventoryItemAdjustmentTemplate, '$.template_id');
            END IF;

            IF TRIM(BOTH ' ' FROM charDescription) <> '' THEN
                SET @responseMessage = '';
            ELSE
                SET bolProceed = FALSE;
                SET @responseMessage = 'Please specify the adjustment template description to continue!';
            END IF;

            IF processType = 0 THEN
                SET @whereConditions = ' LCASE(description) = LCASE(?);';
                SET @param = charDescription;
            ELSE
                SET @whereConditions = ' template_id = ?;';
                SET @param = intTemplateId;
            END IF;

            IF bolProceed THEN
                SET @rowCount = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.items_adjustments_templates WHERE <conditions/>';
                SET @sqlCommand = REPLACE(@sqlCommand, '<conditions/>', @whereConditions);
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING @param;
                DEALLOCATE PREPARE query_statement;

                IF processType = 0 THEN
                    IF @rowCount = 1 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Adjustment template already exists. Please choose a different name!';
                    END IF;
                ELSE
                    IF @rowCount = 0 THEN
                        SET bolProceed = FALSE;
                        IF processType = 1 THEN
                            SET @responseMessage = 'Can not modify non-existent entry!';
                        ELSEIF processType = 2 THEN
                            SET @responseMessage = 'Can not delete non-existent entry!';
                        END IF;
                    END IF;
                END IF;

                IF processType = 1 AND bolProceed THEN
                    SET @rowCount = 0;
                    SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.items_adjustments_templates WHERE LCASE(description) = LCASE(?) AND template_id NOT IN (?);';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING charDescription, intTemplateId;
                    DEALLOCATE PREPARE query_statement;

                    IF @rowCount = 1 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Adjustment template already exists. Please choose a different name!';
                    END IF;
                END IF;
            END IF;

            SET autocommit = 0;
            START TRANSACTION;

            IF bolProceed AND processType = 0 THEN
                SET @sqlCommand = 'INSERT INTO inventory.items_adjustments_templates (description, add_to_quantity, require_destination_and_source, created_by) VALUES (?,?,?,?);';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING charDescription, bolAddToQuantity, bolRequireDestinationAndSource, intUserId;
                SET @template_id = LAST_INSERT_ID();
                DEALLOCATE PREPARE query_statement;

                IF @template_id = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Failed to save adjustment template entry!';
                END IF;
            END IF;

            IF bolProceed AND processType = 1 THEN
                SET @rows_affected = 0;
                SET @sqlCommand = 'UPDATE inventory.items_adjustments_templates SET description = ?, add_to_quantity = ?, require_destination_and_source = ?, modified_by = ?, datetime_modified = NOW() WHERE template_id = ?;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING charDescription, bolAddToQuantity, bolRequireDestinationAndSource, intUserId, intTemplateId;
                SELECT ROW_COUNT() INTO @rows_affected;
                DEALLOCATE PREPARE query_statement;

                IF @rows_affected = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Failed to update adjustment template entry!';
                ELSE
                    SET @template_id = intTemplateId;
                END IF;
            END IF;

            IF bolProceed AND processType = 2 THEN
                SET @rowCount = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.items_adjustments WHERE template_id = ?;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intTemplateId;
                DEALLOCATE PREPARE query_statement;

                IF @rowCount > 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Deletion of adjustment template entry not possible due to existing dependent item adjustment!';
                END IF;

                IF bolProceed THEN
                    SET @rows_affected = 0;
                    SET @sqlCommand = 'DELETE FROM inventory.items_adjustments_templates WHERE template_id = ?;';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intTemplateId;
                    SELECT ROW_COUNT() INTO @rows_affected;
                    DEALLOCATE PREPARE query_statement;

                    IF @rows_affected = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Failed to delete adjustment template entry!';
                    ELSE
                        SET @template_id = intTemplateId;
                    END IF;
                END IF;
            END IF;

        END IF;
    END IF;

    IF bolProceed THEN
        IF processType = 0 THEN
            SET @responseMessage = 'Adjustment Template Successfully Saved!';
        ELSEIF processType = 1 THEN
            SET @responseMessage = 'Adjustment Template Successfully Updated!';
        ELSEIF processType = 2 THEN
            SET @responseMessage = 'Adjustment Template Successfully Deleted!';
        END IF;
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', @template_id) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;

    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postInventoryItemCategory` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postInventoryItemCategory`(
    IN jsnInventoryItemCategory JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE processType INT;

    DECLARE charDescription VARCHAR(45);
    DECLARE intGlSlId INT;
    DECLARE intItemCategoryId INT;
    DECLARE intUserId INT;

    SET @item_category_id = 0;

    IF JSON_VALID(jsnInventoryItemCategory) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET processType = JSON_VALUE(jsnInventoryItemCategory, '$.process_type');

        IF processType NOT BETWEEN 0 AND 2 THEN
            SET bolProceed = FALSE;
            SET @responseMessage = 'Please enter a valid process type!';
        END IF;

        IF bolProceed THEN
            SET charDescription = COALESCE(JSON_VALUE(jsnInventoryItemCategory, '$.description'), '');
            SET intGlSlId = COALESCE(JSON_VALUE(jsnInventoryItemCategory, '$.glsl_id'), 0);
            SET intUserId = COALESCE(JSON_VALUE(jsnInventoryItemCategory, '$.user_id'), 0);

            IF processType BETWEEN 1 AND 2 THEN
                SET intItemCategoryId = COALESCE(JSON_VALUE(jsnInventoryItemCategory, '$.item_category_id'), 0);
            END IF;

            IF TRIM(BOTH ' ' FROM charDescription) <> '' THEN
                SET @responseMessage = '';
            ELSE
                SET bolProceed = FALSE;
                SET @responseMessage = 'Please specify the item category description to continue!';
            END IF;

            IF processType = 0 THEN
                SET @whereConditions = ' LCASE(description) = LCASE(?);';
                SET @param = charDescription;
            ELSE
                SET @whereConditions = ' item_category_id = ?;';
                SET @param = intItemCategoryId;
            END IF;

            IF bolProceed THEN
                SET @rowCount = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.items_categories WHERE <conditions/>';
                SET @sqlCommand = REPLACE(@sqlCommand, '<conditions/>', @whereConditions);
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING @param;
                DEALLOCATE PREPARE query_statement;

                IF processType = 0 THEN
                    IF @rowCount = 1 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Item category already exists. Please choose a different name!';
                    END IF;
                ELSE
                    IF @rowCount = 0 THEN
                        SET bolProceed = FALSE;
                        IF processType = 1 THEN
                            SET @responseMessage = 'Can not modify non-existent entry!';
                        ELSEIF processType = 2 THEN
                            SET @responseMessage = 'Can not delete non-existent entry!';
                        END IF;
                    END IF;
                END IF;

                IF processType = 1 AND bolProceed THEN
                    SET @rowCount = 0;
                    SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.items_categories WHERE LCASE(description) = LCASE(?) AND item_category_id NOT IN (?);';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING charDescription, intItemCategoryId;
                    DEALLOCATE PREPARE query_statement;

                    IF @rowCount = 1 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Item category already exists. Please choose a different name!';
                    END IF;
                END IF;
            END IF;

            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM application_users_inventory.application_users WHERE user_id = ? LIMIT 1';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intUserId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'You have entered non-existing user!';
                END IF;
            END IF;

            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM application_users_inventory.application_users WHERE user_id = ? AND !ISNULL(unit_id) LIMIT 1';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intUserId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Can not continue. Your user does not belong to any unit!';
                END IF;
            END IF;

            SET autocommit = 0;
            START TRANSACTION;

            IF bolProceed AND processType = 0 THEN
                SET @sqlCommand = 'INSERT INTO inventory.items_categories (description, created_by) VALUES (?,?);';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING charDescription, intUserId;
                SET @item_category_id = LAST_INSERT_ID();
                DEALLOCATE PREPARE query_statement;

                IF @item_category_id = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Failed to save item category entry!';
                END IF;
            END IF;

            IF bolProceed AND processType = 1 THEN
                SET @rows_affected = 0;
                SET @sqlCommand = 'UPDATE inventory.items_categories SET description = ?, modified_by = ?, datetime_modified = NOW() WHERE item_category_id = ?;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING charDescription, intUserId, intItemCategoryId;
                SELECT ROW_COUNT() INTO @rows_affected;
                DEALLOCATE PREPARE query_statement;

                IF @rows_affected = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Failed to update item category entry!';
                ELSE
                    SET @item_category_id = intItemCategoryId;
                END IF;
            END IF;

            IF bolProceed AND processType > 0 THEN
                SET @sqlCommand = 'DELETE FROM inventory.item_category_glsl_item WHERE item_category_id = ?';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intItemCategoryId;
                DEALLOCATE PREPARE query_statement;
            END IF;

            IF bolProceed AND processType < 2 THEN
                SET @rows_affected = 0;
                SET @sqlCommand = 'INSERT INTO inventory.item_category_glsl_item (item_category_id, glsl_item) VALUES (?,?);';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING @item_category_id, intGlSlId;
                SELECT ROW_COUNT() INTO @rows_affected;
                DEALLOCATE PREPARE query_statement;

                IF @rows_affected = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Failed to link GLSL account to item category!';
                END IF;
            END IF;

            IF bolProceed AND processType = 2 THEN
                SET @rowCount = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.inventory_items WHERE item_category_id = ?;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intItemCategoryId;
                DEALLOCATE PREPARE query_statement;

                IF @rowCount > 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Deletion of item category entry not possible due to existing dependent inventory items!';
                END IF;

                IF bolProceed THEN
                    SET @rows_affected = 0;
                    SET @sqlCommand = 'DELETE FROM inventory.items_categories WHERE item_category_id = ?;';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intItemCategoryId;
                    SELECT ROW_COUNT() INTO @rows_affected;
                    DEALLOCATE PREPARE query_statement;

                    IF @rows_affected = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Failed to delete item category entry!';
                    ELSE
                        SET @item_category_id = intItemCategoryId;
                    END IF;
                END IF;
            END IF;

        END IF;
    END IF;

    IF bolProceed THEN
        IF processType = 0 THEN
            SET @responseMessage = 'Item Category Successfully Saved!';
        ELSEIF processType = 1 THEN
            SET @responseMessage = 'Item Category Successfully Updated!';
        ELSEIF processType = 2 THEN
            SET @responseMessage = 'Item Category Successfully Deleted!';
        END IF;
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', @item_category_id) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;

    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postInventoryUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postInventoryUnit`(
    IN jsnInventoryUnit JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;

    DECLARE intUnitId INT;
    DECLARE bolWarehouse BOOLEAN;
    DECLARE bolEmployee BOOLEAN;
    DECLARE intPersonInCharge INT;
    DECLARE charPersonName VARCHAR(100);

    IF JSON_VALID(jsnInventoryUnit) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET intUnitId = JSON_VALUE(jsnInventoryUnit, '$.unit_id');
        SET bolWarehouse = JSON_VALUE(jsnInventoryUnit, '$.bol_warehouse');
        SET bolEmployee = JSON_VALUE(jsnInventoryUnit, '$.bol_employee');

        IF bolEmployee THEN
            SET intPersonInCharge = JSON_VALUE(jsnInventoryUnit, '$.person_in_charge');

            SET @rowCount = 0;
            SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM employees_profile.employees WHERE employee_id = ?;';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING intPersonInCharge;
            DEALLOCATE PREPARE query_statement;

            IF @rowCount = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'You have entered a non-existing employee!';
            END IF;
        ELSE
            SET charPersonName = JSON_VALUE(jsnInventoryUnit, '$.person_name');

            IF !(TRIM(BOTH ' ' FROM charPersonName) <> '') THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'Please specify person name to continue!';
            END IF;
        END IF;

        IF bolProceed THEN
            SET @rows_affected = 0;
            SET @sqlCommand = 'UPDATE inventory.inventory_units SET warehouse = ?, person_in_charge = ?, person_name = ? WHERE unit_id = ?;';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING bolWarehouse, intPersonInCharge, charPersonName, intUnitId;
            SELECT ROW_COUNT() INTO @rows_affected;
            DEALLOCATE PREPARE query_statement;

            IF @rows_affected = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'Failed to update inventory unit entry!';
            END IF;
        END IF;
    END IF;

    IF bolProceed THEN
        SET @responseMessage = 'Inventory Unit Successfully Updated!';
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', intUnitId) AS response;
    ELSE
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postInventoryUnitBin` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postInventoryUnitBin`(
    IN jsnInventoryUnitBin JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE processType INT;

    DECLARE charDescription VARCHAR(45);
    DECLARE intUnitId INT;
    DECLARE intBinId INT;
    DECLARE intUserId INT;

    -- Sample JSON representation for reference:
    -- '{
    --     "process_type":0, (0 = Save, 1 = Update, 2 = Delete)
    --     "unit_id":1, 
    --     "description":"People",
    --     "bin_id":10,
    --     "user_id":10
    -- }'

    SET @bin_id = 0;

    IF JSON_VALID(jsnInventoryUnitBin) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET processType = JSON_VALUE(jsnInventoryUnitBin, '$.process_type');
    
        IF processType NOT BETWEEN 0 AND 2 THEN 
            SET bolProceed = FALSE;
            SET @responseMessage = 'Please enter a valid process type!';
        END IF;
    
        IF bolProceed THEN
        
            SET intUnitId = JSON_VALUE(jsnInventoryUnitBin, '$.unit_id');
            SET charDescription = JSON_VALUE(jsnInventoryUnitBin, '$.description');
            SET intUserId = JSON_VALUE(jsnInventoryUnitBin, '$.user_id');
        
            IF processType BETWEEN 1 AND 2 THEN
                SET intBinId = JSON_VALUE(jsnInventoryUnitBin, '$.bin_id');
            END IF;
        
            IF TRIM(BOTH ' ' FROM charDescription) <> '' THEN
                SET @responseMessage = '';
            ELSE
                SET bolProceed = FALSE;
                SET @responseMessage = 'Please specify the item bin description to continue!';
            END IF;
        
            IF processType = 0 THEN
                SET @whereConditions = CONCAT(' unit_id = ', intUnitId, ' AND LCASE(description) = LCASE(?);');
                SET @param = charDescription;
            ELSE
                SET @whereConditions = CONCAT(' unit_id = ', intUnitId, ' AND bin_id = ?;');
                SET @param = intBinId;
            END IF;
        
            IF bolProceed THEN
                SET @rowCount = 0;
                
                -- Simplified string concatenation without REPLACE()
                SET @sqlCommand = CONCAT('SELECT COUNT(*) INTO @rowCount FROM inventory.unit_bins WHERE', @whereConditions);
                
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING @param;
                DEALLOCATE PREPARE query_statement;
            
                IF processType = 0 THEN
                    IF @rowCount = 1 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Bin already exists. Please choose a different name!';
                    END IF;
                ELSE
                    IF @rowCount = 0 THEN
                        SET bolProceed = FALSE;
                        IF processType = 1 THEN
                            SET @responseMessage = 'Can not modify non-existent entry!';
                        ELSEIF processType = 2 THEN
                            SET @responseMessage = 'Can not delete non-existent entry!';
                        END IF;
                    END IF;
                END IF;
            
                IF processType = 1 AND bolProceed THEN
                    SET @rowCount = 0;
                    SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.unit_bins WHERE LCASE(description) = LCASE(?) AND unit_id = ? AND bin_id NOT IN (?);';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING charDescription, intUnitId, intBinId;
                    DEALLOCATE PREPARE query_statement;
                
                    IF @rowCount = 1 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Bin already exists. Please choose a different name!';
                    END IF;
                END IF;
            END IF;
        
            SET autocommit = 0;
            START TRANSACTION;
        
            IF bolProceed AND processType = 0 THEN
                SET @sqlCommand = 'INSERT INTO inventory.unit_bins (unit_id, description, created_by) VALUES (?,?,?);';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intUnitId, charDescription, intUserId;
                SET @bin_id = LAST_INSERT_ID(); 
                DEALLOCATE PREPARE query_statement;
            
                IF @bin_id = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Failed to save item bin entry!';
                END IF;
            END IF;
        
            IF bolProceed AND processType = 1 THEN
                SET @rows_affected = 0;
                SET @sqlCommand = 'UPDATE inventory.unit_bins SET unit_id = ?, description = ?, modified_by = ?, datetime_modified = NOW() WHERE bin_id = ?;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intUnitId, charDescription, intUserId, intBinId;
                SELECT ROW_COUNT() INTO @rows_affected;
                DEALLOCATE PREPARE query_statement;
            
                IF @rows_affected = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Failed to update item bin entry!';
                ELSE
                    SET @bin_id = intBinId;
                END IF;
            END IF;
        
            IF bolProceed AND processType = 2 THEN
                SET @rowCount = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.inventory_units_items WHERE bin_id = ?;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intBinId;
                DEALLOCATE PREPARE query_statement;
            
                IF @rowCount > 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'Deletion of bin entry not possible due to existing dependent inventory items!';
                END IF;
            
                IF bolProceed THEN
                    SET @rows_affected = 0;
                    SET @sqlCommand = 'DELETE FROM inventory.unit_bins WHERE bin_id = ?;';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intBinId;
                    SELECT ROW_COUNT() INTO @rows_affected;
                    DEALLOCATE PREPARE query_statement;
                
                    IF @rows_affected = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'Failed to delete item bin entry!';
                    ELSE
                        SET @bin_id = intBinId;
                    END IF;
                END IF;
            END IF;
        END IF;
    END IF;

    -- Standardized Return Format via JSON_OBJECT
    IF bolProceed THEN
        IF processType = 0 THEN
            SET @responseMessage = 'Item Bin Successfully Saved!';
        ELSEIF processType = 1 THEN
            SET @responseMessage = 'Item Bin Successfully Updated!';
        ELSEIF processType = 2 THEN
            SET @responseMessage = 'Item Bin Successfully Deleted!';
        END IF;
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', @bin_id) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;
   
    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postInventoryUnitItem` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postInventoryUnitItem`(
    IN jsnInventoryUnitItem JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE processType INT;
    DECLARE intUnitItemId INT;
    DECLARE intItemId INT;
    DECLARE intUnitId INT;
    DECLARE dteStartingPeriod DATETIME;
    DECLARE dblStartingQuantity DOUBLE(9,2);
    DECLARE dblQuantityIn DOUBLE(9,2);
    DECLARE dblQuantityOut DOUBLE(9,2);
    DECLARE dblEndingQuantity DOUBLE(9,2);
    DECLARE dblStartingCost DOUBLE(12,2);
    DECLARE dblCostIn DOUBLE(12,2);
    DECLARE dblCostOut DOUBLE(12,2);
    DECLARE dblEndingCost DOUBLE(12,2);
    DECLARE dblUnitCost DOUBLE(9,2);
    DECLARE dblLastHighestInUnitCost DOUBLE(12,2);
    DECLARE intBinId INT;
    DECLARE intUserId INT;

    SET @unit_item_id = 0;

    IF JSON_VALID(jsnInventoryUnitItem) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET processType = JSON_VALUE(jsnInventoryUnitItem, '$.process_type');
        IF processType NOT BETWEEN 0 AND 2 THEN
            SET bolProceed = FALSE;
            SET @responseMessage = 'Please enter a valid process type!';
        END IF;
    END IF;

    IF bolProceed THEN
        SET intItemId = JSON_VALUE(jsnInventoryUnitItem, '$.item_id');
        SET intUnitId = JSON_VALUE(jsnInventoryUnitItem, '$.unit_id');
        SET dteStartingPeriod = JSON_VALUE(jsnInventoryUnitItem, '$.starting_period');
        SET dblStartingQuantity = JSON_VALUE(jsnInventoryUnitItem, '$.starting_quantity');
        SET dblQuantityIn = JSON_VALUE(jsnInventoryUnitItem, '$.quantity_in');
        SET dblQuantityOut = JSON_VALUE(jsnInventoryUnitItem, '$.quantity_out');
        SET dblUnitCost = JSON_VALUE(jsnInventoryUnitItem, '$.unit_cost');
        SET dblEndingQuantity = dblStartingQuantity + dblQuantityIn - dblQuantityOut;
        SET dblStartingCost = dblUnitCost * dblStartingQuantity;
        SET dblCostIn = dblUnitCost * dblQuantityIn;
        SET dblCostOut = dblUnitCost * dblQuantityOut;
        SET dblEndingCost = dblUnitCost * dblEndingQuantity;
        SET dblLastHighestInUnitCost = IFNULL(JSON_VALUE(jsnInventoryUnitItem, '$.last_highest_in_unit_cost'), 0);
        SET intBinId = JSON_VALUE(jsnInventoryUnitItem, '$.bin_id');
        SET intUserId = JSON_VALUE(jsnInventoryUnitItem, '$.user_id');

        SET @empty_item_id = 0;
        SELECT iec.empty_item_id INTO @empty_item_id
        FROM inventory.inventory_items ii
        LEFT JOIN inventory.inventory_empty_cases iec ON iec.main_item_id = ii.item_id
        WHERE ii.item_id = intItemId
        LIMIT 1;

        IF processType BETWEEN 1 AND 2 THEN
            SET intUnitItemId = JSON_VALUE(jsnInventoryUnitItem, '$.unit_item_id');
        END IF;
    END IF;

    IF bolProceed AND processType <> 0 THEN
        SET @rowCount = 0;
        SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM inventory.inventory_units_items WHERE unit_item_id = ?;';
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING intUnitItemId;
        DEALLOCATE PREPARE query_statement;
        
        IF @rowCount = 0 THEN
            SET bolProceed = FALSE;
            IF processType = 1 THEN
                SET @responseMessage = 'Cannot modify non-existent entry!';
            ELSEIF processType = 2 THEN
                SET @responseMessage = 'Cannot delete non-existent entry!';
            END IF;
        END IF;
    END IF;

    SET autocommit = 0;
    START TRANSACTION;

    IF bolProceed AND processType = 0 THEN
        SET @sqlCommand = 'INSERT INTO inventory.inventory_units_items
        (
            item_id,
            unit_id,
            starting_period,
            last_entry,
            starting_quantity,
            quantity_in,
            quantity_out,
            ending_quantity,
            starting_cost,
            cost_in,
            cost_out,
            ending_cost,
            unit_cost,
            last_highest_in_unit_cost,
            bin_id,
            created_by
        )
        VALUES
        (
            ?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
        );';
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING intItemId, intUnitId, dteStartingPeriod, dblStartingQuantity,
            dblQuantityIn, dblQuantityOut, dblEndingQuantity, dblStartingCost, dblCostIn, dblCostOut,
            dblEndingCost, dblUnitCost, dblLastHighestInUnitCost, intBinId, intUserId;
        SET @unit_item_id = LAST_INSERT_ID();
        DEALLOCATE PREPARE query_statement;
        
        IF @unit_item_id = 0 THEN
            SET bolProceed = FALSE;
            SET @responseMessage = 'Failed to save inventory unit item entry!';
        END IF;

        /* MEdy villarias ako nag add ani -- arthur leywin */
        IF @empty_item_id IS NOT NULL AND @empty_item_id > 0 THEN
            SET @sqlCommand = 'INSERT INTO inventory.inventory_units_items
            (
                item_id,
                unit_id,
                starting_period,
                last_entry,
                starting_quantity,
                quantity_in,
                quantity_out,
                ending_quantity,
                starting_cost,
                cost_in,
                cost_out,
                ending_cost,
                unit_cost,
                last_highest_in_unit_cost,
                bin_id,
                created_by
            )
            VALUES
            (
                ?, ?, ?, NOW(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?
            );';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING @empty_item_id, intUnitId, dteStartingPeriod, dblStartingQuantity,
                dblQuantityIn, dblQuantityOut, dblEndingQuantity, dblStartingCost, dblCostIn, dblCostOut,
                dblEndingCost, 0.00, 0.00, intBinId, intUserId;
            SET @unit_item_id = LAST_INSERT_ID();
            DEALLOCATE PREPARE query_statement;
        END IF;
    END IF;

    IF bolProceed AND processType = 1 THEN
        SET @empty_item_id = 0;
        SELECT iui2.unit_item_id INTO @empty_item_id
        FROM inventory.inventory_units_items iui
        LEFT JOIN inventory.inventory_empty_cases iec ON iec.main_item_id = iui.item_id
        LEFT JOIN inventory.inventory_units_items iui2 ON iui2.item_id = iec.empty_item_id
        WHERE iui.unit_item_id = intUnitItemId
        LIMIT 1;

        SET @rows_affected = 0;
        SET @sqlCommand = 'UPDATE inventory.inventory_units_items
        SET
            starting_period = ?,
            last_entry = NOW(),
            starting_quantity = ?,
            quantity_in = ?,
            quantity_out = ?,
            ending_quantity = ?,
            starting_cost = ?,
            cost_in = ?,
            cost_out = ?,
            ending_cost = ?,
            unit_cost = ?,
            last_highest_in_unit_cost = IF(? > last_highest_in_unit_cost, ?, last_highest_in_unit_cost),
            bin_id = ?,
            modified_by = ?,
            datetime_modified = NOW()
        WHERE unit_item_id = ?;';
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING dteStartingPeriod, dblStartingQuantity, dblQuantityIn, dblQuantityOut,
            dblEndingQuantity, dblStartingCost, dblCostIn, dblCostOut, dblEndingCost, dblUnitCost,
            dblUnitCost, dblUnitCost, intBinId, intUserId, intUnitItemId;
        SELECT ROW_COUNT() INTO @rows_affected;
        DEALLOCATE PREPARE query_statement;
        
        IF @rows_affected = 0 THEN
            SET bolProceed = FALSE;
            SET @responseMessage = 'Failed to update inventory unit item entry!';
        ELSE
            SET @unit_item_id = intUnitItemId;
        END IF;

--         /* MEdy villarias ako nag add ani -- arthur leywin */
--         IF @empty_item_id IS NOT NULL AND @empty_item_id > 0 THEN
--             SET @sqlCommand = 'UPDATE inventory.inventory_units_items
--             SET
--                 starting_period = ?,
--                 last_entry = NOW(),
--                 starting_quantity = ?,
--                 quantity_in = ?,
--                 quantity_out = ?,
--                 ending_quantity = ?,
--                 starting_cost = ?,
--                 cost_in = ?,
--                 cost_out = ?,
--                 ending_cost = ?,
--                 unit_cost = 0.00,
--                 last_highest_in_unit_cost = 0.00,
--                 bin_id = ?,
--                 modified_by = ?,
--                 datetime_modified = NOW()
--             WHERE unit_item_id = ?;';
--             PREPARE query_statement FROM @sqlCommand;
--             EXECUTE query_statement USING dteStartingPeriod, dblStartingQuantity, dblQuantityIn, dblQuantityOut,
--                 dblEndingQuantity, dblStartingCost, dblCostIn, dblCostOut, dblEndingCost,
--                 intBinId, intUserId, @empty_item_id;
--             SELECT ROW_COUNT() INTO @rows_affected;
--             DEALLOCATE PREPARE query_statement;
--         END IF;
    END IF;

    IF bolProceed AND processType < 2 THEN
        SET @rows_affected = 0;
        SET @empty_item_id = 0;
        SELECT iui2.unit_item_id INTO @empty_item_id
        FROM inventory.inventory_units_items iui
        LEFT JOIN inventory.inventory_empty_cases iec ON iec.main_item_id = iui.item_id
        LEFT JOIN inventory.inventory_units_items iui2 ON iui2.item_id = iec.empty_item_id
        WHERE iui.unit_item_id = @unit_item_id
        LIMIT 1;

        SET @sqlCommand = 'UPDATE inventory.inventory_items i
            JOIN (
                SELECT
                    a.item_id,
                    (SELECT
                        IFNULL(SUM(iui.ending_cost) / NULLIF(SUM(IF(iu.warehouse, iui.ending_quantity * ii.rtu_over_stu, iui.ending_quantity)), 0), 0)
                     FROM inventory.inventory_units_items iui
                     INNER JOIN inventory.inventory_items ii ON iui.item_id = ii.item_id
                     INNER JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id
                     WHERE iui.item_id = a.item_id
                    ) AS unit_cost,
                    (SELECT
                        MAX(IF(iu.warehouse, (iui.last_highest_in_unit_cost / ii.rtu_over_stu), iui.last_highest_in_unit_cost))
                     FROM inventory.inventory_units_items iui
                     INNER JOIN inventory.inventory_items ii ON iui.item_id = ii.item_id
                     INNER JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id
                     WHERE iui.item_id = a.item_id
                    ) AS last_highest_in_unit_cost
                FROM inventory.inventory_units_items a
                WHERE a.unit_item_id = ?
                GROUP BY a.item_id
            ) u ON i.item_id = u.item_id
            SET
                i.wtd_ave_cost = IFNULL(u.unit_cost, 0),
                i.last_highest_in_unit_cost = IF(i.last_highest_in_unit_cost > IFNULL(u.last_highest_in_unit_cost, 0), i.last_highest_in_unit_cost, IFNULL(u.last_highest_in_unit_cost, 0))
            LIMIT 1;';
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING @unit_item_id;
        SELECT ROW_COUNT() INTO @rows_affected;
        DEALLOCATE PREPARE query_statement;

        /* MEdy villarias ako nag add ani -- arthur leywin */
          -- this is the original selling price      i.selling_price = IF(i.last_highest_in_unit_cost > IFNULL(u.last_highest_in_unit_cost, 0), i.selling_price, IFNULL(u.last_highest_in_unit_cost, 0) * (1 + i.markup_rate))
--         IF @empty_item_id IS NOT NULL AND @empty_item_id > 0 THEN
--             -- For empty case, only update wtd_ave_cost (skip last_highest_in_unit_cost and selling_price)
--             SET @sqlCommand = 'UPDATE inventory.inventory_items i
--                 JOIN (
--                     SELECT
--                         a.item_id,
--                         (SELECT
--                             IFNULL(SUM(iui.ending_cost) / NULLIF(SUM(IF(iu.warehouse, iui.ending_quantity * ii.rtu_over_stu, iui.ending_quantity)), 0), 0)
--                          FROM inventory.inventory_units_items iui
--                          INNER JOIN inventory.inventory_items ii ON iui.item_id = ii.item_id
--                          INNER JOIN inventory.inventory_units iu ON iui.unit_id = iu.unit_id
--                          WHERE iui.item_id = a.item_id
--                         ) AS unit_cost
--                     FROM inventory.inventory_units_items a
--                     WHERE a.unit_item_id = ?
--                     GROUP BY a.item_id
--                 ) u ON i.item_id = u.item_id
--                 SET
--                     i.wtd_ave_cost = IFNULL(u.unit_cost, 0)
--                 LIMIT 1;';
--             PREPARE query_statement FROM @sqlCommand;
--             EXECUTE query_statement USING @empty_item_id;
--             SELECT ROW_COUNT() INTO @rows_affected;
--             DEALLOCATE PREPARE query_statement;
--         END IF;
    END IF;

    IF bolProceed AND processType = 2 THEN
        SET @rowCount = 0;
        SET @sqlCommand = 'SELECT COUNT(*) INTO @rowCount FROM udf_and_views_inventory.unit_item_checking WHERE unit_item_id = ?;';
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement USING intUnitItemId;
        DEALLOCATE PREPARE query_statement;
        
        IF @rowCount > 0 THEN
            SET bolProceed = FALSE;
            SET @responseMessage = 'Deletion of unit item entry not possible due to existing dependent entries!';
        END IF;

        IF bolProceed THEN
            SET @rows_affected = 0;
            SET @sqlCommand = 'DELETE FROM inventory.inventory_units_items WHERE unit_item_id = ?;';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING intUnitItemId;
            SELECT ROW_COUNT() INTO @rows_affected;
            DEALLOCATE PREPARE query_statement;
            
            IF @rows_affected = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'Failed to delete inventory unit item entry!';
            ELSE
                SET @unit_item_id = intUnitItemId;
            END IF;
        END IF;
    END IF;

    IF bolProceed THEN
        IF processType = 0 THEN
            SET @responseMessage = 'Inventory Unit Item Successfully Saved!';
        ELSEIF processType = 1 THEN
            SET @responseMessage = 'Inventory Unit Item Successfully Updated!';
        ELSEIF processType = 2 THEN
            SET @responseMessage = 'Inventory Unit Item Successfully Deleted!';
        END IF;
        
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', @unit_item_id) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;

    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postItemImports` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postItemImports`(
    IN jsnItemImports JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE processType INT;

    -- Removed explicit COLLATE to allow inheritance of the database's default collation
    DECLARE charDescription VARCHAR(45);
    DECLARE charImportType VARCHAR(20);
    DECLARE intId INT;
    DECLARE intUserId INT;

    DECLARE charImportId VARCHAR(40);
    DECLARE charImportName VARCHAR(40);
    DECLARE charImportTable VARCHAR(40);

    SET @id = 0;

    IF JSON_VALID(jsnItemImports) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET processType = JSON_VALUE(jsnItemImports, '$.process_type');
        SET charImportType = JSON_VALUE(jsnItemImports, '$.import_type');

        IF processType NOT BETWEEN 0 AND 2 THEN
            SET bolProceed = FALSE;
            SET @responseMessage = 'Please enter a valid process type!';
        END IF;

        IF charImportType = 'brand' THEN
            SET charImportId = 'brand_id'; SET charImportName = 'Brand'; SET charImportTable = 'brands';
        ELSEIF charImportType = 'ratio' THEN
            SET charImportId = 'ratio_id'; SET charImportName = 'Ply Rating'; SET charImportTable = 'ratios';
        ELSEIF charImportType = 'size' THEN
            SET charImportId = 'size_id'; SET charImportName = 'Size'; SET charImportTable = 'sizes';
        ELSEIF charImportType = 'threadPattern' THEN
            SET charImportId = 'pattern_id'; SET charImportName = 'Thread Pattern'; SET charImportTable = 'thread_patterns';
        ELSEIF charImportType = 'valveType' THEN
            SET charImportId = 'valve_id'; SET charImportName = 'Valve Type'; SET charImportTable = 'valve_types';
        ELSEIF charImportType = 'vehiclePart' THEN
            SET charImportId = 'part_id'; SET charImportName = 'Vehicle Part'; SET charImportTable = 'vehicle_parts';
        ELSEIF charImportType = 'vehiclePartNumber' THEN
            SET charImportId = 'part_number_id'; SET charImportName = 'Vehicle Part Number'; SET charImportTable = 'vehicle_part_numbers';
        ELSE
            SET bolProceed = FALSE;
            SET @responseMessage = 'Invalid import type!';
        END IF;

        IF bolProceed THEN
            SET charDescription = JSON_VALUE(jsnItemImports, '$.description');
            SET intUserId = JSON_VALUE(jsnItemImports, '$.user_id');

            IF processType BETWEEN 1 AND 2 THEN
                SET intId = JSON_VALUE(jsnItemImports, '$.id');
            END IF;

            IF TRIM(BOTH ' ' FROM charDescription) <> '' THEN
                SET @responseMessage = '';
            ELSE
                SET bolProceed = FALSE;
                SET @responseMessage = CONCAT('Please specify the ', LOWER(charImportName), ' description to continue!');
            END IF;

            IF processType = 0 THEN
                SET @whereConditions = 'LCASE(description) = LCASE(?);';
                SET @param = charDescription;
            ELSE
                SET @whereConditions = CONCAT(charImportId, ' = ?;');
                SET @param = intId;
            END IF;

            IF bolProceed THEN
                SET @rowCount = 0;
                
                -- Simplified string concatenation. 
                -- We build the string dynamically without needing the REPLACE() function.
                SET @sqlCommand = CONCAT('SELECT COUNT(*) INTO @rowCount FROM inventory.', charImportTable, ' WHERE ', @whereConditions);
                
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING @param;
                DEALLOCATE PREPARE query_statement;

                IF processType = 0 THEN
                    IF @rowCount = 1 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = 'The entry already exists. Please choose a different name.';
                    END IF;
                ELSE
                    IF @rowCount = 0 THEN
                        SET bolProceed = FALSE;
                        IF processType = 1 THEN
                            SET @responseMessage = 'Can not modify non-existent entry!';
                        ELSEIF processType = 2 THEN
                            SET @responseMessage = 'Can not delete non-existent entry!';
                        END IF;
                    END IF;
                END IF;

                IF processType = 1 AND bolProceed THEN
                    SET @rowCount = 0;
                    SET @sqlCommand = CONCAT('SELECT COUNT(*) INTO @rowCount FROM inventory.', charImportTable, ' WHERE LCASE(description) = LCASE(?) AND ', charImportId, ' NOT IN (?);');
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING charDescription, intId;
                    DEALLOCATE PREPARE query_statement;

                    IF @rowCount = 1 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = CONCAT(CONCAT(UPPER(SUBSTRING(LOWER(charImportName), 1, 1)), LOWER(SUBSTRING(LOWER(charImportName), 2))), ' already exists. Please choose a different name!');
                    END IF;
                END IF;
            END IF;

            SET autocommit = 0;
            START TRANSACTION;

            IF bolProceed AND processType = 0 THEN
                SET @sqlCommand = CONCAT('INSERT INTO inventory.', charImportTable, ' (description, created_by) VALUES (?,?);');
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING charDescription, intUserId;
                SET @id = LAST_INSERT_ID();
                DEALLOCATE PREPARE query_statement;

                IF @id = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT('Failed to save ', LOWER(charImportName), ' entry!');
                END IF;
            END IF;

            IF bolProceed AND processType = 1 THEN
                SET @rows_affected = 0;
                SET @sqlCommand = CONCAT('UPDATE inventory.', charImportTable, ' SET description = ?, modified_by = ?, datetime_modified = NOW() WHERE ', charImportId, ' = ?;');
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING charDescription, intUserId, intId;
                SELECT ROW_COUNT() INTO @rows_affected;
                DEALLOCATE PREPARE query_statement;

                IF @rows_affected = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT('Failed to update ', LOWER(charImportName), ' entry!');
                ELSE
                    SET @id = intId;
                END IF;
            END IF;

            IF bolProceed AND processType = 2 THEN
                SET @rowCount = 0;
                SET @sqlCommand = CONCAT('SELECT COUNT(*) INTO @rowCount FROM inventory.inventory_items WHERE ', charImportId, ' = ?;');
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intId;
                DEALLOCATE PREPARE query_statement;

                IF @rowCount > 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT('Deletion of ', LOWER(charImportName), ' entry not possible due to existing dependent inventory items!');
                END IF;

                IF bolProceed THEN
                    SET @rows_affected = 0;
                    SET @sqlCommand = CONCAT('DELETE FROM inventory.', charImportTable, ' WHERE ', charImportId, ' = ?;');
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING intId;
                    SELECT ROW_COUNT() INTO @rows_affected;
                    DEALLOCATE PREPARE query_statement;

                    IF @rows_affected = 0 THEN
                        SET bolProceed = FALSE;
                        SET @responseMessage = CONCAT('Failed to delete ', LOWER(charImportName), ' entry!');
                    ELSE
                        SET @id = intId;
                    END IF;
                END IF;
            END IF;

        END IF;
    END IF;

    IF bolProceed THEN
        IF processType = 0 THEN
            SET @responseMessage = CONCAT(charImportName, ' Successfully Saved!');
        ELSEIF processType = 1 THEN
            SET @responseMessage = CONCAT(charImportName, ' Successfully Updated!');
        ELSEIF processType = 2 THEN
            SET @responseMessage = CONCAT(charImportName, ' Successfully Deleted!');
        END IF;
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', @id) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;

    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postItemToUnits` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postItemToUnits`(
    IN jsnItemToUnits JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE intCount INT DEFAULT 0;

    DECLARE intItemId INT;
    DECLARE intUserId INT;
    DECLARE jsnUnits JSON;
    DECLARE jsnUnitsLength INT DEFAULT 0;

    DECLARE intUnitId INT;
    DECLARE intBinId INT;

    IF JSON_VALID(jsnItemToUnits) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET intItemId = JSON_VALUE(jsnItemToUnits, '$.item_id');
        SET intUserId = JSON_VALUE(jsnItemToUnits, '$.user_id');
        SET jsnUnits = JSON_EXTRACT(jsnItemToUnits, '$.units');

        IF JSON_VALID(jsnUnits) THEN
            SET jsnUnitsLength = JSON_LENGTH(jsnUnits);
        ELSE
            SET bolProceed = FALSE;
            SET @responseMessage = 'Invalid units value!';
        END IF;

        IF bolProceed THEN
            SET @countEntry = 0;
            SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM inventory.inventory_items WHERE item_id = ? LIMIT 1';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING intItemId;
            DEALLOCATE PREPARE query_statement;

            IF @countEntry = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'You have entered non-existent item!';
            END IF;
        END IF;

        IF bolProceed THEN
            SET @countEntry = 0;
            SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM application_users_inventory.application_users WHERE user_id = ? LIMIT 1';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING intUserId;
            DEALLOCATE PREPARE query_statement;

            IF @countEntry = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'You have entered non-existent user!';
            END IF;
        END IF;

        SET autocommit = 0;
        START TRANSACTION;

        WHILE bolProceed AND intCount < jsnUnitsLength DO
            SET intUnitId = JSON_VALUE(jsnUnits, CONCAT('$[', intCount, '].unit_id'));
            SET intBinId = JSON_VALUE(jsnUnits, CONCAT('$[', intCount, '].bin_id'));

            SET @unitName = NULL;
            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*), description INTO @countEntry, @unitName FROM subscriber_common_tables.units WHERE unit_id = ? LIMIT 1';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intUnitId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'You have entered non-existent unit!';
                END IF;
            END IF;

            SET @binName = NULL;
            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*), description INTO @countEntry, @binName FROM inventory.unit_bins WHERE bin_id = ? LIMIT 1';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intBinId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'You have entered non-existent bin!';
                END IF;
            END IF;

            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM inventory.unit_bins WHERE bin_id = ? AND unit_id = ? LIMIT 1';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intBinId, intUnitId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT(@binName, ' does not belong to ', @unitName);
                END IF;
            END IF;

            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM inventory.inventory_units_items WHERE item_id = ? AND unit_id = ? LIMIT 1;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intItemId, intUnitId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 1 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT('Item already exists in ', @unitName);
                END IF;
            END IF;

            IF bolProceed THEN
                SET @empty_item_id = 0;
                SELECT iec.empty_item_id INTO @empty_item_id FROM inventory.inventory_items ii LEFT JOIN inventory.inventory_empty_cases iec ON ii.item_id = iec.main_item_id WHERE ii.item_id = intItemId;

                SET @last_id = 0;
                SET @sqlCommand = 'INSERT inventory.inventory_units_items (item_id, unit_id, starting_period, last_entry, starting_quantity, quantity_in, quantity_out, ending_quantity, starting_cost, cost_in, cost_out, ending_Cost, unit_cost, last_highest_in_unit_cost, created_by, datetime_created, bin_id) VALUES (?,?,NOW(),NOW(),0,0,0,0,0,0,0,0,0,0,?,NOW(),?)';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intItemId, intUnitId, intUserId, intBinId;
                SET @last_id = LAST_INSERT_ID();
                DEALLOCATE PREPARE query_statement;

                IF @last_id = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT('Failed to add item to ', @unitName);
                END IF;

                IF @empty_item_id IS NOT NULL AND @empty_item_id > 0 THEN
                    SET @sqlCommand = 'INSERT inventory.inventory_units_items (item_id, unit_id, starting_period, last_entry, starting_quantity, quantity_in, quantity_out, ending_quantity, starting_cost, cost_in, cost_out, ending_Cost, unit_cost, last_highest_in_unit_cost, created_by, datetime_created, bin_id) VALUES (?,?,NOW(),NOW(),0,0,0,0,0,0,0,0,0,0,?,NOW(),?)';
                    PREPARE query_statement FROM @sqlCommand;
                    EXECUTE query_statement USING @empty_item_id, intUnitId, intUserId, intBinId;
                    DEALLOCATE PREPARE query_statement;
                END IF;
            END IF;

            SET intCount = intCount + 1;
        END WHILE;

    END IF;

    IF bolProceed THEN
        SET @responseMessage = CONCAT('Item Successfully Added To The Unit', IF(jsnUnitsLength > 1, 's', ''), '!');
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', @last_id) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;

    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postUnitItemBinSwitch` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_unicode_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postUnitItemBinSwitch`(
    IN jsnUnitItemBinSwitch JSON
)
BEGIN
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE intCount INT DEFAULT 0;

    DECLARE intUserId INT;
    DECLARE jsnSwappedItems JSON;
    DECLARE jsnSwappedItemsLength INT DEFAULT 0;

    DECLARE intUnitItemId INT;
    DECLARE intFromBinId INT;
    DECLARE intToBinId INT;

    IF JSON_VALID(jsnUnitItemBinSwitch) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid parameter to continue!';
    END IF;

    IF bolProceed THEN
        SET intUserId = JSON_VALUE(jsnUnitItemBinSwitch, '$.user_id');
        SET jsnSwappedItems = JSON_EXTRACT(jsnUnitItemBinSwitch, '$.swapped_items');

        IF JSON_VALID(jsnSwappedItems) THEN
            SET jsnSwappedItemsLength = JSON_LENGTH(jsnSwappedItems);
        ELSE
            SET bolProceed = FALSE;
            SET @responseMessage = 'Invalid swapped items value!';
        END IF;

        IF bolProceed THEN
            SET @countEntry = 0;
            SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM application_users_inventory.application_users WHERE user_id = ? LIMIT 1';
            PREPARE query_statement FROM @sqlCommand;
            EXECUTE query_statement USING intUserId;
            DEALLOCATE PREPARE query_statement;

            IF @countEntry = 0 THEN
                SET bolProceed = FALSE;
                SET @responseMessage = 'You have entered non-existent user!';
            END IF;
        END IF;

        SET autocommit = 0;
        START TRANSACTION;

        WHILE bolProceed AND intCount < jsnSwappedItemsLength DO
            SET intUnitItemId = JSON_VALUE(jsnSwappedItems, CONCAT('$[', intCount, '].unit_item_id'));
            SET intFromBinId = JSON_VALUE(jsnSwappedItems, CONCAT('$[', intCount, '].from_bin_id'));
            SET intToBinId = JSON_VALUE(jsnSwappedItems, CONCAT('$[', intCount, '].to_bin_id'));

            SET @unitItemName = NULL;
            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*), iic.item_description INTO @countEntry, @unitItemName FROM inventory.inventory_units_items iui INNER JOIN inventory_udf_and_views.inventory_item_concat iic ON iui.item_id = iic.item_id WHERE unit_item_id = ? LIMIT 1;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intUnitItemId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'You have entered non-existent unit item!';
                END IF;
            END IF;

            SET @binName = NULL;
            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*), description INTO @countEntry, @binName FROM inventory.unit_bins WHERE bin_id = ? LIMIT 1;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intToBinId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = 'You have entered non-existent bin!';
                END IF;
            END IF;

            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM inventory.inventory_units_items iui WHERE unit_item_id = ? AND bin_id = ? LIMIT 1;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intUnitItemId, intFromBinId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT(@binName, ' does not belong to ', @unitItemName);
                END IF;
            END IF;

            IF bolProceed THEN
                SET @countEntry = 0;
                SET @sqlCommand = 'SELECT COUNT(*) INTO @countEntry FROM inventory.inventory_units_items iui WHERE unit_item_id = ? AND bin_id = ? LIMIT 1;';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intUnitItemId, intToBinId;
                DEALLOCATE PREPARE query_statement;

                IF @countEntry = 1 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT(@unitItemName, '\'s bin is already ', @binName);
                END IF;
            END IF;

            IF bolProceed THEN
                SET @rows_affected = 0;
                SET @sqlCommand = 'UPDATE inventory.inventory_units_items SET bin_id = ?, modified_by = ?, datetime_modified = NOW() WHERE unit_item_id = ?';
                PREPARE query_statement FROM @sqlCommand;
                EXECUTE query_statement USING intToBinId, intUserId, intUnitItemId;
                SELECT ROW_COUNT() INTO @rows_affected;
                DEALLOCATE PREPARE query_statement;

                IF @rows_affected = 0 THEN
                    SET bolProceed = FALSE;
                    SET @responseMessage = CONCAT('Failed to update the bin of ', @unitItemName);
                END IF;
            END IF;

            SET intCount = intCount + 1;
        END WHILE;

    END IF;

    IF bolProceed THEN
        SET @responseMessage = 'Items\' Bins Successfully Updated!';
        COMMIT;
        SELECT JSON_OBJECT('success', TRUE, 'message', @responseMessage, 'json_data', NULL) AS response;
    ELSE
        ROLLBACK;
        SELECT JSON_OBJECT('success', FALSE, 'message', @responseMessage, 'json_data', NULL) AS response;
    END IF;

    SET autocommit = 1;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'IGNORE_SPACE,STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
/*!50003 DROP PROCEDURE IF EXISTS `postUpdateInventoryUnit` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_general_ci */ ;
DELIMITER ;;
CREATE DEFINER=`developer`@`%` PROCEDURE `postUpdateInventoryUnit`(
    IN jsnUpdateInventoryUnit JSON
)
BEGIN
    -- Declare control variables
    DECLARE bolProceed BOOLEAN DEFAULT TRUE;
    DECLARE rows_deleted INT DEFAULT 0;
    DECLARE rows_inserted INT DEFAULT 0;

    -- Handle SQL exceptions cleanly
    DECLARE CONTINUE HANDLER FOR SQLEXCEPTION
    BEGIN
        SET bolProceed = FALSE;
        SET @responseMessage = 'Operation failed due to constraints or SQL errors.';
    END;

    -- Validate input parameter
    IF JSON_VALID(jsnUpdateInventoryUnit) THEN
        SET @responseMessage = '';
    ELSE
        SET bolProceed = FALSE;
        SET @responseMessage = 'Please enter a valid JSON parameter to continue!';
    END IF;

    -- Proceed to Delete obsolete inventory units
    IF bolProceed THEN
        SET @sqlCommand =  "DELETE FROM inventory.inventory_units 
                            WHERE 
                                (!warehouse AND ISNULL(person_in_charge) AND ISNULL(person_name)) OR unit_id NOT IN (
                                    SELECT 
                                        u.unit_id
                                    FROM 
                                        subscriber_common_tables.units u
                                );";
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement;
        SELECT ROW_COUNT() INTO rows_deleted; -- Capture the number of rows deleted
        DEALLOCATE PREPARE query_statement;
    END IF;

    -- Proceed to Insert new inventory units
    IF bolProceed THEN
        SET @sqlCommand =  "INSERT INTO inventory.inventory_units
                            (
                                unit_id,
                                warehouse,
                                person_in_charge,
                                person_name
                            )
                            SELECT 
                                u.unit_id,
                                0,
                                NULL,
                                NULL
                            FROM 
                                subscriber_common_tables.units u
                            WHERE
                                unit_id NOT IN (
                                    SELECT 
                                        unit_id
                                    FROM
                                        inventory.inventory_units                        
                                )
                            ORDER BY
                                u.unit_id;";
        PREPARE query_statement FROM @sqlCommand;
        EXECUTE query_statement;
        SELECT ROW_COUNT() INTO rows_inserted; -- Capture the number of rows inserted
        DEALLOCATE PREPARE query_statement;
    END IF;

    -- Standardized Return Logic
    IF bolProceed THEN
        -- Construct a dynamic success message based on affected rows
        SET @responseMessage = CONCAT('Inventory units successfully refreshed! Deleted: ', rows_deleted, ' record(s), Added: ', rows_inserted, ' new record(s).');
        
        SELECT JSON_OBJECT(
            'success', TRUE, 
            'message', @responseMessage, 
            'json_data', NULL
        ) AS response;
    ELSE
        SELECT JSON_OBJECT(
            'success', FALSE, 
            'message', @responseMessage, 
            'json_data', NULL
        ) AS response;
    END IF;

END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09 11:22:42
SET FOREIGN_KEY_CHECKS=1;
