
-------------Create tables and insert some data-------------
CREATE TABLE Aircraft_info (
ID CHAR(6),                            
model VARCHAR2(100) NOT NULL,          
manufacturer VARCHAR2(100) NOT NULL,   
PRIMARY KEY (ID)
);
INSERT INTO AIRCRAFT_info VALUES ('XY-ALV','A340','Airbus'); 
INSERT INTO AIRCRAFT_info VALUES ('XY-CMJ','737','Boeing'); 
INSERT INTO AIRCRAFT_info VALUES ('XY-FBA','A330neo','Airbus');

CREATE TABLE dayMonthYear (
dayMonthYearID Date,                                       
monthID CHAR(7) NOT null,
PRIMARY KEY (dayMonthYearID),
FOREIGN KEY (monthID) REFERENCES MonthYear(MonthYearID)
);

INSERT INTO dayMonthYear VALUES ('1/02/2021','02/2021');
INSERT INTO dayMonthYear VALUES ('1/07/2021','07/2021');
INSERT INTO dayMonthYear VALUES ('1/05/2022','05/2022');
INSERT INTO dayMonthYear VALUES ('8/02/2021','02/2021');


CREATE TABLE MonthYear (
MonthYearID CHAR(7),
y NUMBER(4) NOT NULL,
PRIMARY KEY (MonthYearID)
);
INSERT INTO MonthYear VALUES ('02/2021', '2021');
INSERT INTO MonthYear VALUES ('07/2021', '2021');
INSERT INTO MonthYear VALUES ('05/2022', '2022');


CREATE TABLE People (
ID CHAR(6),                                       
airport CHAR(3),
role CHAR(1) CHECK (role IN ('P','M')) NOT NULL,
CONSTRAINT airport_maintenance CHECK (ROLE ='M' AND airport IS NOT NULL OR ROLE ='P' AND airport IS null),
PRIMARY KEY (ID)
);

INSERT INTO People VALUES ('100000','gtr','M');
INSERT INTO People VALUES ('102','','P');
INSERT INTO People VALUES ('107','','P');


CREATE TABLE AircraftMetrics (
aircraftID CHAR(6),
timeID Date,
scheduledOutOfService NUMBER(2),
unScheduledOutOfService NUMBER(2),
flightHours NUMBER(2),
flightCycles NUMBER(2),
delays NUMBER(2),  
delayedMinutes NUMBER(3),
cancellations NUMBER(2),
PRIMARY KEY (aircraftID, timeID),
FOREIGN KEY (aircraftID) REFERENCES Aircraft_info(ID),
FOREIGN KEY (timeID) REFERENCES dayMonthYear(dayMonthYearID)
);

INSERT INTO AircraftMetrics VALUES ('XY-ALV','1/02/2021','2','3','6','8','9','10','19');
INSERT INTO AircraftMetrics VALUES ('XY-ALV','1/05/2022','1','7','10','8','9','10','19');
INSERT INTO AircraftMetrics VALUES ('XY-ALV','8/02/2021','2','3','10','20','9','10','19');


CREATE TABLE LogBooks (
aircraftID CHAR(6),
monthID CHAR(7),
personID CHAR(6),
counter NUMBER(2) NOT NULL,
PRIMARY KEY (aircraftID, monthID, personID),
FOREIGN KEY (aircraftID) REFERENCES Aircraft_info(ID),
FOREIGN KEY (monthID) REFERENCES MonthYear(MonthYearID),
FOREIGN KEY (personID) REFERENCES People(ID)
);
INSERT INTO LOGBOOKS VALUES ('XY-ALV','02/2021','100000',3);
INSERT INTO LOGBOOKS VALUES ('XY-CMJ','07/2021','107',5);
INSERT INTO LOGBOOKS VALUES ('XY-FBA','07/2021','102',10);


-------------MATERIALIZED VIEW LOGS FOR EVERY TABLE INVOLVED IN THE VIEWS-------------
CREATE MATERIALIZED VIEW LOG ON dayMonthYear
WITH ROWID,SEQUENCE(dayMonthYearID, monthID)
INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON MonthYear
WITH ROWID,SEQUENCE(MonthYearID, y)
INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON People
WITH ROWID,SEQUENCE(ID, airport, role)
INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON AIRCRAFT_info
WITH ROWID,SEQUENCE(ID, model, manufacturer)
INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON LogBooks
WITH ROWID,SEQUENCE(aircraftID,  monthID, personID, counter) INCLUDING NEW VALUES;

CREATE MATERIALIZED VIEW LOG ON AircraftMetrics
WITH ROWID,SEQUENCE(aircraftID, timeID, scheduledOutOfService, unScheduledOutOfService,
flightHours, flightCycles, delays, delayedMinutes, cancellations) INCLUDING NEW VALUES;

----------------------------------------MV for extrcting FH & TO per month-------------------------------------------
CREATE MATERIALIZED VIEW AIRCRAFT_METRICS_FH
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
START WITH SYSDATE NEXT (ADD_MONTHS(TRUNC(SYSDATE,'MM'),1))
Enable QUERY REWRITE AS
	SELECT ai.ID, ai.MODEL,
	d.monthID AS month,
	t.y AS year,  
	sum(am.flightHours) AS T_flightHours,
	sum(am.flightCycles)AS T_flightCycles
	FROM AIRCRAFT_info ai, AircraftMetrics am, dayMonthYear d, MonthYear t
	WHERE am.aircraftID = ai.ID AND
		am.timeID = d.dayMonthYearID AND 
		d.MONTHID = t.MonthYearID 
	GROUP BY ai.ID, ai.MODEL, d.monthID, t.y;

--------------------------------------Log for previous MV------------------------------------------
CREATE MATERIALIZED VIEW LOG ON AIRCRAFT_METRICS_FH
WITH ROWID,SEQUENCE(ID, Model, month, T_flightHours,T_flightCycles
) INCLUDING NEW VALUES;

----------------------------------------MV for LOOGBOOK_MONTHLY--------------------------------------------
CREATE MATERIALIZED VIEW LOOGBOOK_MONTHLY
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
START WITH SYSDATE NEXT (ADD_MONTHS(TRUNC(SYSDATE,'MM'),1))
ENABLE QUERY REWRITE AS
	SELECT l.aircraftID, 
	p.ROLE, 
	p.airport,
	ai.MODEL, 
	ai.MANUFACTURER, 
	t.MonthYearID AS month,
	t.y AS year,
	sum(test. T_flightHours) AS T_flightHours,
	sum(test.T_flightCycles) AS T_flightCycles, 
	SUM (l.counter) AS T_counter
	FROM LogBooks l, MonthYear t, AIRCRAFT_info ai, People p, AIRCRAFT_METRICS_FH test
	WHERE  l.aircraftID = ai.ID AND 
	l.monthID = t.MonthYearID And 
	p.ID= l.personID AND  
	test.ID = l.aircraftID AND 
	test.MONTH= l.MONTHID 
	GROUP BY l.aircraftID, p.ROLE, p.airport, ai.MODEL, ai.MANUFACTURER, t.MonthYearID,
	t.y;

----------------------------------------MV for AIRCRAFT_METRICS-----------------------------------------------------
CREATE MATERIALIZED VIEW AIRCRAFT_METRICS_DAILY
BUILD IMMEDIATE
REFRESH FAST
ON DEMAND
START WITH SYSDATE NEXT SYSDATE + 1
Enable QUERY REWRITE AS
	SELECT ai.ID, ai.MODEL,
	d.dayMonthYearID AS day, 
	d.monthID AS month,
	t.y AS year,  
	sum(am.flightHours) AS T_flightHours,
	sum(am.flightCycles)AS T_flightCycles,
	COUNT(d.dayMonthYearID)AS T_days, 
	SUM(am.delays) AS T_NumberofDelays, 
	SUM(am.cancellations) AS T_NumberofCancells ,
	SUM(am.delayedMinutes)AS T_MinutesDelay,
	sum(am.scheduledOutOfService) AS T_ADOSS,
	sum(am.unScheduledOutOfService) AS T_ADOSU
	FROM AIRCRAFT_info ai, AircraftMetrics am, dayMonthYear d, MonthYear t
	WHERE am.aircraftID = ai.ID AND
		am.timeID = d.dayMonthYearID AND 
		d.MONTHID = t.MonthYearID 
	GROUP BY ai.ID, ai.MODEL, d.dayMonthYearID, d.monthID, t.y;
