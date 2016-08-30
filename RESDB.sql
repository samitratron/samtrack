CREATE DATABASE  IF NOT EXISTS `resdb` /*!40100 DEFAULT CHARACTER SET utf8 */;
USE `resdb`;
-- MySQL dump 10.13  Distrib 5.7.12, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: resdb
-- ------------------------------------------------------
-- Server version	5.7.13-log

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
-- Table structure for table `activities`
--

DROP TABLE IF EXISTS `activities`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activities` (
  `activity_id` varchar(45) NOT NULL,
  `activity_type` varchar(25) NOT NULL,
  `activity_status` varchar(25) NOT NULL DEFAULT 'Unassigned',
  `activity_priority` varchar(25) NOT NULL,
  `activity_reqemail` varchar(45) NOT NULL,
  `activity_notified_using` varchar(25) NOT NULL,
  `activity_desc` varchar(145) NOT NULL,
  `activity_comments` varchar(145) NOT NULL,
  `activity_reported_date` date NOT NULL,
  `goal_id` int(11) NOT NULL,
  PRIMARY KEY (`activity_id`),
  UNIQUE KEY `activity_id_UNIQUE` (`activity_id`)
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
-- Table structure for table `activity_details`
--

DROP TABLE IF EXISTS `activity_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_details` (
  `id` varchar(45) NOT NULL,
  `activity_owner` varchar(45) NOT NULL,
  `activity_planned_manhrs` int(11) DEFAULT NULL,
  `activity_planned_start_date` date DEFAULT NULL,
  `activity_planned_end_date` date DEFAULT NULL,
  `activity_actual_start_date` date DEFAULT NULL,
  `activity_actual_end_date` date DEFAULT NULL,
  `milestone_id` int(11) DEFAULT NULL,
  `activity_percentage_complete` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_details`
--

LOCK TABLES `activity_details` WRITE;
/*!40000 ALTER TABLE `activity_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `activity_workers`
--

DROP TABLE IF EXISTS `activity_workers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `activity_workers` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `activity_id` varchar(45) NOT NULL,
  `worker_username` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `activity_workers`
--

LOCK TABLES `activity_workers` WRITE;
/*!40000 ALTER TABLE `activity_workers` DISABLE KEYS */;
/*!40000 ALTER TABLE `activity_workers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `bugs`
--

DROP TABLE IF EXISTS `bugs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `bugs` (
  `bug_id` int(11) NOT NULL,
  `bug_logger` varchar(25) NOT NULL,
  `bug_logdate` date NOT NULL,
  `bug_severity` varchar(15) NOT NULL,
  `bug_details` blob NOT NULL,
  `bug_status` varchar(15) NOT NULL,
  `bug_desc` varchar(45) NOT NULL,
  PRIMARY KEY (`bug_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `bugs`
--

LOCK TABLES `bugs` WRITE;
/*!40000 ALTER TABLE `bugs` DISABLE KEYS */;
/*!40000 ALTER TABLE `bugs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `dummy`
--

DROP TABLE IF EXISTS `dummy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dummy` (
  `iddummy` int(11) NOT NULL,
  PRIMARY KEY (`iddummy`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `dummy`
--

LOCK TABLES `dummy` WRITE;
/*!40000 ALTER TABLE `dummy` DISABLE KEYS */;
INSERT INTO `dummy` VALUES (1);
/*!40000 ALTER TABLE `dummy` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `exec_status`
--

DROP TABLE IF EXISTS `exec_status`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `exec_status` (
  `EXEC_STATUS_ID` int(11) NOT NULL DEFAULT '1',
  `RUN_ID` varchar(45) NOT NULL,
  `TC_ID` varchar(45) NOT NULL,
  `TC_STATUS` varchar(45) NOT NULL,
  PRIMARY KEY (`EXEC_STATUS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `exec_status`
--

LOCK TABLES `exec_status` WRITE;
/*!40000 ALTER TABLE `exec_status` DISABLE KEYS */;
/*!40000 ALTER TABLE `exec_status` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goal_success_criteria`
--

DROP TABLE IF EXISTS `goal_success_criteria`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `goal_success_criteria` (
  `success_criteria_id` int(11) NOT NULL DEFAULT '1',
  `goal_id` int(11) NOT NULL,
  `success_definition` varchar(125) NOT NULL,
  PRIMARY KEY (`success_criteria_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goal_success_criteria`
--

LOCK TABLES `goal_success_criteria` WRITE;
/*!40000 ALTER TABLE `goal_success_criteria` DISABLE KEYS */;
/*!40000 ALTER TABLE `goal_success_criteria` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `goals`
--

DROP TABLE IF EXISTS `goals`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `goals` (
  `goal_id` int(11) NOT NULL AUTO_INCREMENT,
  `goal_name` varchar(125) NOT NULL,
  `goal_desc` varchar(300) NOT NULL,
  `goal_year` year(4) NOT NULL,
  `goal_creation_date` date NOT NULL,
  `goal_target_date` date NOT NULL,
  `goal_type` varchar(45) NOT NULL,
  `goal_percentage_complete` int(11) DEFAULT NULL,
  PRIMARY KEY (`goal_id`)
) ENGINE=MyISAM AUTO_INCREMENT=201518 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `goals`
--

LOCK TABLES `goals` WRITE;
/*!40000 ALTER TABLE `goals` DISABLE KEYS */;
/*!40000 ALTER TABLE `goals` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_role`
--

DROP TABLE IF EXISTS `job_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `job_role` (
  `rolename` varchar(45) NOT NULL,
  `roledesc` varchar(125) NOT NULL,
  `role_domain` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`rolename`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_role`
--

LOCK TABLES `job_role` WRITE;
/*!40000 ALTER TABLE `job_role` DISABLE KEYS */;
INSERT INTO `job_role` VALUES ('API Automation Consultant','Senior indiviudal contributor on automation',NULL),('APP Automation Consultant','Heads a specific QA area',NULL),('Automation Architect','As architect for all automation needs',NULL),('Automation Framework Developer','Senior Engineer working on automation',NULL),('Managing Automation Team','Manages automation deliverables and resources',NULL),('Mobile Automation Consultant','Senior indiviudal contributor on automation',NULL);
/*!40000 ALTER TABLE `job_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `milestone`
--

DROP TABLE IF EXISTS `milestone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `milestone` (
  `milestone_id` int(11) NOT NULL AUTO_INCREMENT,
  `goal_id` int(11) NOT NULL,
  `milestone_desc` varchar(125) NOT NULL,
  `milestone_date` date NOT NULL,
  `milestone_comments` varchar(300) NOT NULL,
  `milestone_reqemail` varchar(45) NOT NULL,
  `milestone_achieved` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`milestone_id`)
) ENGINE=MyISAM AUTO_INCREMENT=2097 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `milestone`
--

LOCK TABLES `milestone` WRITE;
/*!40000 ALTER TABLE `milestone` DISABLE KEYS */;
/*!40000 ALTER TABLE `milestone` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `new_skillset_request`
--

DROP TABLE IF EXISTS `new_skillset_request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `new_skillset_request` (
  `skillset_request_id` int(11) NOT NULL AUTO_INCREMENT,
  `skillset_requester` varchar(15) NOT NULL,
  `skillset_name` varchar(45) NOT NULL,
  `skillset_desc` varchar(125) NOT NULL,
  `skillset_type` varchar(45) NOT NULL,
  `comp_level` varchar(25) NOT NULL,
  PRIMARY KEY (`skillset_request_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `new_skillset_request`
--

LOCK TABLES `new_skillset_request` WRITE;
/*!40000 ALTER TABLE `new_skillset_request` DISABLE KEYS */;
/*!40000 ALTER TABLE `new_skillset_request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `projects`
--

DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `projects` (
  `projname` varchar(45) NOT NULL,
  `projdesc` varchar(145) DEFAULT NULL,
  `proj_type` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`projname`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `projects`
--

LOCK TABLES `projects` WRITE;
/*!40000 ALTER TABLE `projects` DISABLE KEYS */;
/*!40000 ALTER TABLE `projects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `resources`
--

DROP TABLE IF EXISTS `resources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `resources` (
  `username` varchar(25) NOT NULL,
  `password` varchar(32) NOT NULL,
  `role` varchar(15) NOT NULL,
  `first_name` varchar(45) NOT NULL,
  `last_name` varchar(45) NOT NULL,
  `title` varchar(45) NOT NULL,
  `manager` varchar(15) NOT NULL,
  `emailid` varchar(45) NOT NULL,
  `locale` varchar(15) NOT NULL,
  `mantis_username` varchar(25) NOT NULL,
  `team` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`username`),
  UNIQUE KEY `username_UNIQUE` (`username`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `resources`
--

LOCK TABLES `resources` WRITE;
/*!40000 ALTER TABLE `resources` DISABLE KEYS */;
INSERT INTO `resources` VALUES ('admin','40be4e59b9a2a2b5dffb918c0e86b3d7','admin','Admin_User','Not Applicable','Admin','boss','admin@admin.com','Bangalore','admin',NULL),('guest','40be4e59b9a2a2b5dffb918c0e86b3d7','user','Guest','User','Guest','admin','guest@guest.com','Bangalore','guest',NULL);
/*!40000 ALTER TABLE `resources` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `risk_register`
--

DROP TABLE IF EXISTS `risk_register`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `risk_register` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `risk_desc` varchar(300) NOT NULL,
  `risk_affecting_milestone` int(11) NOT NULL,
  `risk_raise_date` date NOT NULL,
  `risk_raised_by` varchar(45) NOT NULL,
  `risk_impact` int(11) NOT NULL,
  `risk_probability` float NOT NULL,
  `risk_mitigation_plan` varchar(300) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=MyISAM AUTO_INCREMENT=11 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `risk_register`
--

LOCK TABLES `risk_register` WRITE;
/*!40000 ALTER TABLE `risk_register` DISABLE KEYS */;
/*!40000 ALTER TABLE `risk_register` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `run_details`
--

DROP TABLE IF EXISTS `run_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `run_details` (
  `RUN_DETAILS_ID` varchar(25) NOT NULL,
  `HOST_IP` varchar(25) NOT NULL,
  `ENV_ID` int(11) NOT NULL,
  `BUILD_ID` varchar(45) NOT NULL,
  `EXEC_STATUS` varchar(25) NOT NULL,
  `EXEC_ON` datetime NOT NULL,
  PRIMARY KEY (`RUN_DETAILS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `run_details`
--

LOCK TABLES `run_details` WRITE;
/*!40000 ALTER TABLE `run_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `run_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `run_history`
--

DROP TABLE IF EXISTS `run_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `run_history` (
  `RUN_HISTORY_ID` int(11) NOT NULL DEFAULT '1',
  `RUN_ID` varchar(45) NOT NULL,
  `LOG_ID` int(11) NOT NULL,
  `RUN_COMMENTS` varchar(125) NOT NULL,
  PRIMARY KEY (`RUN_HISTORY_ID`),
  KEY `FK_RUN_ID_idx` (`RUN_ID`),
  CONSTRAINT `FK_RUN_ID` FOREIGN KEY (`RUN_ID`) REFERENCES `run_details` (`RUN_DETAILS_ID`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `run_history`
--

LOCK TABLES `run_history` WRITE;
/*!40000 ALTER TABLE `run_history` DISABLE KEYS */;
/*!40000 ALTER TABLE `run_history` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `skillset`
--

DROP TABLE IF EXISTS `skillset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `skillset` (
  `skillset_name` varchar(45) NOT NULL,
  `skillset_desc` varchar(45) NOT NULL,
  `skillset_type` varchar(45) NOT NULL,
  `role` varchar(45) NOT NULL,
  PRIMARY KEY (`skillset_name`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `skillset`
--

LOCK TABLES `skillset` WRITE;
/*!40000 ALTER TABLE `skillset` DISABLE KEYS */;
INSERT INTO `skillset` VALUES ('Automating Tests','Automating Tests','QA','Automation Consultant'),('Automation Execution','Automation Execution','QA','Automation Consultant'),('Demo / KT To Stakeholders','Demo / KT To Stakeholders','QA','Automation Consultant'),('Design Review','Design Review','QA','Automation Consultant'),('Failure Analysis','Failure Analysis','QA','Automation Consultant'),('Fixing Scripts','Fixing Scripts','QA','Automation Consultant'),('Framework Enhancement','Framework Enhancement','QA','Automation Consultant'),('Functional Test KT','Functional Test KT','QA','Automation Consultant'),('Improving Coverage','Improving Coverage','QA','Automation Consultant'),('New Cobrand Automation','New Cobrand Automation','QA','Automation Consultant'),('QA Delivery Mgmt','Managing QA delivery','QA','Managing Automation Team'),('QA Resource Mgmt','Managing QA Resources','QA','Managing Automation Team'),('Report Creation','Report Creation','QA','Automation Consultant'),('Requirements Review','Requirements Review','QA','Automation Consultant'),('REST API Script Creation','REST API Script Creation','QA','Automation Consultant'),('SOAP API Script Creation','SOAP API Script Creation','QA','Automation Consultant'),('SOAP Script Integration','SOAP Script Integration','QA','Automation Consultant'),('Task Automation','Task Automation','QA','Automation Consultant'),('Test Case Review','Test Case Review','QA','Automation Consultant'),('Test Suite Execution','Test Suite Execution','QA','Automation Consultant'),('Training to Stakeholders','Training to Stakeholders','QA','Automation Consultant');
/*!40000 ALTER TABLE `skillset` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `success_datapoints`
--

DROP TABLE IF EXISTS `success_datapoints`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `success_datapoints` (
  `datapoint_id` int(11) NOT NULL DEFAULT '1',
  `success_criteria_id` int(11) NOT NULL,
  `success_data_collection_date` date NOT NULL,
  `success_datapoint` blob NOT NULL,
  PRIMARY KEY (`datapoint_id`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `success_datapoints`
--

LOCK TABLES `success_datapoints` WRITE;
/*!40000 ALTER TABLE `success_datapoints` DISABLE KEYS */;
/*!40000 ALTER TABLE `success_datapoints` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suite_details`
--

DROP TABLE IF EXISTS `suite_details`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suite_details` (
  `SUITE_DETAILS_ID` varchar(25) NOT NULL,
  `SUITE_PLATFORM` varchar(45) NOT NULL,
  `SUITE_TYPE` varchar(45) NOT NULL,
  `PROD_ID` int(11) NOT NULL,
  PRIMARY KEY (`SUITE_DETAILS_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suite_details`
--

LOCK TABLES `suite_details` WRITE;
/*!40000 ALTER TABLE `suite_details` DISABLE KEYS */;
/*!40000 ALTER TABLE `suite_details` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `suite_to_tc_mapping`
--

DROP TABLE IF EXISTS `suite_to_tc_mapping`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `suite_to_tc_mapping` (
  `SUITE_TO_TC_MAPPING_ID` int(11) NOT NULL DEFAULT '1',
  `SUITE_ID` varchar(45) NOT NULL,
  `TC_ID` varchar(45) NOT NULL,
  PRIMARY KEY (`SUITE_TO_TC_MAPPING_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `suite_to_tc_mapping`
--

LOCK TABLES `suite_to_tc_mapping` WRITE;
/*!40000 ALTER TABLE `suite_to_tc_mapping` DISABLE KEYS */;
/*!40000 ALTER TABLE `suite_to_tc_mapping` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_global`
--

DROP TABLE IF EXISTS `task_global`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_global` (
  `task_id` varchar(25) NOT NULL,
  `task_username` varchar(25) NOT NULL,
  `task_cat` varchar(45) DEFAULT NULL,
  `task_comments` varchar(300) NOT NULL,
  `task_projname` varchar(45) NOT NULL,
  `task_date` date DEFAULT NULL,
  `task_manhour` int(11) NOT NULL,
  `task_priority` varchar(15) NOT NULL,
  `task_assigned_by` varchar(25) NOT NULL,
  `task_percentage_complete` int(11) DEFAULT NULL,
  `task_status` varchar(45) NOT NULL,
  `task_eta` varchar(45) DEFAULT NULL,
  `activity_id` varchar(45) DEFAULT NULL,
  `task_depends_on` varchar(45) DEFAULT NULL,
  `task_enddate` date DEFAULT NULL,
  PRIMARY KEY (`task_id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_global`
--

LOCK TABLES `task_global` WRITE;
/*!40000 ALTER TABLE `task_global` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_global` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `task_transactions`
--

DROP TABLE IF EXISTS `task_transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `task_transactions` (
  `transaction_id` int(11) NOT NULL AUTO_INCREMENT,
  `task_id` varchar(25) NOT NULL,
  `task_username` varchar(45) NOT NULL,
  `task_cat` varchar(45) NOT NULL,
  `task_comments` varchar(300) NOT NULL,
  `task_projname` varchar(45) NOT NULL,
  `task_update_date` date NOT NULL,
  `task_manhour` int(11) NOT NULL,
  `task_priority` varchar(45) NOT NULL,
  `task_percentage_complete` int(11) DEFAULT NULL,
  `task_status` varchar(45) NOT NULL,
  `task_eta` varchar(45) DEFAULT NULL,
  `activity_id` varchar(90) NOT NULL,
  `transaction_type` varchar(45) NOT NULL,
  PRIMARY KEY (`transaction_id`)
) ENGINE=MyISAM AUTO_INCREMENT=192 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `task_transactions`
--

LOCK TABLES `task_transactions` WRITE;
/*!40000 ALTER TABLE `task_transactions` DISABLE KEYS */;
/*!40000 ALTER TABLE `task_transactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_leaves`
--

DROP TABLE IF EXISTS `user_leaves`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_leaves` (
  `leave_entry` int(11) NOT NULL AUTO_INCREMENT,
  `username` varchar(45) NOT NULL,
  `leave_fromdate` date NOT NULL,
  `leave_todate` date NOT NULL,
  `leave_type` varchar(25) NOT NULL,
  `leave_justification` varchar(125) NOT NULL,
  PRIMARY KEY (`leave_entry`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_leaves`
--

LOCK TABLES `user_leaves` WRITE;
/*!40000 ALTER TABLE `user_leaves` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_leaves` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_roles`
--

DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_roles` (
  `index` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(15) NOT NULL,
  `user_role` varchar(45) NOT NULL,
  PRIMARY KEY (`index`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_roles`
--

LOCK TABLES `user_roles` WRITE;
/*!40000 ALTER TABLE `user_roles` DISABLE KEYS */;
INSERT INTO `user_roles` VALUES (1,'admin','Managing Automation Team'),(2,'guest','Automation Architect');
/*!40000 ALTER TABLE `user_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_skillset`
--

DROP TABLE IF EXISTS `user_skillset`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_skillset` (
  `skillset_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_name` varchar(15) NOT NULL,
  `user_skillset_desc` varchar(45) NOT NULL,
  `user_skillset_type` varchar(45) DEFAULT NULL,
  PRIMARY KEY (`skillset_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_skillset`
--

LOCK TABLES `user_skillset` WRITE;
/*!40000 ALTER TABLE `user_skillset` DISABLE KEYS */;
INSERT INTO `user_skillset` VALUES (1,'admin','Certified Project Management Professional','BU_INDEPENDENT'),(2,'guest','Certified Scrum Master','BU_INDEPENDENT');
/*!40000 ALTER TABLE `user_skillset` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2016-08-30 15:09:58
