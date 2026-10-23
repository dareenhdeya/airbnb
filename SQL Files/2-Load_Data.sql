USE airbnb;
GO

CREATE TABLE BRONZE.AirbnbStaging
(
    c0 VARCHAR(50),
    c1 VARCHAR(100),
    c2 VARCHAR(100),
    c3 VARCHAR(50),
    c4 VARCHAR(50),
    c5 VARCHAR(50),
    c6 VARCHAR(50),
    c7 VARCHAR(50),
    c8 VARCHAR(50),
    c9 VARCHAR(50),
    c10 VARCHAR(50),
    c11 VARCHAR(50),
    c12 VARCHAR(50),
    c13 VARCHAR(50),
    c14 VARCHAR(50),
    c15 VARCHAR(50),
    c16 VARCHAR(50),
    c17 VARCHAR(50),
    c18 VARCHAR(50),
    c19 VARCHAR(50)
);
GO

CREATE TABLE BRONZE.AirbnbRawData
(
    RowIndex VARCHAR(50),
    realSum VARCHAR(100),
    room_type VARCHAR(100),
    room_shared VARCHAR(50),
    room_private VARCHAR(50),
    person_capacity VARCHAR(50),
    host_is_superhost VARCHAR(50),
    multi VARCHAR(50),
    biz VARCHAR(50),
    cleanliness_rating VARCHAR(50),
    guest_satisfaction_overall VARCHAR(50),
    bedrooms VARCHAR(50),
    dist VARCHAR(100),
    metro_dist VARCHAR(100),
    attr_index VARCHAR(100),
    attr_index_norm VARCHAR(100),
    rest_index VARCHAR(100),
    rest_index_norm VARCHAR(100),
    lng VARCHAR(100),
    lat VARCHAR(100),

    City VARCHAR(50),
    DayType VARCHAR(20),
    SourceFile VARCHAR(100)
);
GO


BULK INSERT BRONZE.AirbnbStaging
FROM 'D:\data_science\training\sprint 1\my-pr\data\old_data\vienna_weekends.csv'
WITH
(
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001'
);
GO

INSERT INTO BRONZE.AirbnbRawData
(
    RowIndex, realSum, room_type, room_shared,
    room_private, person_capacity, host_is_superhost,
    multi, biz, cleanliness_rating,
    guest_satisfaction_overall, bedrooms, dist,
    metro_dist, attr_index, attr_index_norm,
    rest_index, rest_index_norm, lng, lat,
    City, DayType, SourceFile
)
SELECT
    c0, c1, c2, c3, c4, c5, c6, c7, c8, c9,
    c10, c11, c12, c13, c14, c15, c16, c17,
    c18, c19,
    'vienna',
    'weekends',
    'vienna_weekends.csv'
FROM BRONZE.AirbnbStaging;
GO

TRUNCATE TABLE BRONZE.AirbnbStaging;



SELECT City, DayType, COUNT(*) AS TotalRows
FROM BRONZE.AirbnbRawData
GROUP BY City, DayType
ORDER BY City, DayType;
GO


SELECT *
FROM BRONZE.AirbnbStaging
GO