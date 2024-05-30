/*
# Data Cleaning Steps

1. Remove unnecessary columns by only selecting ones we need
2. Extract the Yuotube channel names from the 1st column
3. Rename the columns

*/

CREATE DATABASE youtube_db;

USE youtube_db; 

SELECT * FROM top_uk_youtubers_2024;

SELECT 
    nombre, total_subscribers, total_views, total_videos
FROM
    top_uk_youtubers_2024;
    
-- INSTR function MySQL to get the index position of character
-- Shows us the position of @ in the nombre column
SELECT INSTR(NOMBRE, '@'), NOMBRE FROM top_uk_youtubers_2024;

-- Find just the names of the channel (before the @ sumbol)
SELECT 
	CAST(SUBSTR(NOMBRE, 1, INSTR(NOMBRE, '@')-1) AS CHAR) AS channel_name,
    total_subscribers,
    total_views, 
    total_videos
FROM 
	top_uk_youtubers_2024;


-- Create a view to use later in PowerBI
CREATE VIEW view_uk_youtubers_2024 AS
(
SELECT 
	CAST(SUBSTR(NOMBRE, 1, INSTR(NOMBRE, '@')-1) AS CHAR) AS channel_name,
    total_subscribers,
    total_views, 
    total_videos
FROM 
	top_uk_youtubers_2024
);

/*

# Data Quality Tests

1. The data needs to be 100 records of Youtube channels (row count test) --- (Passed)
2. The data needs 4 correct fields (column count test) --- (Passed)
3. The data name column must be string format, and the other columns must be suitable numerical types (data type check) --- (Passed)
4. Each record must be unique in the dataset. Check for duplicates (duplicate count check) --- (Passed)

Requirements:
	Row count - 100 
	Column Count - 4
	Data types:
		Channel name = text
        total_subscribers = INTEGER
        total_views = BIG INTEGER
		total_videos = INTEGER
	Duplicate count = 0

*/

-- 1. Row count check 

SELECT 
	COUNT(*) 
FROM 
	view_uk_youtubers_2024 AS no_of_rows;

-- 2. Column count check 

SELECT 
	COUNT(*) AS column_count 
FROM 
	INFORMATION_SCHEMA.COLUMNS 
WHERE 
	TABLE_NAME = 'view_uk_youtubers_2024';

-- 3. Data type check table

SELECT 
	column_name,
    data_type
FROM 
	INFORMATION_SCHEMA.COLUMNS 
WHERE 
	TABLE_NAME = 'view_uk_youtubers_2024';
    
-- 4. Check for duplicates

SELECT 
	channel_name,
	COUNT(*) AS duplicate_count
FROM 
	view_uk_youtubers_2024
GROUP BY
	channel_name
HAVING 
	duplicate_count > 1;
    
SELECT * FROM view_uk_youtubers_2024;

