USE airbnb;
GO


-- 1. Check Total Rows
SELECT COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData;

-- 2. Check Rows per City and Day Type
SELECT City, DayType, COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
GROUP BY City, DayType
ORDER BY City, DayType;
GO

-- We have 51707 rows in total
-- The data contains 10 cities, each with weekday and weekend records


-- 3. Check Missing Values
SELECT
    SUM(CASE WHEN realSum IS NULL OR realSum = '' THEN 1 ELSE 0 END) AS MissingPrice,
    SUM(CASE WHEN room_type IS NULL OR room_type = '' THEN 1 ELSE 0 END) AS MissingRoomType,
    SUM(CASE WHEN person_capacity IS NULL OR person_capacity = '' THEN 1 ELSE 0 END) AS MissingCapacity,
    SUM(CASE WHEN cleanliness_rating IS NULL OR cleanliness_rating = '' THEN 1 ELSE 0 END) AS MissingCleanliness,
    SUM(CASE WHEN guest_satisfaction_overall IS NULL OR guest_satisfaction_overall = '' THEN 1 ELSE 0 END) AS MissingSatisfaction,
    SUM(CASE WHEN City IS NULL OR City = '' THEN 1 ELSE 0 END) AS MissingCity,
    SUM(CASE WHEN DayType IS NULL OR DayType = '' THEN 1 ELSE 0 END) AS MissingDayType
FROM Bronze.AirbnbRawData;

--no missing values were found in the checked columns
--silver: no action


-- 4. Check Numeric Data Types
SELECT *
FROM Bronze.AirbnbRawData
WHERE TRY_CAST(realSum AS FLOAT) IS NULL
   OR TRY_CAST(person_capacity AS FLOAT) IS NULL
   OR TRY_CAST(cleanliness_rating AS FLOAT) IS NULL
   OR TRY_CAST(guest_satisfaction_overall AS FLOAT) IS NULL
   OR TRY_CAST(bedrooms AS FLOAT) IS NULL
   OR TRY_CAST(dist AS FLOAT) IS NULL
   OR TRY_CAST(metro_dist AS FLOAT) IS NULL
   OR TRY_CAST(attr_index AS FLOAT) IS NULL
   OR TRY_CAST(attr_index_norm AS FLOAT) IS NULL
   OR TRY_CAST(rest_index AS FLOAT) IS NULL
   OR TRY_CAST(rest_index_norm AS FLOAT) IS NULL;

--checked whether the numeric columns can be converted to float
--no rows were returned so all checked values can be converted
--silver: convert these columns to numeric data types (real_sum -> DECIMAL(10,2)   dist & metro_dist -> DECIMAL(10,4)  indexes -> DECIMAL(10,4)  bedrooms -> INT)

-- 5. Check Decimal Values in Person Capacity
SELECT COUNT(*) AS HasDecimalPart
FROM Bronze.AirbnbRawData
WHERE TRY_CAST(person_capacity AS FLOAT)
      != FLOOR(TRY_CAST(person_capacity AS FLOAT));

--  checked whether person_capacity contains decimal values
-- HasDecimalPart = 0 -> all values are whole numbers
--silver: convert person_capacity to INT


-- 6. Check Numeric Value Ranges
SELECT *
FROM Bronze.AirbnbRawData
WHERE TRY_CAST(realSum AS FLOAT) < 0
   OR TRY_CAST(bedrooms AS FLOAT) < 0
   OR TRY_CAST(dist AS FLOAT) < 0
   OR TRY_CAST(metro_dist AS FLOAT) < 0
   OR TRY_CAST(attr_index AS FLOAT) < 0
   OR TRY_CAST(attr_index_norm AS FLOAT) < 0
   OR TRY_CAST(rest_index AS FLOAT) < 0
   OR TRY_CAST(rest_index_norm AS FLOAT) < 0
   OR TRY_CAST(person_capacity AS FLOAT) <= 0
   OR TRY_CAST(cleanliness_rating AS FLOAT) NOT BETWEEN 0 AND 10
   OR TRY_CAST(guest_satisfaction_overall AS FLOAT) NOT BETWEEN 0 AND 100;

--checked for negative prices, bedroom counts and distances, negative values in attraction and restaurant indices, non-positive capacity, cleanliness ratings outside 0-10 and satisfaction scores outside 0-100
--no rows were returned -> no violation values
--silver: no action


-- 7.Check Zero Bedrooms
SELECT
    room_type,
    COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
WHERE TRY_CAST(bedrooms AS FLOAT) = 0
GROUP BY room_type
ORDER BY TotalRows DESC;

-- checked how many listings have zero bedrooms
-- 4485 rows in total: Entire home/apt 4026 and Private room 459
-- zero bedrooms may indicate studio listings, not treated as missing or invalid
-- silver: keep these rows and add an is_studio flag (1 when bedrooms = 0)


-- 8. Check Categorical Values
SELECT room_type, COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
GROUP BY room_type
ORDER BY TotalRows DESC;

SELECT host_is_superhost, COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
GROUP BY host_is_superhost;

-- checked the available room types and superhost values
-- room_type: Entire home/apt, Private room, Shared room
-- host_is_superhost: True and False
-- silver: convert host_is_superhost to BIT


-- 9. Check whether RowIndex repeats within the same City and DayType
SELECT City, DayType, RowIndex, COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
GROUP BY City, DayType, RowIndex
HAVING COUNT(*) > 1;

-- checked whether RowIndex repeats within the same City and DayType
-- no duplicates were found
-- silver: no duplicate handling needed


-- 9. Check Duplicates
SELECT
    City, DayType, realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall, bedrooms,
    dist, metro_dist, attr_index, attr_index_norm,
    rest_index, rest_index_norm, lng, lat,
    COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
GROUP BY
    City, DayType, realSum, room_type, room_shared, room_private,
    person_capacity, host_is_superhost, multi, biz,
    cleanliness_rating, guest_satisfaction_overall, bedrooms,
    dist, metro_dist, attr_index, attr_index_norm,
    rest_index, rest_index_norm, lng, lat
HAVING COUNT(*) > 1;

-- checked whether any listing appears twice with identical values in all other columns
-- no duplicates were found
--silver:no duplicate handling is needed


-- 10. Check Room Type and Room Flags
SELECT room_type, room_shared, room_private, COUNT(*) AS total_rows
FROM Bronze.AirbnbRawData
GROUP BY room_type, room_shared, room_private;

-- checked whether room_shared and room_private match room_type
--no inconsistent combinations
-- silver: no cleaning needed, only convert the flags from text to BIT


-- 11. Check City and Source File
SELECT City, COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
GROUP BY City
ORDER BY City;

SELECT City, DayType, SourceFile
FROM Bronze.AirbnbRawData
WHERE LOWER(SourceFile) !=
      LOWER(City + '_' + DayType + '.csv');

-- checked the city names and whether SourceFile matches City and DayType
-- 10 cities found -> all lowercase
-- no mismatched rows were found
-- silver: no action


-- 12. Check Multi and Biz Values
SELECT 'multi' AS ColumnName, multi AS Value, COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
GROUP BY multi

SELECT 'biz' AS ColumnName, biz AS Value, COUNT(*) AS TotalRows
FROM Bronze.AirbnbRawData
GROUP BY biz;

-- checked whether multi and biz contain only 0 and 1
-- both columns contain only 0 and 1
-- silver: convert both to BIT


-- 13. Check Latitude and Longitude
SELECT *
FROM Bronze.AirbnbRawData
WHERE TRY_CAST(lat AS FLOAT) IS NULL
   OR TRY_CAST(lng AS FLOAT) IS NULL
   OR TRY_CAST(lat AS FLOAT) NOT BETWEEN -90 AND 90
   OR TRY_CAST(lng AS FLOAT) NOT BETWEEN -180 AND 180;

--checked whether lat and lng can be converted to numbers and whether the coordinates are within valid geographic ranges(lat between -90, 90 & lng between -180, 180)
-- all latitude and longitude values are numeric and within valid geographic ranges
-- silver: convert lat and lng to DECIMAL(9,6)


-- 14. Check Price Outliers
SELECT COUNT(*) AS HighPriceRows
FROM Bronze.AirbnbRawData
WHERE TRY_CAST(realSum AS FLOAT) > 5000;

SELECT City, realSum, room_type, person_capacity, bedrooms
FROM Bronze.AirbnbRawData
WHERE TRY_CAST(realSum AS FLOAT) > 5000
ORDER BY TRY_CAST(realSum AS FLOAT) DESC;

-- 26 listings have prices above 5000
-- silver: Keep rows, add is_price_outlier flag





-- silver: rename columns to snake_case (realSum -> real_sum, RowIndex -> source_row_index, City -> city, DayType -> day_type, SourceFile -> source_file)
