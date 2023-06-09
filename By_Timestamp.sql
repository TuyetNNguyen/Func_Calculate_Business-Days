CREATE TEMPORARY CONSTANT DATE_STR_FORMAT = "%a %d %b %Y";
CREATE TEMPORARY CONSTANT TIMEZONE = "America/Chicago";

CREATE TEMP FUNCTION COUNT_WEEKDAYS(
  start_timestamp TIMESTAMP,
  end_timestamp TIMESTAMP,
  timezone STRING
) RETURNS INT64 AS (
GREATEST(0, (
  SELECT COUNT(date), - 1
  FROM UNNEST(
    GENERATE_DATE_ARRAY(
      DATE(start_timestamp, timezone),
      DATE(end_timestamp, timezone)
    )
  ) AS date
  #1 = SUN, 7 = SAT
  WHERE EXTRACT(DATEOFWEEK FROM date) NOT IN (1, 7)
  ))
);

WITH dates_tables AS (
  SELECT "Wed 08 Mar 2023" AS start_date, "Wed 08 Mar 2023" AS end_date, '0 days' AS expected_result
  UNION ALL SELECT "Wed 08 Mar 2023", "Thu 09 Mar 2023", '1 days'
  UNION ALL SELECT "Wed 08 Mar 2023", "FRI 10 Mar 2023", '2 days'
  UNION ALL SELECT "Wed 08 Mar 2023", "SAT 11 Mar 2023", '2 days'
  UNION ALL SELECT "Wed 08 Mar 2023", "SUN 12 Mar 2023", '2 days'
  UNION ALL SELECT "Wed 08 Mar 2023", "MON 12 Mar 2023", '3 days'
  UNION ALL SELECT "Wed 08 Mar 2023", "TUE 12 Mar 2023", '4 days'
  UNION ALL SELECT "Wed 08 Mar 2023", "WED 12 Mar 2023", '5 days'
)

SELECT 
  start_date,
  end_date,
  COUNT_WEEKDAYS(PARSE_TIMESTAMP(DATE_STR_FORMAT, start_date), PARSE_TIMESTAMP(DATE_STR_FORMAT, end_date), TIMEZONE) AS num_week_days,
  expected_result
FROM
  dates_table
