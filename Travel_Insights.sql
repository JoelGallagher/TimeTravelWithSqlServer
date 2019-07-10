USE	 TemporalTravel
GO

-- see data
select * from travel for SYSTEM_TIME ALL ORDER BY FromDateTime

--  Countries w/ Day Duration
;WITH cteCountryDayCount AS (
	SELECT	Country, 
		SUM(DateDiff(dd, 
				FromDateTime, 
				(IIF (ToDateTime > GETDATE(),GETDATE() ,ToDateTime))  
				)) AS DaysDuration
	FROM Travel
	FOR SYSTEM_TIME ALL
	GROUP BY Country
)
SELECT * 
FROM cteCountryDayCount
WHERE Country <> 'AUSTRALIA'
ORDER BY DaysDuration DESC

-- Travel by year 
DECLARE @startYear INT=(SELECT YEAR(MIN(FromDateTime)) FROM Travel	FOR SYSTEM_TIME ALL)
DECLARE @endYear INT=(SELECT YEAR(MAX(FromDateTime)) FROM Travel 	FOR SYSTEM_TIME ALL);
WITH cteEmpty AS (
    SELECT @startYear AS [year],0 as c
    UNION ALL
    SELECT [year]+1,0 FROM cteEmpty WHERE [year]+1<=@endYear
),
CteTravel AS (
	SELECT YEAR(FromDateTime) AS [Year], COUNT(*) AS TravelCount
	FROM Travel
	FOR SYSTEM_TIME ALL
	GROUP BY YEAR(FromDateTime)
),
cteCombined as (
	SELECT * FROM cteEmpty 
	UNION 
	select * from CteTravel
)
select Year, sum(c) AS BorderCrossings
from cteCombined
group by [Year]
 
  