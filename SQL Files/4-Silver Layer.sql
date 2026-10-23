USE airbnb;
GO

-- 1. Create Silver Table

SELECT
    TRY_CAST(RowIndex AS INT) AS source_row_index,

    TRY_CAST(realSum AS DECIMAL(10,2)) AS real_sum,

    NULLIF(LTRIM(RTRIM(room_type)), '') AS room_type,

	CAST(CASE
			WHEN LOWER(LTRIM(RTRIM(room_shared))) = 'true' THEN 1
			WHEN LOWER(LTRIM(RTRIM(room_shared))) = 'false' THEN 0
	END AS BIT) AS room_shared,

    CAST(CASE
			WHEN LOWER(LTRIM(RTRIM(room_private))) = 'true' THEN 1
			WHEN LOWER(LTRIM(RTRIM(room_private))) = 'false' THEN 0
	END AS BIT) AS room_private,

    CAST(TRY_CAST(person_capacity AS FLOAT) AS INT) AS person_capacity,

    CAST(CASE
			WHEN LOWER(LTRIM(RTRIM(host_is_superhost))) = 'true' THEN 1
			WHEN LOWER(LTRIM(RTRIM(host_is_superhost))) = 'false' THEN 0
	END AS BIT) AS host_is_superhost,

    TRY_CAST(multi AS BIT) AS multi,
    TRY_CAST(biz AS BIT) AS biz,

    TRY_CAST(cleanliness_rating AS DECIMAL(4,1))
        AS cleanliness_rating,

    TRY_CAST(guest_satisfaction_overall AS DECIMAL(5,2))
        AS guest_satisfaction_overall,

    TRY_CAST(bedrooms AS INT) AS bedrooms,

    TRY_CAST(dist AS DECIMAL(10,4)) AS dist,
    TRY_CAST(metro_dist AS DECIMAL(10,4)) AS metro_dist,

    TRY_CAST(attr_index AS DECIMAL(10,4)) AS attr_index,
    TRY_CAST(attr_index_norm AS DECIMAL(10,4)) AS attr_index_norm,

    TRY_CAST(rest_index AS DECIMAL(10,4)) AS rest_index,
    TRY_CAST(rest_index_norm AS DECIMAL(10,4)) AS rest_index_norm,

    TRY_CAST(TRY_CAST(lng AS FLOAT) AS DECIMAL(9,6)) AS lng,
    TRY_CAST(TRY_CAST(lat AS FLOAT) AS DECIMAL(9,6)) AS lat,

    UPPER(LEFT(LTRIM(RTRIM(City)), 1))
		+ LOWER(SUBSTRING(LTRIM(RTRIM(City)), 2, LEN(LTRIM(RTRIM(City)))))
		AS city,

    NULLIF(LTRIM(RTRIM(DayType)), '') AS day_type,
	NULLIF(LTRIM(RTRIM(SourceFile)), '') AS source_file,

    CAST(CASE
			WHEN TRY_CAST(bedrooms AS INT) = 0 THEN 1
			ELSE 0
    END AS BIT) AS is_studio,

    CAST(CASE
			WHEN TRY_CAST(realSum AS FLOAT) > 5000 THEN 1
			ELSE 0
    END AS BIT) AS is_price_outlier

INTO Silver.AirbnbCleaned
FROM Bronze.AirbnbRawData;
GO


-- 2. Check Total Rows
-- Silver should contain the same number of rows as Bronze.

SELECT COUNT(*) AS TotalRows
FROM Silver.AirbnbCleaned;
GO


-- 3. Check Converted Data Types
-- Check whether numeric conversions resulted in NULL values.


SELECT
    SUM(CASE WHEN source_row_index IS NULL THEN 1 ELSE 0 END) AS MissingRowIndex,
    SUM(CASE WHEN real_sum IS NULL THEN 1 ELSE 0 END) AS MissingPrice,
    SUM(CASE WHEN room_type IS NULL THEN 1 ELSE 0 END) AS MissingRoomType,
    SUM(CASE WHEN room_shared IS NULL THEN 1 ELSE 0 END) AS MissingRoomShared,
    SUM(CASE WHEN room_private IS NULL THEN 1 ELSE 0 END) AS MissingRoomPrivate,
    SUM(CASE WHEN person_capacity IS NULL THEN 1 ELSE 0 END) AS MissingCapacity,
    SUM(CASE WHEN host_is_superhost IS NULL THEN 1 ELSE 0 END) AS MissingSuperhost,
	SUM(CASE WHEN multi IS NULL THEN 1 ELSE 0 END) AS MissingMulti,
	SUM(CASE WHEN biz IS NULL THEN 1 ELSE 0 END) AS MissingBiz,
	SUM(CASE WHEN cleanliness_rating IS NULL THEN 1 ELSE 0 END) AS MissingCleanlinessRating,
	SUM(CASE WHEN guest_satisfaction_overall IS NULL THEN 1 ELSE 0 END) AS MissingGuestSatisfaction,
	SUM(CASE WHEN bedrooms IS NULL THEN 1 ELSE 0 END) AS MissingBedrooms,
	SUM(CASE WHEN dist IS NULL THEN 1 ELSE 0 END) AS MissingDist,
	SUM(CASE WHEN metro_dist IS NULL THEN 1 ELSE 0 END) AS MissingMetroDist,
	SUM(CASE WHEN attr_index IS NULL THEN 1 ELSE 0 END) AS MissingAttr,
	SUM(CASE WHEN attr_index_norm IS NULL THEN 1 ELSE 0 END) AS MissingAttrNorm,
	SUM(CASE WHEN rest_index IS NULL THEN 1 ELSE 0 END) AS MissingRest,
	SUM(CASE WHEN rest_index_norm IS NULL THEN 1 ELSE 0 END) AS MissingRestNorm,
    SUM(CASE WHEN lat IS NULL THEN 1 ELSE 0 END) AS MissingLat,
    SUM(CASE WHEN lng IS NULL THEN 1 ELSE 0 END) AS MissingLng,
	SUM(CASE WHEN city IS NULL THEN 1 ELSE 0 END) AS MissingCity,
	SUM(CASE WHEN day_type IS NULL THEN 1 ELSE 0 END) AS MissingDayType,
	SUM(CASE WHEN source_file IS NULL THEN 1 ELSE 0 END) AS MissingSource
FROM Silver.AirbnbCleaned;
GO


-- 4. Check New Flags
-- Count studio listings and high-price listings.

SELECT
    is_studio,
    COUNT(*) AS TotalRows
FROM Silver.AirbnbCleaned
GROUP BY is_studio;
GO

SELECT
    is_price_outlier,
    COUNT(*) AS TotalRows
FROM Silver.AirbnbCleaned
GROUP BY is_price_outlier;
GO


-- 5. Silver Data

SELECT TOP 10 *
FROM Silver.AirbnbCleaned;
GO
