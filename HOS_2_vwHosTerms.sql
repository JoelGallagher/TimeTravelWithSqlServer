USE TemporalHOS
GO


DROP VIEW IF EXISTS vwHosTerms_UK
GO
CREATE VIEW vwHosTerms_UK AS 
 
	WITH cteUK AS (
		SELECT 'UK' AS Nation, UK AS 'HOS', FromDateTime,  ToDateTime
		FROM HeadsOfState 
		FOR SYSTEM_TIME ALL
	) 
	,cteHOSWithDaysTillNextStart AS(
	SELECT 
		ROW_NUMBER() OVER(ORDER BY HOS) AS RN_HOS,
		HOS, FromDateTime,  ToDateTime,
		DATEDIFF(dd,TODATETIME , LEAD(FromDateTime) OVER (PARTITION BY HOS ORDER BY FROMDATETIME)) AS DaysTillNextStart,
		DATEDIFF(dd,FROMDATETIME,LAG(ToDateTime)OVER  (PARTITION BY HOS ORDER BY FROMDATETIME)) AS DaysSinceLast
	FROM cteUK	
	),
	cteStartingDates AS -- Term Start Dates (dsLast = null OR < 0)
	(
		SELECT ROW_NUMBER()OVER(PARTITION BY HOS ORDER BY FromDateTime) AS RN,
			HOS, FromDateTime, ToDateTime
		FROM cteHOSWithDaysTillNextStart 
		WHERE (DaysSinceLast IS NULL OR DaysSinceLast < 0)
	),
	cteEndingDates AS -- Term End Dates  (Next = null OR > 0)
	(
		SELECT ROW_NUMBER()OVER(PARTITION BY HOS ORDER BY FromDateTime) AS RN,
			HOS, FromDateTime, ToDateTime
		FROM cteHOSWithDaysTillNextStart 
		WHERE (DaysTillNextStart IS NULL OR DaysTillNextStart > 0)
	),
	cteFinal AS (
		SELECT s.HOS, s.FromDateTime, e.ToDateTime 
		FROM cteStartingDates s
			INNER JOIN cteEndingDates e
				ON e.HOS = s.HOS
				AND e.RN = s.RN
	)
	-- Return View
	select 'UK' AS Nation,* from cteFinal
	 
GO

--------- AUS
DROP VIEW IF EXISTS vwHosTerms_AUS
GO
CREATE VIEW vwHosTerms_AUS AS 
 
	WITH cteAUS AS (
		SELECT AUS AS 'HOS', FromDateTime,  ToDateTime
		FROM HeadsOfState 
		FOR SYSTEM_TIME ALL
	) 
	,cteHOSWithDaysTillNextStart AS(
	SELECT 
		ROW_NUMBER() OVER(ORDER BY HOS) AS RN_HOS,
		HOS, FromDateTime,  ToDateTime,
		DATEDIFF(dd,TODATETIME , LEAD(FromDateTime) OVER (PARTITION BY HOS ORDER BY FROMDATETIME)) AS DaysTillNextStart,
		DATEDIFF(dd,FROMDATETIME,LAG(ToDateTime)OVER  (PARTITION BY HOS ORDER BY FROMDATETIME)) AS DaysSinceLast
	FROM cteAus	
	),
	cteStartingDates AS -- Term Start Dates (dsLast = null OR < 0)
	(
		SELECT ROW_NUMBER()OVER(PARTITION BY HOS ORDER BY FromDateTime) AS RN,
			HOS, FromDateTime, ToDateTime
		FROM cteHOSWithDaysTillNextStart 
		WHERE (DaysSinceLast IS NULL OR DaysSinceLast < 0)
	),
	cteEndingDates AS -- Term End Dates  (Next = null OR > 0)
	(
		SELECT ROW_NUMBER()OVER(PARTITION BY HOS ORDER BY FromDateTime) AS RN,
			HOS, FromDateTime, ToDateTime
		FROM cteHOSWithDaysTillNextStart 
		WHERE (DaysTillNextStart IS NULL OR DaysTillNextStart > 0)
	),
	cteFinal AS (
		SELECT s.HOS, s.FromDateTime, e.ToDateTime 
		FROM cteStartingDates s
			INNER JOIN cteEndingDates e
				ON e.HOS = s.HOS
				AND e.RN = s.RN
	)
	-- Return View
	select 'AUS' AS Nation,* from cteFinal
	 
GO


--------- US
DROP VIEW IF EXISTS vwHosTerms_US
GO
CREATE VIEW vwHosTerms_US AS 
 
	WITH cte AS (
		SELECT US AS 'HOS', FromDateTime,  ToDateTime
		FROM HeadsOfState 
		FOR SYSTEM_TIME ALL
	) 
	,cteHOSWithDaysTillNextStart AS(
	SELECT 
		ROW_NUMBER() OVER(ORDER BY HOS) AS RN_HOS,
		HOS, FromDateTime,  ToDateTime,
		DATEDIFF(dd,TODATETIME , LEAD(FromDateTime) OVER (PARTITION BY HOS ORDER BY FROMDATETIME)) AS DaysTillNextStart,
		DATEDIFF(dd,FROMDATETIME,LAG(ToDateTime)OVER  (PARTITION BY HOS ORDER BY FROMDATETIME)) AS DaysSinceLast
	FROM cte
	),
	cteStartingDates AS -- Term Start Dates (dsLast = null OR < 0)
	(
		SELECT ROW_NUMBER()OVER(PARTITION BY HOS ORDER BY FromDateTime) AS RN,
			HOS, FromDateTime, ToDateTime
		FROM cteHOSWithDaysTillNextStart 
		WHERE (DaysSinceLast IS NULL OR DaysSinceLast < 0)
	),
	cteEndingDates AS -- Term End Dates  (Next = null OR > 0)
	(
		SELECT ROW_NUMBER()OVER(PARTITION BY HOS ORDER BY FromDateTime) AS RN,
			HOS, FromDateTime, ToDateTime
		FROM cteHOSWithDaysTillNextStart 
		WHERE (DaysTillNextStart IS NULL OR DaysTillNextStart > 0)
	),
	cteFinal AS (
		SELECT s.HOS, s.FromDateTime, e.ToDateTime 
		FROM cteStartingDates s
			INNER JOIN cteEndingDates e
				ON e.HOS = s.HOS
				AND e.RN = s.RN
	)
	-- Return View
	select 'US' AS Nation,* from cteFinal
	 
GO

-- Final View
DROP VIEW IF EXISTS vwHosTerms
GO
CREATE VIEW vwHosTerms AS 
	with cteFinal AS (
	select *,DATEDIFF(dd,FromDateTime, CASE WHEN ToDateTime> GETDATE() THEN GETDATE() ELSE ToDateTime END) AS DaysInOffice
	from vwHosTerms_UK 
	UNION
	select *,DATEDIFF(dd,FromDateTime, CASE WHEN ToDateTime> GETDATE() THEN GETDATE() ELSE ToDateTime END) 
	from vwHosTerms_Aus
	UNION
	select *,DATEDIFF(dd,FromDateTime, CASE WHEN ToDateTime> GETDATE() THEN GETDATE() ELSE ToDateTime END) 
	from vwHosTerms_Us 
	)
	SELECT * FROM cteFinal
GO

SELECT * FROM vwHosTerms  Order by FromDateTime