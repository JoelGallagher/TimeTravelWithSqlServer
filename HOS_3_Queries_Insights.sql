/*****************************************
	QUERIES
*****************************************/

-- Show current heads of state (Only Main)
SELECT * 
FROM HeadsOfState 

-- Show Previous heads of state (Only history)
SELECT * 
FROM HeadsOfStateHistory

-- Update US 
-- UPDATE HeadsOfState SET US = 'Mike Pence'
	

-- ALL : Show History of Heads Of State (Union of Main & History)
SELECT * 
FROM HeadsOfState 
FOR SYSTEM_TIME ALL
ORDER BY FromDateTime ASC 

-- AS OF : Show Heads of State on given date
DECLARE @year	INT = 1919,
		@month	INT = 09,
		@day	INT = 03
DECLARE @dt DATETIME2 = DATEFROMPARTS(@year,@month,@day)

SELECT * 
FROM HeadsOfState 
FOR SYSTEM_TIME AS OF @dt

-- FROM : Data active at any point in window
SELECT *
FROM HeadsOfState	
FOR SYSTEM_TIME	FROM '1930-01-01' TO '1939-12-31'

-- BETWEEN : Data active at any point in window INCLUDING started on enddate
SELECT *
FROM HeadsOfState	
FOR SYSTEM_TIME	BETWEEN '1930-01-01' AND '1940-05-10 00:00:00.0000000'  
--FOR SYSTEM_TIME	FROM '1930-01-01' TO '1940-05-10 00:00:00.0000000'  

-- CONTAINED IN : Data that started & finished inside daterange
SELECT * 
FROM HeadsOfState
--FOR SYSTEM_TIME FROM '1940-1-1' TO '1950-1-1' 
FOR SYSTEM_TIME CONTAINED IN ('1940-1-1','1950-1-1') 






/*****************************************
	INSIGHTS
*****************************************/

SELECT * FROM vwHosTerms ORDER BY fromdatetime


-- Find Longest serving HOS
SELECT	HOS, Nation, SUM(DaysInOffice) AS TotalDaysInOffice, SUM(DaysInOffice) / 365.25 AS 'Years In Office'
FROM	vwhosTerms 
GROUP BY HOS, Nation
ORDER BY TotalDaysInOffice DESC

-- Find Average term length, by Nation
SELECT	Nation, 
		AVG(DaysInOffice) AS 'AverageDaysInOffice' 
FROM	vwhosTerms 
GROUP BY Nation
ORDER BY AverageDaysInOffice DESC

-- Non-contiguous terms
SELECT HOS, Nation, COUNT(HOS) AS TermCount
FROM vwhosTerms	
GROUP BY HOS, Nation
HAVING Count(HOS) > 1 
ORDER BY TermCount DESC
