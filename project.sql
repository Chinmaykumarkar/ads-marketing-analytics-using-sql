use ads_data;
select * from ads_data.`data (3)`; 
select * from ads_data.googleads_dataanalytics_sales_uncleaned;
ALTER TABLE ads_data.`data (3)`
ADD COLUMN campaign_name VARCHAR(255);
SET SQL_SAFE_UPDATES = 0;
UPDATE ads_data.`data (3)`
SET campaign_name = 'Meta_Campaign';
update ads_data.googleads_dataanalytics_sales_uncleaned
set Campaign_name = 'Google_campaign';

-- Standardize and union data
CREATE OR REPLACE VIEW unified_campaign_data AS
SELECT campaign_name,'Google_campaign' AS platform,clicks, cost,impressions,Conversions
FROM ads_data.googleads_dataanalytics_sales_uncleaned
UNION ALL
SELECT campaign_name,'Meta_campaign' AS platform,clicks, spent as cost,impressions,total_conversion
FROM ads_data.`data (3)`;

select * from unified_campaign_data;

SELECT
  campaign_name,
  platform,
  SUM(impressions) AS total_impressions,
  SUM(clicks) AS total_clicks,
  ROUND(SUM(clicks)*100.0 / NULLIF(SUM(impressions), 0), 2) AS ctr,
  SUM(conversions) AS total_conversions,
  SUM(cost) AS total_spend,
  ROUND(SUM(cost) / NULLIF(SUM(conversions), 0), 2) AS cost_per_conversion
FROM unified_campaign_data
GROUP BY campaign_name, platform;


