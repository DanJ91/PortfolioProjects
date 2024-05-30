/* 
1. Define the variables
2. Create a CTE that round the average views per video
3. Select appropriate columns for analysis
4. Filter the results by the Youtube channels with he highest subscriber bases
5. Order by net profit DESC
*/

USE youtube_db;


-- 1. 
SET @conversion_rate = 0.02; 	-- The conversion rate @ 2%
SET @product_cost = 5.0; 		-- Product cost @ $5
SET @campaign_cost = 50000; 	-- Campaign cost @ $50000

-- 2.

WITH channel_data AS (
    SELECT 
		channel_name,
		total_subscribers,
		total_views,
		total_videos,
        ROUND((total_views / total_videos) / 10000,0) * 10000 AS rounded_avg_views_per_video
FROM 
    youtube_db.view_uk_youtubers_2024
)


-- 3.
SELECT 
	channel_name,
    rounded_avg_views_per_video,
    ROUND(rounded_avg_views_per_video * @conversion_rate,0) AS potential_units_sold_per_video,
    ROUND(rounded_avg_views_per_video * @conversion_rate * @product_cost,0) AS potential_revenue_per_video,
    ROUND(rounded_avg_views_per_video * @conversion_rate * @product_cost) - @campaign_cost AS net_profit
FROM channel_data
-- 4. Filter by top 3 youtube channels
WHERE
	channel_name IN ('NoCopyrightSounds ', 'DanTDM ', 'Dan Rhodes ')
ORDER BY 
	net_profit DESC

