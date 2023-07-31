-- ----------------------------------------------------------------
--          Indyco Builder - Auto-Generated DDL Script           --
-- ----------------------------------------------------------------
--
-- Project Name . . . . . . : DW_project1
--  + Exported Datamarts. . : Datamart
--  + Export Timestamp. . . : 2022-10-25 18:34:36
--
-- Selected Profile . . . . : Star Schema
--  + Shared Hierarchies. . : Snowflake
--  + Cross Dimensional Attr: Bridge table without surrogates
--  + Degenerate Dimensions : Use fact table
--  + Multiple Arcs . . . . : Bridge table without surrogates
--  + Recursions. . . . . . : Use self-referencing keys
--
-- Target DB. . . . . . . . : MySQL
--  + Export Primary Keys . : True
--  + Export Foreign Keys . : True
--  + Nullable columns. . . : True
--
-- ----------------------------------------------------------------

-- WARNING
-- If you omit the ENGINE option, the default storage engine is used (normally, this is MyISAM).
-- For storage engines that do not support foreign keys (such as MyISAM), MySQL Server parses and ignores foreign key specifications.
-- https://dev.mysql.com/doc/refman/5.1/en/storage-engine-setting.html
-- http://dev.mysql.com/doc/refman/5.1/en/create-table-foreign-keys.html

-- Comment out the statement below to enforce the InnoDB storage engine on each created table (it will be applied only on this session).
-- SET storage_engine=InnoDB;

CREATE TABLE `DT_AIRCRAFT_INFO`
(
  `ID_AIRCRAFT_INFO` INT PRIMARY KEY,
  `AIRCRAFT_INFO` VARCHAR (255),
  `MODEL` VARCHAR (255),
  `ID_MODEL` INT,
  `ID` VARCHAR (255),
  `ID_ID` INT,
  `MANUFACTURE` VARCHAR (255),
  `ID_MANUFACTURE` INT
);




CREATE TABLE `DT_MONTHYEAR`
(
  `ID_MONTHYEAR` INT PRIMARY KEY,
  `MONTHYEAR` VARCHAR (255),
  `YEARID` VARCHAR (255),
  `ID_YEARID` INT,
  `YEAR` VARCHAR (255),
  `ID_YEAR` INT
);




CREATE TABLE `FT_AIRCRAFTMETRICS`
(
  `ID_AIRCRAFT_INFO` INT,
  `ID_DATE_YEARMONTHDAY` INT,
  `FLIGHTHOURS` DECIMAL (18,3),
  `FLIGHTCYCLES` DECIMAL (18,3),
  `SCHEDULEOUT_OF_SERVISE` DECIMAL (18,3),
  `UNSCHEDULEOUTOFSERVICE` DECIMAL (18,3),
  `DELAYS` DECIMAL (18,3),
  `DELAYSMINUTES` DECIMAL (18,3),
  `CANCELLATION` DECIMAL (18,3)
);
ALTER TABLE `FT_AIRCRAFTMETRICS` ADD CONSTRAINT `PK_FT_AIRCRAFTMETRICS` PRIMARY KEY (`ID_AIRCRAFT_INFO`, `ID_DATE_YEARMONTHDAY`);




CREATE TABLE `DT_DATE_YEARMONTHDAY`
(
  `ID_DATE_YEARMONTHDAY` INT PRIMARY KEY,
  `DATE_YEARMONTHDAY` VARCHAR (255),
  `YEATMONTHID` VARCHAR (255),
  `ID_MONTHYEAR` INT
);




CREATE TABLE `FT_LOGBOOKS`
(
  `ID_AIRCRAFT_INFO` INT,
  `ID_PEOPLE` INT,
  `ID_MONTHYEAR` INT,
  `COUNT` DECIMAL (18,3)
);
ALTER TABLE `FT_LOGBOOKS` ADD CONSTRAINT `PK_FT_LOGBOOKS` PRIMARY KEY (`ID_AIRCRAFT_INFO`, `ID_PEOPLE`, `ID_MONTHYEAR`);




CREATE TABLE `DT_PEOPLE`
(
  `ID_PEOPLE` INT PRIMARY KEY,
  `PEOPLE` VARCHAR (255),
  `ID` VARCHAR (255),
  `AIRPORT` VARCHAR (255),
  `ROLE` VARCHAR (255)
);







ALTER TABLE `FT_AIRCRAFTMETRICS` ADD CONSTRAINT `FK_FT_ARCR_ID_ARCR_INFO_ID_AR` FOREIGN KEY (`ID_AIRCRAFT_INFO`) REFERENCES `DT_AIRCRAFT_INFO` (`ID_AIRCRAFT_INFO`);
ALTER TABLE `FT_AIRCRAFTMETRICS` ADD CONSTRAINT `FK_FT_ARCR_ID_DATE_YRMN_ID_DA` FOREIGN KEY (`ID_DATE_YEARMONTHDAY`) REFERENCES `DT_DATE_YEARMONTHDAY` (`ID_DATE_YEARMONTHDAY`);

ALTER TABLE `DT_DATE_YEARMONTHDAY` ADD CONSTRAINT `FK_DT_DATE_YRMN_ID_MNTH_ID_MN` FOREIGN KEY (`ID_MONTHYEAR`) REFERENCES `DT_MONTHYEAR` (`ID_MONTHYEAR`);

ALTER TABLE `FT_LOGBOOKS` ADD CONSTRAINT `FK_FT_LGBK_ID_ARCR_INFO_ID_AR` FOREIGN KEY (`ID_AIRCRAFT_INFO`) REFERENCES `DT_AIRCRAFT_INFO` (`ID_AIRCRAFT_INFO`);
ALTER TABLE `FT_LOGBOOKS` ADD CONSTRAINT `FK_FT_LOGBOOKS_ID_PPL_ID_PPL` FOREIGN KEY (`ID_PEOPLE`) REFERENCES `DT_PEOPLE` (`ID_PEOPLE`);
ALTER TABLE `FT_LOGBOOKS` ADD CONSTRAINT `FK_FT_LGBK_ID_MNTH_ID_MNTH` FOREIGN KEY (`ID_MONTHYEAR`) REFERENCES `DT_MONTHYEAR` (`ID_MONTHYEAR`);



-- ALTER TABLE `FT_AIRCRAFTMETRICS` DROP CONSTRAINT FK_FT_ARCR_ID_ARCR_INFO_ID_AR;
-- ALTER TABLE `FT_AIRCRAFTMETRICS` DROP CONSTRAINT FK_FT_ARCR_ID_DATE_YRMN_ID_DA;
-- ALTER TABLE `DT_DATE_YEARMONTHDAY` DROP CONSTRAINT FK_DT_DATE_YRMN_ID_MNTH_ID_MN;
-- ALTER TABLE `FT_LOGBOOKS` DROP CONSTRAINT FK_FT_LGBK_ID_ARCR_INFO_ID_AR;
-- ALTER TABLE `FT_LOGBOOKS` DROP CONSTRAINT FK_FT_LOGBOOKS_ID_PPL_ID_PPL;
-- ALTER TABLE `FT_LOGBOOKS` DROP CONSTRAINT FK_FT_LGBK_ID_MNTH_ID_MNTH;
-- DROP TABLE `DT_AIRCRAFT_INFO`;
-- DROP TABLE `DT_MONTHYEAR`;
-- DROP TABLE `FT_AIRCRAFTMETRICS`;
-- DROP TABLE `DT_DATE_YEARMONTHDAY`;
-- DROP TABLE `FT_LOGBOOKS`;
-- DROP TABLE `DT_PEOPLE`;




