-- ----------------------------------------------------------------
--          Indyco Builder - Auto-Generated DDL Script           --
-- ----------------------------------------------------------------
--
-- Project Name . . . . . . : DW_project1
--  + Exported Datamarts. . : Datamart
--  + Export Timestamp. . . : 2022-10-25 18:19:03
--
-- Selected Profile . . . . : Star Schema
--  + Shared Hierarchies. . : Snowflake
--  + Cross Dimensional Attr: Bridge table without surrogates
--  + Degenerate Dimensions : Use fact table
--  + Multiple Arcs . . . . : Bridge table without surrogates
--  + Recursions. . . . . . : Use self-referencing keys
--
-- Target DB. . . . . . . . : Oracle Database
--  + Export Primary Keys . : True
--  + Export Foreign Keys . : False
--  + Nullable columns. . . : True
--
-- ----------------------------------------------------------------

CREATE TABLE "DT_AIRCRAFT_INFO"
(
  "ID_AIRCRAFT_INFO" NUMBER (9),
  "AIRCRAFT_INFO" VARCHAR2 (255 CHAR),
  "MODEL" VARCHAR2 (255 CHAR),
  "ID_MODEL" NUMBER (9),
  "ID" VARCHAR2 (255 CHAR),
  "ID_ID" NUMBER (9),
  "MANUFACTURE" VARCHAR2 (255 CHAR),
  "ID_MANUFACTURE" NUMBER (9)
);
ALTER TABLE "DT_AIRCRAFT_INFO" ADD CONSTRAINT "PK_DT_AIRCRAFT_INFO" PRIMARY KEY ("ID_AIRCRAFT_INFO");





CREATE TABLE "DT_MONTHYEAR"
(
  "ID_MONTHYEAR" NUMBER (9),
  "MONTHYEAR" VARCHAR2 (255 CHAR),
  "YEARID" VARCHAR2 (255 CHAR),
  "ID_YEARID" NUMBER (9),
  "YEAR" VARCHAR2 (255 CHAR),
  "ID_YEAR" NUMBER (9)
);
ALTER TABLE "DT_MONTHYEAR" ADD CONSTRAINT "PK_DT_MONTHYEAR" PRIMARY KEY ("ID_MONTHYEAR");





CREATE TABLE "FT_AIRCRAFTMETRICS"
(
  "ID_AIRCRAFT_INFO" NUMBER (9),
  "ID_DATE_YEARMONTHDAY" NUMBER (9),
  "FLIGHTHOURS" NUMBER (18,3),
  "FLIGHTCYCLES" NUMBER (18,3),
  "SCHEDULEOUT_OF_SERVISE" NUMBER (18,3),
  "UNSCHEDULEOUTOFSERVICE" NUMBER (18,3),
  "DELAYS" NUMBER (18,3),
  "DELAYSMINUTES" NUMBER (18,3),
  "CANCELLATION" NUMBER (18,3)
);
ALTER TABLE "FT_AIRCRAFTMETRICS" ADD CONSTRAINT "PK_FT_AIRCRAFTMETRICS" PRIMARY KEY ("ID_AIRCRAFT_INFO", "ID_DATE_YEARMONTHDAY");





CREATE TABLE "DT_DATE_YEARMONTHDAY"
(
  "ID_DATE_YEARMONTHDAY" NUMBER (9),
  "DATE_YEARMONTHDAY" VARCHAR2 (255 CHAR),
  "YEATMONTHID" VARCHAR2 (255 CHAR),
  "ID_MONTHYEAR" NUMBER (9)
);
ALTER TABLE "DT_DATE_YEARMONTHDAY" ADD CONSTRAINT "PK_DT_DATE_YEARMONTHDAY" PRIMARY KEY ("ID_DATE_YEARMONTHDAY");





CREATE TABLE "FT_LOGBOOKS"
(
  "ID_AIRCRAFT_INFO" NUMBER (9),
  "ID_PEOPLE" NUMBER (9),
  "ID_MONTHYEAR" NUMBER (9),
  "COUNT" NUMBER (18,3)
);
ALTER TABLE "FT_LOGBOOKS" ADD CONSTRAINT "PK_FT_LOGBOOKS" PRIMARY KEY ("ID_AIRCRAFT_INFO", "ID_PEOPLE", "ID_MONTHYEAR");





CREATE TABLE "DT_PEOPLE"
(
  "ID_PEOPLE" NUMBER (9),
  "PEOPLE" VARCHAR2 (255 CHAR),
  "ID" VARCHAR2 (255 CHAR),
  "AIRPORT" VARCHAR2 (255 CHAR),
  "ROLE" VARCHAR2 (255 CHAR)
);
ALTER TABLE "DT_PEOPLE" ADD CONSTRAINT "PK_DT_PEOPLE" PRIMARY KEY ("ID_PEOPLE");













-- DROP TABLE "DT_AIRCRAFT_INFO" CASCADE CONSTRAINTS;
-- DROP TABLE "DT_MONTHYEAR" CASCADE CONSTRAINTS;
-- DROP TABLE "FT_AIRCRAFTMETRICS" CASCADE CONSTRAINTS;
-- DROP TABLE "DT_DATE_YEARMONTHDAY" CASCADE CONSTRAINTS;
-- DROP TABLE "FT_LOGBOOKS" CASCADE CONSTRAINTS;
-- DROP TABLE "DT_PEOPLE" CASCADE CONSTRAINTS;




