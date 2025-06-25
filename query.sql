-- Step 1: Extract Grubhub hours
WITH grubhub_hours AS (
  SELECT 
    JSON_EXTRACT_SCALAR(response, '$.slug') AS gh_slug,
    JSON_EXTRACT(response, '$.openHours') AS gh_open_hours
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours`
),

-- Step 2: Extract UberEats hours
ubereats_hours AS (
  SELECT
    JSON_EXTRACT_SCALAR(response, '$[0].key') AS ue_slug,
    JSON_EXTRACT_SCALAR(response, '$[0].sections[0].regularHours[0]') AS ue_start_time,
    JSON_EXTRACT_SCALAR(response, '$[0].sections[0].regularHours[1]') AS ue_end_time
  FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours`
),

-- Step 3: Join and prepare comparison fields
hours_joined AS (
  SELECT
    gh_slug,
    gh_open_hours,
    ue_slug,
    ue_start_time,
    ue_end_time,
    JSON_EXTRACT_SCALAR(gh_open_hours, '$[1]') AS gh_start_time
  FROM grubhub_hours
  JOIN ubereats_hours 
    ON JSON_EXTRACT_SCALAR(gh_open_hours, '$[0]') = ue_slug
)

-- Step 4: Final result with timestamp comparison
SELECT
  gh_slug,
  JSON_EXTRACT_SCALAR(gh_open_hours, '$[0]') AS gh_open_hours_string,
  ue_slug,  
  ue_start_time,
  ue_end_time,
  gh_start_time,
  CASE
    WHEN SAFE.PARSE_TIMESTAMP('%I:%M %p', gh_start_time) 
         BETWEEN SAFE.PARSE_TIMESTAMP('%I:%M %p', ue_start_time)
             AND SAFE.PARSE_TIMESTAMP('%I:%M %p', ue_end_time) THEN "In Range"
    WHEN ABS(TIMESTAMP_DIFF(
              SAFE.PARSE_TIMESTAMP('%I:%M %p', gh_start_time), 
              SAFE.PARSE_TIMESTAMP('%I:%M %p', ue_start_time), MINUTE)) < 5 
         THEN "Out of Range with 5 mins difference"
    ELSE "Out of Range"
  END AS is_out_of_range
FROM hours_joined;
