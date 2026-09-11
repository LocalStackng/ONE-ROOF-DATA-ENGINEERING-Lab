USE PortOps;
GO

-- TASK 1: Understand the Size of the Source

-- Return the total number of records separately for:

--   dbo.VesselCall == record is 60 records
--   dbo.Container == record is 108 records
--   dbo.ContainerMovement == record is 50 records
--   dbo.DataLoadLog == record is 28 records


SELECT COUNT(*) AS total_number_of_VesselCall_records
FROM dbo.VesselCall;

SELECT COUNT(*) AS total_number_of_Container_records
FROM dbo.Container;

SELECT COUNT(*) AS total_number_of_ContainerMovement_records
FROM dbo.ContainerMovement;

SELECT COUNT(*) AS total_number_of_DataLoadLog_records
FROM dbo.DataLoadLog;

-- ENGINEERING QUESTION:
-- Why would row volume matter when deciding how to load data?

  /* I think it matters because the resources for a million rows will definitely be different to that of a thousand rows.
     The way i have it in my head is like, fundamentally, as a plumber the size of pipe needed to pull 10,000Ltrs will 
     def be different from the size needed for a 100,000Ltrs. Not just pipe, the machine to pull the water,
     the connectors, the controllers; all these will be determined by the size of the water. */


-- TASK 2: Understand the Container Data Coverage
-- Determine:
--   - Earliest CreatedAt  2026-09-10 12:18:33.6100000
--   - Latest CreatedAt  2026-09-10 12:23:07.6533333
--   - Total number of containers  108
-- from dbo.Container.
-- ENGINEERING QUESTION:
-- What period of source data are we dealing with?

	/* Period of Source Data Coverage: 10 September 2026, 12:18:33.6100000 to 12:23:07.6533333, 
	covering about 5 minutes. */

SELECT MIN(CreatedAt) AS Earliest_CreatedAt
FROM dbo.Container;

SELECT MAX(CreatedAt) AS Latest_CreatedAt
FROM dbo.Container;

SELECT COUNT(*) AS total_number_of_Container_records
FROM dbo.Container;

-- TASK 3: Understand the Movement Data Coverage
-- Determine:
--   - Earliest MovementTime 2026-09-10 12:18:33.6200000
--   - Latest MovementTime 2026-09-10 12:23:07.6633333
--   - Total number of movements 50
-- from dbo.ContainerMovement.

-- ENGINEERING QUESTION:
-- Does the movement history cover the same period as the
-- container master data?
	
	/* Yeah - there is a kind of alignment between the data, there is a consistent 10 milliseconds after CreatedAt at both table*/

SELECT MIN(CreatedAt) AS Earliest_MovementTime
FROM dbo.ContainerMovement;

SELECT MAX(CreatedAt) AS Latest_MovementTime
FROM dbo.ContainerMovement;

SELECT COUNT(*) AS total_number_of_Container_records
FROM dbo.ContainerMovement;

/* ============================================================
   SECTION B — DATA QUALITY BEFORE LOAD
   ============================================================ */

-- TASK 4: Mandatory Weight Check
-- GrossWeightKG is required for the destination dataset.
-- Find all containers where GrossWeightKG is NULL.
-- Return:
--   ContainerID
--   ContainerNumber
--   ISOType
--   Category
--   ShippingLineID
-- Then write a second query showing the total number affected. == 4
-- ENGINEERING QUESTION:
-- Would you load these records?
-- If yes, how would you treat them?
-- If no, what happens to them?

	/* No, i will not load the data. Records with NULL GrossWeightKG will not be loaded into the destination 
	dataset because GrossWeightKG value is a required value for the destination dataset. However, this value 
	will be logged somewhere with the validation failure*/

-- a) Detail records:
-- YOUR QUERY HERE:
SELECT	ContainerID,
		ContainerNumber,
		ISOType,
		Category,
		ShippingLineID
FROM dbo.Container
WHERE GrossWeightKG is NULL;

-- b) Count:
-- YOUR QUERY HERE:
SELECT
    COUNT(*) AS TotalAffected
FROM dbo.Container
WHERE GrossWeightKG IS NULL;

-- TASK 5: Container Number Uniqueness
-- The business expects ContainerNumber to identify a physical
-- container.
-- Find ContainerNumbers that occur more than once.
-- Return:
--   ContainerNumber
--   Occurrences
-- ENGINEERING QUESTION:
-- Does a repeated ContainerNumber automatically mean that the data is wrong?

	/* No. A repeated ContainerNumber does not automatically means the data is wrong.
	We already have a unique ContainerID, so we need to understand the business rule 
	and what ContainerNumber means from operational perspective.*/

-- YOUR QUERY HERE:
SELECT 
	ContainerNumber,
	COUNT(*) AS Occurrences
FROM dbo.Container
GROUP BY ContainerNumber
HAVING COUNT(*)>1;

-- TASK 6: Vessel Call Integrity
-- A vessel cannot physically depart before it arrives.
-- Find VesselCall records where ATD < ATA.
-- Return:
--   CallID
--   VoyageNumber
--   ETA
--   ATA
--   ATD
--   CallStatus
-- ENGINEERING QUESTION:
-- What should happen to these records during a production load?
/**/
-- YOUR QUERY HERE:
SELECT CallID,
	VoyageNumber,
	ETA,
	ATA,
	ATD,
	CallStatus
FROM dbo.VesselCall
WHERE ATD < ATA;

-- TASK 7: Incomplete Vessel Calls
-- Identify vessel calls where ATA IS NULL.
-- Return:
--   CallID
--   VoyageNumber
--   ETA
--   ATA
--   ATD
--   CallStatus
-- ENGINEERING QUESTION:
-- Is NULL ATA necessarily a data-quality problem?
-- Explain.
	/*If ATA means Actual Time of Arrival, that means the vessel has not arrived yet, ATA being NULL is expected.
	Hence, a NULL ATA is not necessarily a data quality problem.*/

-- YOUR QUERY HERE:
SELECT CallID,
	VoyageNumber,
	ETA,
	ATA,
	ATD,
	CallStatus
FROM dbo.VesselCall
WHERE ATA IS NULL;

-- TASK 8: Container -> Movement Relationship
-- Every ContainerMovement should reference an existing
-- ContainerID.
-- Find movements that reference a ContainerID that does not
-- exist in dbo.Container.
-- Return:
--   MovementID
--   ContainerID
--   MovementType
--   MovementTime
-- ENGINEERING QUESTION:
-- What problem could this create after loading the data into
-- an analytical platform?
-- STUCK-POINT NOTE:
-- Where did you get stuck, or what would you need to learn?

-- YOUR QUERY HERE: