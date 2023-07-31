-- create tables 

CREATE TABLE Months (
ID CHAR(7),
y NUMBER(4) NOT NULL
) PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE TemporalDimension (
ID DATE,
monthID CHAR(7) NOT NULL
) PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE AircraftDimension (
ID CHAR(6),                            
model VARCHAR2(100) NOT NULL,          
manufacturer VARCHAR2(100) NOT NULL
) PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE AircraftUtilization (
aircraftID CHAR(6),
timeID DATE,
scheduledOutOfService NUMBER(2),
unScheduledOutOfService NUMBER(2),
flightHours NUMBER(2),
flightCycles NUMBER(2),
delays NUMBER(2),
delayedMinutes NUMBER(3),
cancellations NUMBER(2)
) PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE PeopleDimension (
ID CHAR(6),                                       
airport CHAR(3),
role CHAR(1) CHECK (role IN ('P','M')) NOT NULL
) PCTFREE 0 ENABLE ROW MOVEMENT;

CREATE TABLE LogBookReporting (
aircraftID CHAR(6),
monthID CHAR(7),
personID CHAR(6),
counter NUMBER(2) NOT NULL
) PCTFREE 0 ENABLE ROW MOVEMENT;

-- generate data 
DECLARE
  i INTEGER;
  j INTEGER;
  k INTEGER;
  nextDate DATE;
  nextMonth varchar2(6);
  manufacturer varchar2(6);
  model varchar2(25);
  maxPeople CONSTANT INTEGER := 100;  
  maxTemporal CONSTANT INTEGER := 5000;   
  l_start_date DATE := DATE'2004-01-01';
 
  type aircraftarray is varray(20) of varchar2(6);
  aircrafts CONSTANT aircraftarray := aircraftarray('XY-WTR', 'XY-VWK', 'XY-OKG','XY-HNS','XY-QLY','XY-XTT','XY-QXN','XY-JJQ','XY-ZSE','XY-XVI','XY-HXO','XY-IOL','XY-WBH','XY-EYQ','XY-OSF','XY-KKF','XY-ZHR','XY-HCI','XY-XPV','XY-VYU'); 
   
  type modelBoeingarray is varray(4) of varchar2(25);
  modelsBoeing CONSTANT modelBoeingarray := modelBoeingarray('767','777','747','737');
 
  type modelAirbusarray is varray(6) of varchar2(25);
  modelsAirbus CONSTANT modelAirbusarray := modelAirbusarray('A340','A330','A321','A330neo','A320neo family','A350 XWB');
 
  type manufacturerarray is varray(2) of varchar2(6);
  manufacturers CONSTANT manufacturerarray := manufacturerarray('Boeing','Airbus');
 
  type airportarray is varray(100) of varchar2(3);
  airports CONSTANT airportarray := airportarray('AGP','SKP','TSE','ESB','VKO','IEV','TIV','FRA','DUB','PDL','GYD','KIV','TRD','CLJ','TLL','OLB','BHX','KRS','DME','DRS','VNO','TFS','NUE','GDN','OVD','BGY','ORY','FNC','MSQ','LPL','TLS','TPS','RVN','PUY','AJA','LWO','CIA','GVA','LTN','HUY','BIQ','DBV','REU','BOO','ODS','RHO','CIY','BJV','BSL','GLA','EIN','LUG','BRQ','BRN','CTA','AAR','TSF','KUN','ZTH','WAW','BIO','LYS','PMO','CFU','OSL','BES','AER','ZAZ','FUE','LNZ','FMO','LIL','SVG','PMI','GOA','INI','LJU','IST','SVX','KBP','XRY','TZX','SEN','OVB','FCO','OST','VLC','SCQ','PFO','HAJ','ALC','PSR','ORK','AAL','EXT','BIA','MAN','BRS','SXF','FAO');
 
  type rolearray is varray(2) of varchar2(1);
  roles CONSTANT rolearray := rolearray('P','M');
  
BEGIN
DBMS_RANDOM.seed(0);

-- Insertions in AircraftDimentsion
FOR i IN 1..(aircrafts.count) LOOP
  manufacturer := manufacturers(dbms_random.value(1,2));
  IF (manufacturer = 'Airbus') THEN
  INSERT INTO AIRCRAFTDIMENSION(ID, MODEL, MANUFACTURER) VALUES (aircrafts(i), modelsAirbus(dbms_random.value(1,6)), manufacturer);
  ELSIF (manufacturer = 'Boeing') THEN 
  INSERT INTO AIRCRAFTDIMENSION(ID, MODEL, MANUFACTURER) VALUES (aircrafts(i), modelsBoeing(dbms_random.value(1,4)), manufacturer);
  END IF;
 END LOOP;
 
 -- Insertions in PeopleDimension
FOR i IN 1..(maxPeople) LOOP
  INSERT INTO PEOPLEDIMENSION(ID, AIRPORT, "ROLE") VALUES (i, airports(dbms_random.value(1,100)), roles(dbms_random.value(1,2)));
  END LOOP;   
 

 -- Insertions in TemporalDimensions and Months
 nextMonth :=  CONCAT(LPAD(EXTRACT(MONTH FROM l_start_date),2,'0'), LPAD(EXTRACT(YEAR FROM l_start_date),4,'0'));
 INSERT INTO MONTHS(ID,Y) VALUES (nextMonth, SUBSTR(nextMonth,LENGTH(nextMonth)-3,4));
 FOR i IN 1..maxTemporal LOOP  
  nextDate := l_start_date + i;    
  IF CONCAT(LPAD(EXTRACT(MONTH FROM nextDate),2,'0'), LPAD(EXTRACT(YEAR FROM nextDate),4,'0')) <> nextMonth THEN 
      nextMonth :=  CONCAT(LPAD(EXTRACT(MONTH FROM nextDate),2,'0'), LPAD(EXTRACT(YEAR FROM nextDate),4,'0'));
	  INSERT INTO MONTHS(ID,Y) VALUES (nextMonth, SUBSTR(nextMonth,LENGTH(nextMonth)-3,4));
  END IF; 
  INSERT INTO TEMPORALDIMENSION(ID, MONTHID) VALUES (nextDate, nextMonth); 
 END LOOP;
  
-- Insertions in LogBookReporting
 nextMonth :=  CONCAT(LPAD(EXTRACT(MONTH FROM l_start_date),2,'0'), LPAD(EXTRACT(YEAR FROM l_start_date),4,'0'));
 FOR i IN 1..aircrafts.count LOOP
   FOR k IN 1..maxPeople LOOP
	 FOR j IN 1..maxTemporal LOOP
	     nextDate := l_start_date + j;
	     IF CONCAT(LPAD(EXTRACT(MONTH FROM nextDate),2,'0'), LPAD(EXTRACT(YEAR FROM nextDate),4,'0')) <> nextMonth THEN 
		    nextMonth :=  CONCAT(LPAD(EXTRACT(MONTH FROM nextDate),2,'0'), LPAD(EXTRACT(YEAR FROM nextDate),4,'0'));	
		 ELSE CONTINUE;
		 END IF;		 
		  INSERT INTO LOGBOOKREPORTING(AIRCRAFTID, MONTHID, PERSONID, COUNTER) VALUES (
		    aircrafts(i),
		    nextMonth,
		    k,
		    CAST(dbms_random.value(1,50) AS INT) );
		 END LOOP;
	 END LOOP;
 END LOOP;

-- Insertions in AircraftUtilization
FOR i IN 1..aircrafts.count LOOP
	 FOR j IN 1..maxTemporal LOOP		
	 nextDate := l_start_date + j;
	  INSERT INTO AIRCRAFTUTILIZATION(AIRCRAFTID, TIMEID, FLIGHTHOURS, FLIGHTCYCLES, DELAYS, DELAYEDMINUTES, CANCELLATIONS, SCHEDULEDOUTOFSERVICE, UNSCHEDULEDOUTOFSERVICE) VALUES (
	    aircrafts(i),
	    nextDate,	    
	  	CAST(dbms_random.value(1,24) AS INT),
	    CAST(dbms_random.value(1,5) AS INT),
	    CAST(dbms_random.value(1,5) AS INT),
	    CAST(dbms_random.value(1,3) AS INT),
	    CAST(dbms_random.value(0,2) AS INT),
	    CAST(dbms_random.value(1,5) AS INT),
	    CAST(dbms_random.value(1,5) AS INT));		 
	 END LOOP;
END LOOP;

UPDATE PEOPLEDIMENSION SET airport=null WHERE ROLE='P';

END;

COMMIT;
------------------------------------------------------------------------------------------------------
ALTER TABLE AIRCRAFTDIMENSION SHRINK SPACE;
ALTER TABLE PEOPLEDIMENSION SHRINK SPACE;
ALTER TABLE TEMPORALDIMENSION SHRINK SPACE;
ALTER TABLE MONTHS SHRINK SPACE;
ALTER TABLE AIRCRAFTUTILIZATION SHRINK SPACE;
ALTER TABLE LOGBOOKREPORTING SHRINK SPACE;

-------------------------INDEXES FOR FIRST AND SECOND QURIES--------------------------
ALTER TABLE AircraftDimension ADD PRIMARY KEY (id) USING INDEX PCTFREE 33;
ALTER TABLE PeopleDimension ADD PRIMARY KEY (id) USING INDEX PCTFREE 33;


CREATE BITMAP INDEX a_model ON AircraftUtilization(AircraftDimension.model) 
FROM AircraftUtilization, AircraftDimension WHERE AircraftDimension.id = AircraftUtilization.aircraftid PCTFREE 0;

CREATE BITMAP INDEX a_aircraft ON AircraftUtilization(aircraftid) PCTFREE 0;
--169

--------Give me FH and FC per month, filtered by the aircraft model--------
SELECT t.monthid AS Month, SUM(a.FlightHours) AS FH, SUM(a.FlightCycles) AS FC
FROM AircraftUtilization a, TemporalDimension t,AircraftDimension d 
WHERE t.ID = a.timeid AND  d.id=a.aircraftid AND  d.model='777'
GROUP BY t.monthid;
------cost:169 and extra 32 blocks for indexs------



-----(30%) Give me ADOSS, ADOSU per year, filtered by the aircraft from the fleet (e.g., "XY-WTR")----------
SELECT m.y AS Year, SUM(a.scheduledoutofservice) AS ADOSS, SUM(a.unscheduledoutofservice) AS ADOSU
FROM AircraftUtilization a,  TemporalDimension t, Months m
WHERE a.timeid=t.id AND t.monthid=m.id AND a.aircraftid ='XY-WTR'
GROUP BY m.y;
---COST: 112, 24 BLOCKS FOR INDEX, USED PREVIOUS INDEXES



---------------------------L-MODEL INDEX---------------------------
CREATE BITMAP INDEX l_model ON LogbookReporting(AircraftDimension.model) FROM 
LogbookReporting, AircraftDimension WHERE AircraftDimension.id = LogbookReporting.aircraftid PCTFREE 0;


-- (20%) Give me the RRh, RRc, PRRh, PRRc, MRRh and MRRc per month, filtered by the aircraft model.
SELECT l.month AS Month, 
	1000*SUM(l.pirep+l.marep)/SUM(a.FH) AS RRh, 100*SUM(l.pirep+l.marep)/SUM(a.FC) AS RRc,
	1000*SUM(l.pirep)/SUM(a.FH) AS PRRh, 1000*SUM(l.marep)/SUM(a.FH) AS MRRh, 
	100*SUM(l.pirep)/SUM(a.FC) AS PRRc, 100*SUM(l.marep)/SUM(a.FC) AS MRRc
FROM (
		SELECT l.aircraftid AS aircraft, l.monthid AS Month,
		    SUM(CASE WHEN p.ROLE = 'P' THEN counter ELSE 0 END) AS PIREP,
		    SUM(CASE WHEN p.ROLE = 'M' THEN counter ELSE 0 END) AS MAREP
		FROM LogBookReporting l
			INNER JOIN PeopleDimension p ON l.personid = p.id
			INNER JOIN AircraftDimension d ON l.aircraftid = d.id
		WHERE d.model = '777'
		GROUP BY l.aircraftid, l.monthid
	)
	INNER JOIN (
		SELECT a.aircraftid AS aircraft, t.monthid AS Month,
			SUM(a.FlightHours) AS FH, SUM(a.FlightCycles) AS FC
		FROM AircraftUtilization a
			INNER JOIN TemporalDimension t ON a.timeid = t.id
		GROUP BY a.aircraftid, t.monthid
	) a ON l.aircraft = a.aircraft AND l.month = a.month 
GROUP BY l.month;
----COST: 2261,
-----COST: 1312, AFTER INDEX OF L_MODEL(16)
-----COST: 1312, AFTER INDEX OF L_AIRPORT(16)



---------------------------L-AIRPORT INDEX---------------------------
CREATE BITMAP INDEX l_airport ON LogbookReporting(PeopleDimension.airport) FROM
LogbookReporting, PeopleDimension WHERE PeopleDimension.id = LogbookReporting.personid PCTFREE 0;


-- (20%) Give me the MRRh and MRRc per aircraft model, filtered by the airport of the reporting 
SELECT d.model AS Model, 
	1000*SUM(l.marep)/SUM(a.FH) AS MRRh, 100*SUM(l.marep)/SUM(a.FC) AS MRRc
FROM (
		SELECT l.AircraftID AS aircraft, l.monthID AS Month, p.airport AS airport,
		    SUM(CASE WHEN p.ROLE = 'M' THEN counter ELSE 0 END) AS MAREP
		FROM LogBookReporting l
			INNER JOIN PeopleDimension p ON l.personid = p.id
		WHERE p.airport = 'KRS'
		GROUP BY l.aircraftID, l.monthID, p.airport
	) l 
	INNER JOIN (
		SELECT a.aircraftid AS aircraft, t.monthid AS Month,
			SUM(a.FlightHours) AS FH, SUM(a.FlightCycles) AS FC
		FROM AircraftUtilization a
			INNER JOIN TemporalDimension t ON a.timeid = t.id
		GROUP BY a.aircraftid, t.monthid
	) a ON l.aircraft = a.aircraft AND l.month = a.month 
	INNER JOIN AircraftDimension d ON l.aircraft = d.id
GROUP BY d.model;

---COST: 1764  INDEX L-MODEL
---COST:798 INDEX L-AIRPORT AND L-MODEL



---------INFORMATION FOR BLOCKS THAT ARE USED---------
SELECT INDEX_NAME,TABLE_NAME, LEAF_BLOCKS  FROM USER_INDEXES ;
SELECT SEGMENT_NAME, SEGMENT_TYPE, BYTES, BLOCKS FROM USER_SEGMENTS;



