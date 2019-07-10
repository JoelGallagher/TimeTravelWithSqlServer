# TimeTravelWithSqlServer

## Heads Of State

1. Import data from HeadsOfStateData.csv into table "HeadsOfStateData". First row contains column names

2. Run "HOS_1_TemporalSetup.sql" to seed & setup Temporal history. Creates a table HeadsOfState with linked HeadsOfStateHistory table

3. Run "HOS_2_vwHosTerms.sql" to create the view for use in Insights

4. Can now execute queries contained in "HOS_3_Queries_Insights.sql"

## Travel 

1. Using example from HeadsOfState, create a Travel table & populate the TravelHistory with your own travel data. 
Travel table structure : 

~~~~
CREATE TABLE [dbo].[Travel](
	[RowID] [int] IDENTITY(1,1) PRIMARY KEY NOT NULL,
	[Country] [varchar](100) NULL,
	[FromDateTime] [datetime2](7) GENERATED ALWAYS AS ROW START NOT NULL,
	[ToDateTime] [datetime2](7) GENERATED ALWAYS AS ROW END NOT NULL,
	PERIOD FOR SYSTEM_TIME ([FromDateTime], [ToDateTime])
)
WITH(SYSTEM_VERSIONING = ON ( HISTORY_TABLE = [dbo].[TravelHistory]))
~~~~

2. Can now execute queries contained in "Travel_Insights.sql"