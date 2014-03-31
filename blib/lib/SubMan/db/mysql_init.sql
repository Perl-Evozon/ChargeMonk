/*
SQLyog Community v11.28 (32 bit)
MySQL - 5.5.35-0+wheezy1 : Database - subman
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`subman` /*!40100 DEFAULT CHARACTER SET latin1 */;

/*Table structure for table `authorize_user` */

DROP TABLE IF EXISTS `authorize_user`;

CREATE TABLE `authorize_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `customer_id` varchar(50) DEFAULT NULL,
  `card_type` varchar(30) DEFAULT NULL,
  `last_four` varchar(4) DEFAULT NULL,
  `expiration_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `authorize_user_idx_user_id` (`user_id`),
  CONSTRAINT `authorize_user_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=latin1;

/*Data for the table `authorize_user` */

/*Table structure for table `braintree_user` */

DROP TABLE IF EXISTS `braintree_user`;

CREATE TABLE `braintree_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_token` varchar(50) NOT NULL,
  `user_id` int(11) NOT NULL,
  `card_type` varchar(30) DEFAULT NULL,
  `last_four` varchar(4) DEFAULT NULL,
  `expiration_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `braintree_user_idx_user_id` (`user_id`),
  CONSTRAINT `braintree_user_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=77 DEFAULT CHARSET=latin1;

/*Data for the table `braintree_user` */

/*Table structure for table `campaign` */

DROP TABLE IF EXISTS `campaign`;

CREATE TABLE `campaign` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `prefix` varchar(5) NOT NULL,
  `nr_of_codes` int(11) NOT NULL DEFAULT '0',
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `discount_type` enum('unit','percent') DEFAULT NULL,
  `discount_amount` int(11) NOT NULL,
  `valability` date DEFAULT NULL,
  `user_id` int(11) NOT NULL,
  `subscription_id` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `campaign_idx_subscription_id` (`subscription_id`),
  KEY `campaign_idx_user_id` (`user_id`),
  CONSTRAINT `campaign_fk_subscription_id` FOREIGN KEY (`subscription_id`) REFERENCES `subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `campaign_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=29 DEFAULT CHARSET=latin1;

/*Data for the table `campaign` */

/*Table structure for table `code` */

DROP TABLE IF EXISTS `code`;

CREATE TABLE `code` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `campaign_id` int(11) NOT NULL,
  `code` varchar(30) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `redeem_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `code_idx_campaign_id` (`campaign_id`),
  KEY `code_idx_user_id` (`user_id`),
  CONSTRAINT `code_fk_campaign_id` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `code_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=139 DEFAULT CHARSET=latin1;

/*Data for the table `code` */

/*Table structure for table `config` */

DROP TABLE IF EXISTS `config`;

CREATE TABLE `config` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `config` */

/*Table structure for table `feature` */

DROP TABLE IF EXISTS `feature`;

CREATE TABLE `feature` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(30) NOT NULL,
  `description` varchar(200) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_feature_names` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=56 DEFAULT CHARSET=latin1;

/*Data for the table `feature` */

/*Table structure for table `invoice` */

DROP TABLE IF EXISTS `invoice`;

CREATE TABLE `invoice` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `invoice_id` varchar(20) NOT NULL,
  `link_user_subscription_id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `gateway` varchar(50) DEFAULT NULL,
  `remaining_amount` int(11) DEFAULT NULL,
  `charge` int(11) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `invoice_invoice_id_key` (`invoice_id`),
  KEY `invoice_idx_link_user_subscription_id` (`link_user_subscription_id`),
  KEY `invoice_idx_user_id` (`user_id`),
  CONSTRAINT `invoice_fk_link_user_subscription_id` FOREIGN KEY (`link_user_subscription_id`) REFERENCES `link_user_subscription` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `invoice_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=195 DEFAULT CHARSET=latin1;

/*Data for the table `invoice` */

/*Table structure for table `ip_range` */

DROP TABLE IF EXISTS `ip_range`;

CREATE TABLE `ip_range` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link_user_subscription_id` int(11) NOT NULL,
  `subscription_id` int(11) NOT NULL,
  `from_ip` varchar(15) NOT NULL,
  `to_ip` varchar(15) NOT NULL,
  `start_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `ip_range_idx_link_user_subscription_id` (`link_user_subscription_id`),
  KEY `ip_range_idx_subscription_id` (`subscription_id`),
  CONSTRAINT `ip_range_fk_link_user_subscription_id` FOREIGN KEY (`link_user_subscription_id`) REFERENCES `link_user_subscription` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `ip_range_fk_subscription_id` FOREIGN KEY (`subscription_id`) REFERENCES `subscription` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `ip_range` */

/*Table structure for table `link_campaigns_subscriptions` */

DROP TABLE IF EXISTS `link_campaigns_subscriptions`;

CREATE TABLE `link_campaigns_subscriptions` (
  `subscription_id` int(11) NOT NULL,
  `campaign_id` int(11) NOT NULL,
  KEY `link_campaigns_subscriptions_idx_campaign_id` (`campaign_id`),
  KEY `link_campaigns_subscriptions_idx_subscription_id` (`subscription_id`),
  CONSTRAINT `link_campaigns_subscriptions_fk_campaign_id` FOREIGN KEY (`campaign_id`) REFERENCES `campaign` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `link_campaigns_subscriptions_fk_subscription_id` FOREIGN KEY (`subscription_id`) REFERENCES `subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `link_campaigns_subscriptions` */

/*Table structure for table `link_subscription_feature` */

DROP TABLE IF EXISTS `link_subscription_feature`;

CREATE TABLE `link_subscription_feature` (
  `subscription_id` int(11) NOT NULL,
  `feature_id` int(11) NOT NULL,
  PRIMARY KEY (`subscription_id`,`feature_id`),
  KEY `link_subscription_feature_idx_feature_id` (`feature_id`),
  KEY `link_subscription_feature_idx_subscription_id` (`subscription_id`),
  CONSTRAINT `link_subscription_feature_fk_feature_id` FOREIGN KEY (`feature_id`) REFERENCES `feature` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `link_subscription_feature_fk_subscription_id` FOREIGN KEY (`subscription_id`) REFERENCES `subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `link_subscription_feature` */

/*Table structure for table `link_user_subscription` */

DROP TABLE IF EXISTS `link_user_subscription`;

CREATE TABLE `link_user_subscription` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `subscription_id` int(11) NOT NULL,
  `nr_of_period_users` int(11) DEFAULT NULL,
  `active_from_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `active_to_date` timestamp NOT NULL DEFAULT '0000-00-00 00:00:00',
  `active` tinyint(1) NOT NULL DEFAULT '0',
  `cancelled` tinyint(1) NOT NULL DEFAULT '0',
  `process_date` timestamp NULL DEFAULT NULL,
  `process_message` varchar(255) DEFAULT NULL,
  `process_status` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `link_user_subscription_idx_subscription_id` (`subscription_id`),
  KEY `link_user_subscription_idx_user_id` (`user_id`),
  CONSTRAINT `link_user_subscription_fk_subscription_id` FOREIGN KEY (`subscription_id`) REFERENCES `subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `link_user_subscription_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=341 DEFAULT CHARSET=latin1;

/*Data for the table `link_user_subscription` */

/*Table structure for table `period_user` */

DROP TABLE IF EXISTS `period_user`;

CREATE TABLE `period_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `link_user_subscription_id` int(11) NOT NULL,
  `subscription_id` int(11) NOT NULL,
  `first_name` varchar(30) NOT NULL,
  `last_name` varchar(30) NOT NULL,
  `email` varchar(50) NOT NULL,
  `start_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `period_user_idx_link_user_subscription_id` (`link_user_subscription_id`),
  KEY `period_user_idx_subscription_id` (`subscription_id`),
  CONSTRAINT `period_user_fk_link_user_subscription_id` FOREIGN KEY (`link_user_subscription_id`) REFERENCES `link_user_subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `period_user_fk_subscription_id` FOREIGN KEY (`subscription_id`) REFERENCES `subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `period_user` */

/*Table structure for table `registration` */

DROP TABLE IF EXISTS `registration`;

CREATE TABLE `registration` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sex` tinyint(1) DEFAULT NULL,
  `first_name` tinyint(1) DEFAULT NULL,
  `last_name` tinyint(1) DEFAULT NULL,
  `date_of_birth` tinyint(1) DEFAULT NULL,
  `address` tinyint(1) DEFAULT NULL,
  `address_2` tinyint(1) DEFAULT NULL,
  `country` tinyint(1) DEFAULT NULL,
  `state` tinyint(1) DEFAULT NULL,
  `zip_code` tinyint(1) DEFAULT NULL,
  `phone_number` tinyint(1) DEFAULT NULL,
  `company_name` tinyint(1) DEFAULT NULL,
  `company_address` tinyint(1) DEFAULT NULL,
  `company_country` tinyint(1) DEFAULT NULL,
  `company_state` tinyint(1) DEFAULT NULL,
  `company_zip_code` tinyint(1) DEFAULT NULL,
  `company_phone_number` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `registration` */

insert  into `registration`(`id`,`sex`,`first_name`,`last_name`,`date_of_birth`,`address`,`address_2`,`country`,`state`,`zip_code`,`phone_number`,`company_name`,`company_address`,`company_country`,`company_state`,`company_zip_code`,`company_phone_number`) values (1,0,1,1,0,0,0,0,0,0,0,1,0,0,0,0,0);

/*Table structure for table `stripe_user` */

DROP TABLE IF EXISTS `stripe_user`;

CREATE TABLE `stripe_user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `card_token` varchar(50) NOT NULL,
  `user_id` int(11) DEFAULT NULL,
  `customer_id` varchar(50) DEFAULT NULL,
  `card_type` varchar(30) DEFAULT NULL,
  `last_four` varchar(4) DEFAULT NULL,
  `expiration_date` date DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `id` (`id`),
  KEY `stripe_user_fk_id` (`user_id`),
  CONSTRAINT `stripe_user_fk_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=latin1;

/*Data for the table `stripe_user` */

/*Table structure for table `subscription` */

DROP TABLE IF EXISTS `subscription`;

CREATE TABLE `subscription` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) DEFAULT NULL,
  `subscription_type` enum('regular','promo') DEFAULT NULL,
  `subscription_group_id` int(11) DEFAULT NULL,
  `is_visible` tinyint(1) NOT NULL DEFAULT '0',
  `require_company_data` tinyint(1) NOT NULL DEFAULT '0',
  `has_auto_renew` tinyint(1) NOT NULL DEFAULT '0',
  `access_type` enum('period','period_users','IP_range','resources','API_calls') DEFAULT NULL,
  `period` int(11) DEFAULT NULL,
  `price` int(11) DEFAULT NULL,
  `call_to_action` varchar(30) DEFAULT NULL,
  `has_trial` tinyint(1) DEFAULT '1',
  `min_active_period_users` int(11) DEFAULT NULL,
  `max_active_period_users` int(11) DEFAULT NULL,
  `position_in_group` int(11) NOT NULL,
  `currency` enum('EUR','USD','GBP','RON','XAU','AUD','CAD','CHF','CZK','DKK','EGP','HUF','JPY','MDL','NOK','PLN','SEK','TRY','XDR','RUB','BGN','ZAR','BRL','CNY','INR','KRW','MXN','NZD','RSD','UAH','AED') DEFAULT NULL,
  `number_of_users` int(11) DEFAULT NULL,
  `trial_period` int(11) DEFAULT NULL,
  `trial_price` int(11) DEFAULT NULL,
  `trial_currency` enum('EUR','USD','GBP','RON','XAU','AUD','CAD','CHF','CZK','DKK','EGP','HUF','JPY','MDL','NOK','PLN','SEK','TRY','XDR','RUB','BGN','ZAR','BRL','CNY','INR','KRW','MXN','NZD','RSD','UAH','AED') DEFAULT NULL,
  `require_credit_card` tinyint(1) DEFAULT '0',
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `created_by` varchar(80) DEFAULT NULL,
  `resource_type` varchar(40) DEFAULT NULL,
  `min_resource_quantity` int(11) DEFAULT NULL,
  `max_resource_quantity` int(11) DEFAULT NULL,
  `min_active_ips` int(11) DEFAULT NULL,
  `max_active_ips` int(11) DEFAULT NULL,
  `api_calls_volume` int(11) DEFAULT NULL,
  `period_count` int(11) DEFAULT NULL,
  `period_unit` enum('Day','Week','Month','Year') DEFAULT NULL,
  `trial_period_count` int(11) DEFAULT NULL,
  `trial_period_unit` enum('Day','Week','Month','Year') DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `subscription_idx_subscription_group_id` (`subscription_group_id`),
  CONSTRAINT `subscription_fk_subscription_group_id` FOREIGN KEY (`subscription_group_id`) REFERENCES `subscription_group` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=240 DEFAULT CHARSET=latin1;

/*Data for the table `subscription` */

/*Table structure for table `subscription_downgrades_to` */

DROP TABLE IF EXISTS `subscription_downgrades_to`;

CREATE TABLE `subscription_downgrades_to` (
  `subscription_id` int(11) NOT NULL,
  `subscription_downgrade_id` int(11) NOT NULL,
  PRIMARY KEY (`subscription_id`,`subscription_downgrade_id`),
  KEY `subscription_downgrades_to_idx_subscription_downgrade_id` (`subscription_downgrade_id`),
  CONSTRAINT `subscription_downgrades_to_fk_subscription_downgrade_id` FOREIGN KEY (`subscription_downgrade_id`) REFERENCES `subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `subscription_downgrades_to` */

/*Table structure for table `subscription_group` */

DROP TABLE IF EXISTS `subscription_group`;

CREATE TABLE `subscription_group` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(40) NOT NULL,
  `creation_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_names` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=190 DEFAULT CHARSET=latin1;

/*Data for the table `subscription_group` */

insert  into `subscription_group`(`id`,`name`,`creation_date`) values (1,'Default','2014-03-03 09:30:59');

/*Table structure for table `subscription_upgrades_to` */

DROP TABLE IF EXISTS `subscription_upgrades_to`;

CREATE TABLE `subscription_upgrades_to` (
  `subscription_id` int(11) NOT NULL,
  `subscription_upgrade_id` int(11) NOT NULL,
  PRIMARY KEY (`subscription_id`,`subscription_upgrade_id`),
  KEY `subscription_upgrades_to_idx_subscription_upgrade_id` (`subscription_upgrade_id`),
  CONSTRAINT `subscription_upgrades_to_fk_subscription_upgrade_id` FOREIGN KEY (`subscription_upgrade_id`) REFERENCES `subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `subscription_upgrades_to` */

/*Table structure for table `theme` */

DROP TABLE IF EXISTS `theme`;

CREATE TABLE `theme` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `css_file` varchar(128) NOT NULL,
  `image_file` varchar(128) NOT NULL,
  `active` tinyint(1) DEFAULT '0',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

/*Data for the table `theme` */

insert  into `theme`(`id`,`name`,`css_file`,`image_file`,`active`) values (1,'test_template','test-template.4/style.css','test-template.4/thumb.png',0);

/*Table structure for table `transaction` */

DROP TABLE IF EXISTS `transaction`;

CREATE TABLE `transaction` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `link_user_subscription_id` int(11) NOT NULL,
  `gateway` varchar(50) DEFAULT NULL,
  `tranzaction_id` varchar(20) DEFAULT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `amount` int(11) NOT NULL,
  `success` tinyint(1) NOT NULL DEFAULT '0',
  `action` varchar(50) DEFAULT NULL,
  `response_text` varchar(500) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `transaction_idx_link_user_subscription_id` (`link_user_subscription_id`),
  KEY `transaction_idx_user_id` (`user_id`),
  CONSTRAINT `transaction_fk_link_user_subscription_id` FOREIGN KEY (`link_user_subscription_id`) REFERENCES `link_user_subscription` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION,
  CONSTRAINT `transaction_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE NO ACTION
) ENGINE=InnoDB AUTO_INCREMENT=68 DEFAULT CHARSET=latin1;

/*Data for the table `transaction` */

/*Table structure for table `user` */

DROP TABLE IF EXISTS `user`;

CREATE TABLE `user` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `firstname` varchar(100) DEFAULT NULL,
  `lastname` varchar(100) DEFAULT NULL,
  `email` varchar(50) NOT NULL,
  `address` varchar(200) DEFAULT NULL,
  `address2` varchar(200) DEFAULT NULL,
  `country` varchar(50) DEFAULT NULL,
  `state` varchar(50) DEFAULT NULL,
  `zip_code` varchar(10) DEFAULT NULL,
  `phone` varchar(15) DEFAULT NULL,
  `gender` varchar(1) DEFAULT NULL,
  `company_name` varchar(100) DEFAULT NULL,
  `company_address` varchar(200) DEFAULT NULL,
  `company_country` varchar(50) DEFAULT NULL,
  `company_state` varchar(50) DEFAULT NULL,
  `company_zip_code` varchar(10) DEFAULT NULL,
  `company_phone` varchar(15) DEFAULT NULL,
  `profile_picture` varchar(250) DEFAULT NULL,
  `user_type` enum('ADMIN','CUSTOMER','LEAD') NOT NULL DEFAULT 'LEAD',
  `birthday` date DEFAULT NULL,
  `password` varchar(64) DEFAULT NULL,
  `signup_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_email_key` (`email`)
) ENGINE=InnoDB AUTO_INCREMENT=576 DEFAULT CHARSET=latin1;

/*Data for the table `user` */

/*Table structure for table `user_photo` */

DROP TABLE IF EXISTS `user_photo`;

CREATE TABLE `user_photo` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `photo` blob,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `user_photo` */

/*Table structure for table `user_psw_set_token` */

DROP TABLE IF EXISTS `user_psw_set_token`;

CREATE TABLE `user_psw_set_token` (
  `uid` int(11) NOT NULL,
  `token` varchar(20) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`uid`),
  UNIQUE KEY `user_psw_set_token_token_key` (`token`),
  KEY `uid` (`uid`),
  CONSTRAINT `user_psw_set_token_fk_uid` FOREIGN KEY (`uid`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `user_psw_set_token` */

/*Table structure for table `user_registration_token` */

DROP TABLE IF EXISTS `user_registration_token`;

CREATE TABLE `user_registration_token` (
  `user_id` int(11) NOT NULL,
  `link_user_subscription_id` int(11) NOT NULL,
  `token` varchar(20) NOT NULL,
  `flow_type` varchar(10) NOT NULL,
  `created` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `user_registration_token_token_key` (`token`),
  KEY `user_registration_token_idx_link_user_subscription_id` (`link_user_subscription_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `user_registration_token_fk_link_user_subscription_id` FOREIGN KEY (`link_user_subscription_id`) REFERENCES `link_user_subscription` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `user_registration_token_fk_user_id` FOREIGN KEY (`user_id`) REFERENCES `user` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `user_registration_token` */

/*Table structure for table `user_type` */

DROP TABLE IF EXISTS `user_type`;

CREATE TABLE `user_type` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `user_type` varchar(10) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_type_type_key` (`user_type`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `user_type` */

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
