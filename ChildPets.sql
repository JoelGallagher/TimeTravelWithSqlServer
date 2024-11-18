/*
SIMPLE STANDARD

CREATE TABLE ChildPets(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	ChildName NVARCHAR(100),
	PetName NVARCHAR(100))
*/


-- already created? Gotta turn off SysVersioning before dropping it
-- ALTER TABLE dbo.ChildPets SET (SYSTEM_VERSIONING = OFF)
	DROP TABLE IF EXISTS ChildPets
	DROP TABLE IF EXISTS ChildPets_History

GO


CREATE TABLE ChildPets(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	ChildName NVARCHAR(100),
	PetName NVARCHAR(100),
	FromDateTime	datetime2 GENERATED ALWAYS AS ROW START NOT NULL ,
	ToDateTime		datetime2 GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME (FromDateTime, ToDateTime)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ChildPets_History))


-- SEE ALL PET HISTORY
SELECT * FROM ChildPets
FOR SYSTEM_TIME ALL
ORDER BY FromDateTime ASC

SELECT * FROM ChildPets
SELECT * FROM ChildPets_History

-- ADD | DROP hidden Period columns 

ALTER TABLE ChildPets
ALTER COLUMN FromDateTime ADD HIDDEN;
ALTER TABLE ChildPets
ALTER COLUMN ToDateTime ADD HIDDEN;
 