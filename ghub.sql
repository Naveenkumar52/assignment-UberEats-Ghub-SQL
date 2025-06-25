SELECT * FROM arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours LIMIT 10;
SELECT * FROM arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours LIMIT 10;

-- Define the UDF
CREATE TEMP FUNCTION jsonObjectKeys(input STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  return Object.keys(JSON.parse(input));
""";

-- Use TO_JSON_STRING to convert JSON to STRING before parsing
WITH json_keys AS (
  SELECT
    jsonObjectKeys(TO_JSON_STRING(response)) AS key_array
  FROM
    `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`
  WHERE response IS NOT NULL
)

-- Extract and list unique keys
SELECT DISTINCT key
FROM json_keys,
UNNEST(key_array) AS key
ORDER BY key;


WITH schedule_rules AS (
  SELECT 
    JSON_EXTRACT_SCALAR(rule, '$.days_of_week[0]') AS day,
    JSON_EXTRACT_SCALAR(rule, '$.from') AS open_time,    
    JSON_EXTRACT_SCALAR(rule, '$.to') AS close_time
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`,
  UNNEST(JSON_EXTRACT_ARRAY(response, '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules')) AS rule
)

SELECT 
  day, 
  open_time,
  close_time
FROM schedule_rules;

-- Extracting business hours from the response field
WITH schedule_rules AS (
  SELECT 
    JSON_EXTRACT_SCALAR(rule, '$.days_of_week[0]') AS day,
    JSON_EXTRACT_SCALAR(rule, '$.from') AS open_time,    
    JSON_EXTRACT_SCALAR(rule, '$.to') AS close_time
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`,
  UNNEST(JSON_EXTRACT_ARRAY(response, '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules')) AS rule
)

SELECT 
  day, 
  open_time,
  close_time
FROM schedule_rules;


-- Using function
CREATE TEMP FUNCTION ExtractHours(json STRING)
RETURNS ARRAY<STRING>
LANGUAGE js AS """
  const obj = JSON.parse(json);  // ✅ parse JSON string
  const rules = obj.availability_by_catalog?.STANDARD_DELIVERY?.schedule_rules || [];
  
  return rules.map(rule => {
    const day = rule.days_of_week?.[0] || '';
    const from = rule.from || '';
    const to = rule.to || '';
    return day + ':' + from + '-' + to;
  });
""";

-- Use TO_JSON_STRING if 'response' is of JSON type
SELECT
  TO_JSON_STRING(response) AS response_str,
  ExtractHours(TO_JSON_STRING(response)) AS hours 
FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`
WHERE response IS NOT NULL;

-- nested JSON extract
SELECT 
  vb_name,
  JSON_EXTRACT(response, '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules') as sch
FROM 
  `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours` LIMIT 10;


-- Prefinal Query to extract JSON data.

WITH schedule_rules AS (

  SELECT 
    vb_name,
    JSON_EXTRACT_SCALAR(value, '$.from') AS open_time,    
    JSON_EXTRACT_SCALAR(value, '$.to') AS close_time  
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`,
   UNNEST(JSON_QUERY_ARRAY(response, 
     '$.availability_by_catalog.STANDARD_DELIVERY.schedule_rules')) AS value
)

SELECT * 
FROM schedule_rules
