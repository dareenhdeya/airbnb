USE airbnb;
GO

-- Dimension Tables

-- dim city
CREATE TABLE Gold.dim_city (
    city_key INT IDENTITY(1,1) PRIMARY KEY,
    city VARCHAR(100) NOT NULL UNIQUE
);
GO

INSERT INTO Gold.dim_city (city)
SELECT DISTINCT city
FROM Silver.AirbnbCleaned;
GO


-- dim room type
CREATE TABLE Gold.dim_room_type (
    room_type_key INT IDENTITY(1,1) PRIMARY KEY,
    room_type VARCHAR(50) NOT NULL UNIQUE
);
GO

INSERT INTO Gold.dim_room_type (room_type)
SELECT DISTINCT room_type
FROM Silver.AirbnbCleaned;
GO


-- dim day type
CREATE TABLE Gold.dim_day_type (
    day_type_key INT IDENTITY(1,1) PRIMARY KEY,
    day_type VARCHAR(20) NOT NULL UNIQUE
);
GO

INSERT INTO Gold.dim_day_type (day_type)
SELECT DISTINCT day_type
FROM Silver.AirbnbCleaned;
GO


-- dim host
CREATE TABLE Gold.dim_host (
    host_key INT IDENTITY(1,1) PRIMARY KEY,
    host_is_superhost BIT NOT NULL,
    multi BIT NOT NULL,
    biz BIT NOT NULL
);
GO

INSERT INTO Gold.dim_host (host_is_superhost, multi, biz)
SELECT DISTINCT host_is_superhost, multi, biz
FROM Silver.AirbnbCleaned;
GO


-- fact listing
CREATE TABLE Gold.fact_listing (
    listing_key INT IDENTITY(1,1) PRIMARY KEY,

    city_key INT NOT NULL,
    room_type_key INT NOT NULL,
    day_type_key INT NOT NULL,
    host_key INT NOT NULL,

    city VARCHAR(100) NOT NULL,
    day_type VARCHAR(20) NOT NULL,
    source_row_index INT,

    real_sum DECIMAL(10,2),
    person_capacity INT,
    bedrooms INT,
    cleanliness_rating DECIMAL(4,1),
    guest_satisfaction_overall DECIMAL(5,2),
    dist DECIMAL(10,4),
    metro_dist DECIMAL(10,4),
    attr_index DECIMAL(10,4),
    rest_index DECIMAL(10,4),
    lat DECIMAL(9,6),
    lng DECIMAL(9,6),

    is_studio BIT,
    is_price_outlier BIT,

    FOREIGN KEY (city_key) REFERENCES Gold.dim_city(city_key),
    FOREIGN KEY (room_type_key) REFERENCES Gold.dim_room_type(room_type_key),
    FOREIGN KEY (day_type_key) REFERENCES Gold.dim_day_type(day_type_key),
    FOREIGN KEY (host_key) REFERENCES Gold.dim_host(host_key)
);
GO


-- load fact listing
INSERT INTO Gold.fact_listing (city_key,room_type_key,day_type_key,host_key,city,day_type,source_row_index,real_sum,person_capacity,bedrooms,cleanliness_rating, guest_satisfaction_overall,dist,metro_dist,attr_index,rest_index,lat,lng,is_studio,is_price_outlier)
SELECT c.city_key, r.room_type_key, d.day_type_key, h.host_key, s.city,s.day_type,s.source_row_index,s.real_sum,s.person_capacity,s.bedrooms,s.cleanliness_rating,s.guest_satisfaction_overall,s.dist,s.metro_dist,s.attr_index,s.rest_index,s.lat,s.lng,s.is_studio,s.is_price_outlier
FROM Silver.AirbnbCleaned AS s INNER JOIN Gold.dim_city AS c
ON s.city = c.city INNER JOIN Gold.dim_room_type AS r
ON s.room_type = r.room_type INNER JOIN Gold.dim_day_type AS d
ON s.day_type = d.day_type INNER JOIN Gold.dim_host AS h
ON s.host_is_superhost = h.host_is_superhost AND s.multi = h.multi AND s.biz = h.biz;
GO


-- check table row counts
SELECT COUNT(*) AS DimCityRows
FROM Gold.dim_city;
GO

SELECT COUNT(*) AS DimRoomTypeRows
FROM Gold.dim_room_type;
GO

SELECT COUNT(*) AS DimDayTypeRows
FROM Gold.dim_day_type;
GO

SELECT COUNT(*) AS DimHostRows
FROM Gold.dim_host;
GO

SELECT COUNT(*) AS FactListingRows
FROM Gold.fact_listing;
GO


-- fact table
SELECT TOP 10 *
FROM Gold.fact_listing;
GO