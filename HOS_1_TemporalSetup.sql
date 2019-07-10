USE TemporalHOS
GO
-- HeadsOfState already created? Gotta turn off SysVersioning before dropping it
-- ALTER TABLE dbo.HeadsOfState SET (SYSTEM_VERSIONING = OFF)
GO
DROP TABLE IF EXISTS HeadsOfState
DROP TABLE IF EXISTS HeadsOfStateHistory
GO

CREATE TABLE HeadsOfState(
	RowID INT IDENTITY (1,1) PRIMARY KEY,
	UK VARCHAR(100),
	AUS VARCHAR(100),
	US VARCHAR(100),
	FromDateTime datetime2 GENERATED ALWAYS AS ROW START NOT NULL, 
	ToDateTime datetime2 GENERATED ALWAYS AS ROW END NOT NULL, 
	PERIOD FOR SYSTEM_TIME (FromDateTime,ToDateTime) 
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.HeadsOfStateHistory) )
GO

-- they should be empty but exist
SELECT * FROM dbo.HeadsOfState 
SELECT * FROM dbo.HeadsOfStateHistory
GO

-- Inject history into table
ALTER TABLE dbo.HeadsOfState SET (SYSTEM_VERSIONING = OFF)
GO
INSERT INTO dbo.HeadsOfStateHistory
(
    RowID,
    UK,
    AUS,
    US,
    FromDateTime,
    ToDateTime
)
SELECT * FROM dbo.HeadsOfStateData WHERE ToDateTime < GETDATE()
GO
-- INSERT CURRENT ROW
INSERT INTO dbo.HeadsOfState
(   UK,
    AUS,
    US
)
SELECT UK,AUS,US FROM dbo.HeadsOfStateData WHERE ToDateTime > GETDATE()
GO

-- Need to drop Period so we can mess with the FromDateTime 
ALTER TABLE dbo.HeadsOfState DROP PERIOD FOR SYSTEM_TIME
GO
UPDATE HeadsOfState
SET    FromDateTime = (SELECT MAX(FromDateTime) FROM HeadsOfStateData)
GO
-- PUT BACK PERIOD
ALTER TABLE dbo.HeadsOfState ADD PERIOD FOR SYSTEM_TIME (FromDateTime,ToDateTime) 
GO

-- TURN EVERYTHING BACK ON
ALTER TABLE dbo.HeadsOfState SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.HeadsOfStateHistory))
GO


SELECT * FROM dbo.HeadsOfState 
SELECT * FROM dbo.HeadsOfStateHistory