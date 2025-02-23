/* 1. How many records are there in the dataset? 
- Use COUNT(*) function 
- Select from the main table */

SELECT 
    COUNT(*) AS total_records
FROM
    fact_airbnb;
    
    
/* 2. How many unique cities are in the European dataset? 
- Use COUNT(DISTINCT ) function 
- Apply it to the CITY column */

SELECT 
    COUNT(DISTINCT dc.City) AS unique_cities
FROM
    fact_airbnb fa
        JOIN
    dim_city dc ON fa.CityID = dc.CityID;

    
/* 3. What are the names of the cities in the dataset? 
- Use DISTINCT keyword 
- Select from the CITY column */

SELECT DISTINCT
    dc.City
FROM
    fact_airbnb fa
        JOIN
    dim_city dc ON fa.CityID = dc.CityID;
    
    
/* 4. How many bookings are there in each city? 
- Use COUNT(*) function 
- Group by CITY 
- Order results descending */

SELECT 
    dc.City, COUNT(*) AS booking_count
FROM
    fact_airbnb AS fa
        JOIN
    dim_city AS dc ON fa.CityID = dc.CityID
GROUP BY dc.City
ORDER BY booking_count DESC;


/* 5. What is the total booking revenue for each city? 
- Use SUM() function on the PRICE column 
- Group by CITY 
- Round the result 
- Order by total revenue descending */

SELECT 
    dc.City, ROUND(SUM(fa.Price), 2) AS total_revenue
FROM
    fact_airbnb AS fa
        JOIN
    dim_city AS dc ON fa.CityID = dc.CityID
GROUP BY dc.City
ORDER BY total_revenue DESC;


/* 6. What is the average guest satisfaction score for each city? 
- Use AVG() function on GUEST_SATISFACTION column 
- Group by CITY
 - Round the result 
- Order by average score descending */

SELECT 
    dc.City,
    ROUND(AVG(fa.`Guest Satisfaction`), 2) AS average_satisfaction
FROM
    fact_airbnb AS fa
        JOIN
    dim_city AS dc ON fa.CityID = dc.CityID
GROUP BY dc.City
ORDER BY average_satisfaction DESC;


/* 7. What are the minimum, maximum, average, and median booking prices? 
- Use MIN(), MAX(), AVG() functions on PRICE column 
- Use PERCENTILE_CONT(0.5) for median 
- Round results */

WITH PriceCTE AS (
    SELECT
        Price,
        NTILE(2) OVER (ORDER BY Price) AS n
    FROM fact_airbnb
),
AggregatesCTE AS (
    SELECT
        ROUND(MIN(Price), 2) AS min_price,
        ROUND(MAX(Price), 2) AS max_price,
        ROUND(AVG(Price), 2) AS avg_price
    FROM fact_airbnb
),
MedianCalcCTE AS (
    SELECT
        ROUND(AVG(Price), 2) AS median_price
    FROM PriceCTE
    WHERE n = 1
       OR n = 2
)
SELECT
    a.min_price,
    a.max_price,
    a.avg_price,
    m.median_price
FROM AggregatesCTE a, MedianCalcCTE m;


/* 8. How many outliers are there in the price field? 
- Calculate Q1, Q3, and IQR using PERCENTILE_CONT() 
- Define lower and upper bounds 
- Count records outside these bounds */ 

WITH PriceCTE AS (
    SELECT 
        Price,
        NTILE(4) OVER (ORDER BY Price) AS quartile
    FROM fact_airbnb
),
QuartilesCTE AS (
    SELECT
        MIN(CASE WHEN quartile = 1 THEN Price END) AS Q1,
        MIN(CASE WHEN quartile = 3 THEN Price END) AS Q3
    FROM PriceCTE
),
BoundsCTE AS (
    SELECT
        Q1,
        Q3,
        (Q3 - Q1) AS IQR,
        Q1 - 1.5 * (Q3 - Q1) AS lower_bound,
        Q3 + 1.5 * (Q3 - Q1) AS upper_bound
    FROM QuartilesCTE
)
SELECT
    COUNT(*) AS outlier_count
FROM fact_airbnb fa
JOIN BoundsCTE b ON fa.Price < b.lower_bound OR fa.Price > b.upper_bound;


/* 9. What are the characteristics of the outliers in terms of room type, number of bookings, and price? 
- Create a view or CTE for outliers 
- Group by ROOM_TYPE 
- Use COUNT(), MIN(), MAX(), AVG() functions */

WITH PriceCTE AS (
    SELECT 
        Price,
        NTILE(4) OVER (ORDER BY Price) AS quartile
    FROM fact_airbnb
),
QuartilesCTE AS (
    SELECT
        MIN(CASE WHEN quartile = 1 THEN Price END) AS Q1,
        MIN(CASE WHEN quartile = 3 THEN Price END) AS Q3
    FROM PriceCTE
),
BoundsCTE AS (
    SELECT
        Q1,
        Q3,
        (Q3 - Q1) AS IQR,
        Q1 - 1.5 * (Q3 - Q1) AS lower_bound,
        Q3 + 1.5 * (Q3 - Q1) AS upper_bound
    FROM QuartilesCTE
),
OutliersCTE AS (
    SELECT
        fa.roomtypeID,
        fa.Price
    FROM fact_airbnb fa
    JOIN BoundsCTE b ON fa.Price < b.lower_bound OR fa.Price > b.upper_bound
)
SELECT
    dr.`Room Type`,
    COUNT(*) AS number_of_bookings,
    ROUND(MIN(o.Price), 2) AS min_price,
    ROUND(MAX(o.Price), 2) AS max_price,
    ROUND(AVG(o.Price), 2) AS avg_price
FROM OutliersCTE o
JOIN dim_roomtype dr ON o.roomtypeID = dr.roomtypeID
GROUP BY dr.`Room Type`;


/* 10. How does the average price differ between the main dataset and the dataset with outliers
removed?
 - Create a view for cleaned data (without outliers)
 - Calculate average price for both datasets
 - Compare results */
 
-- Creation of the View for Cleaned Data
 
CREATE VIEW cleaned_data AS
WITH PriceCTE AS (
    SELECT 
        Price,
        NTILE(4) OVER (ORDER BY PRICE) AS quartile
    FROM fact_airbnb
),
QuartilesCTE AS (
    SELECT
        MIN(CASE WHEN quartile = 1 THEN Price END) AS Q1,
        MIN(CASE WHEN quartile = 3 THEN Price END) AS Q3
    FROM PriceCTE
),
BoundsCTE AS (
    SELECT
        Q1,
        Q3,
        (Q3 - Q1) AS IQR,
        Q1 - 1.5 * (Q3 - Q1) AS lower_bound,
        Q3 + 1.5 * (Q3 - Q1) AS upper_bound
    FROM QuartilesCTE
),
OutliersCTE AS (
    SELECT
        Price
    FROM fact_airbnb fa
    JOIN BoundsCTE b ON fa.Price < b.lower_bound OR fa.Price > b.upper_bound
)
SELECT
    Price
FROM fact_airbnb
WHERE Price NOT IN (SELECT Price FROM OutliersCTE);

-- Calculate average price for the main dataset
SELECT 
    'Main Dataset' AS dataset,
    ROUND(AVG(Price), 2) AS average_price
FROM
    fact_airbnb 
UNION ALL SELECT 
    'Cleaned Dataset' AS dataset,
    ROUND(AVG(Price), 2) AS average_price
FROM
    cleaned_data;
    
    
/* 11. What is the average price for each room type? 
- Use AVG() function on PRICE column 
- Group by ROOM_TYPE */

SELECT 
    dr.`Room Type`, ROUND(AVG(fa.Price), 2) AS average_price
FROM
    fact_airbnb fa
        JOIN
    dim_roomtype dr ON fa.roomtypeID = dr.roomtypeID
GROUP BY dr.`Room Type`;


/* 12. How do weekend and weekday bookings compare in terms of average price and number of bookings? 
- Group by DAY column 
- Use AVG() for price and COUNT() for bookings */

SELECT
    dt.DayType AS day_type,
    ROUND(AVG(fa.Price), 2) AS average_price,
    COUNT(*) AS number_of_bookings
FROM fact_airbnb fa
JOIN dim_daytype dt ON fa.DayTypeID = dt.DayTypeID
GROUP BY dt.DayType;


/* 13. What is the average distance from metro and city center for each city? 
- Use AVG() on METRO_DISTANCE_KM and CITY_CENTER_KM columns 
- Group by CITY */ 

SELECT 
    dc.City AS city_name,
    ROUND(AVG(fa.`Metro Distance (km)`), 2) AS average_metro_distance,
    ROUND(AVG(fa.`City Center (km)`), 2) AS average_city_center_distance
FROM
    fact_airbnb fa
        JOIN
    dim_city dc ON fa.CityID = dc.CityID
GROUP BY dc.City;


/* 14. How many bookings are there for each room type on weekdays vs weekends? 
- Use CASE statements to categorize room types 
- Group by DAY and ROOM_TYPE */

SELECT 
    dt.DayType AS day_type,
    dr.`Room Type`,
    COUNT(*) AS number_of_bookings
FROM
    fact_airbnb fa
        JOIN
    dim_daytype dt ON fa.DayTypeID = dt.DayTypeID
        JOIN
    dim_roomtype dr ON fa.roomtypeID = dr.roomtypeID
GROUP BY dt.DayType , dr.`Room Type`;


/* 15. What is the booking revenue for each room type on weekdays vs weekends? 
- Similar to previous question, but use SUM() on PRICE instead of COUNT() */

SELECT
    dt.DayType AS day_type,
    dr.`Room Type`,
    ROUND(SUM(fa.Price), 2) AS total_revenue
FROM fact_airbnb fa
JOIN dim_daytype dt ON fa.DayTypeID = dt.DayTypeID
JOIN dim_roomtype dr ON fa.roomtypeID = dr.roomtypeID
GROUP BY dt.DayType, dr.`Room Type`;


/* 16. What is the overall average, minimum, and maximum guest satisfaction score? 
- Use AVG(), MIN(), MAX() functions on GUEST_SATISFACTION column */

SELECT 
    ROUND(AVG(`Guest Satisfaction`), 2) AS average_satisfaction,
    MIN(`Guest Satisfaction`) AS minimum_satisfaction,
    MAX(`Guest Satisfaction`) AS maximum_satisfaction
FROM
    fact_airbnb;
    
    
/* 17. How does guest satisfaction score vary by city?
 - Group by CITY
 - Use AVG(), MIN(), MAX() on GUEST_SATISFACTION column */
 
SELECT 
    dc.City AS city_name,
    ROUND(AVG(fa.`Guest Satisfaction`), 2) AS average_satisfaction,
    MIN(fa.`Guest Satisfaction`) AS minimum_satisfaction,
    MAX(fa.`Guest Satisfaction`) AS maximum_satisfaction
FROM
    fact_airbnb fa
        JOIN
    dim_city dc ON fa.CITYID = dc.CITYID
GROUP BY dc.City;


/* 18. Is there a correlation between guest satisfaction and factors like cleanliness rating, price, or
attraction index?
 - Use CORR() function to calculate correlation coefficients */
 
 -- Correlation between guest satisfaction and cleanliness rating
WITH stats AS (
    SELECT
        COUNT(*) AS n,
        SUM(`Guest Satisfaction`) AS sum_x,
        SUM(`Cleanliness Rating`) AS sum_y,
        SUM(POW(`Guest Satisfaction`, 2)) AS sum_x2,
        SUM(POW(`Cleanliness Rating`, 2)) AS sum_y2,
        SUM(`Guest Satisfaction` * `Cleanliness Rating`) AS sum_xy
    FROM fact_airbnb
),

correlation_cleanliness AS (
    SELECT
        ROUND(
            (n * sum_xy - sum_x * sum_y) /
            (SQRT((n * sum_x2 - POW(sum_x, 2)) * (n * sum_y2 - POW(sum_y, 2)))),
            2
        ) AS correlation_with_cleanliness
    FROM stats
)

SELECT correlation_with_cleanliness
FROM correlation_cleanliness;

-- Correlation between guest satisfaction and price
WITH stats AS (
    SELECT
        COUNT(*) AS n,
        SUM(`Guest Satisfaction`) AS sum_x,
        SUM(Price) AS sum_y,
        SUM(POW(`Guest Satisfaction`, 2)) AS sum_x2,
        SUM(POW(Price, 2)) AS sum_y2,
        SUM(`Guest Satisfaction` * Price) AS sum_xy
    FROM fact_airbnb
),

correlation_price AS (
    SELECT
        ROUND(
            (n * sum_xy - sum_x * sum_y) /
            (SQRT((n * sum_x2 - POW(sum_x, 2)) * (n * sum_y2 - POW(sum_y, 2)))),
            2
        ) AS correlation_with_price
    FROM stats
)

SELECT correlation_with_price
FROM correlation_price;

-- Correlation between guest satisfaction and attraction index
WITH stats AS (
    SELECT
        COUNT(*) AS n,
        SUM(`Guest Satisfaction`) AS sum_x,
        SUM(`Normalised Attraction Index`) AS sum_y,
        SUM(POW(`Guest Satisfaction`, 2)) AS sum_x2,
        SUM(POW(`Normalised Attraction Index`, 2)) AS sum_y2,
        SUM(`Guest Satisfaction` * `Normalised Attraction Index`) AS sum_xy
    FROM fact_airbnb
),

correlation_attraction AS (
    SELECT
        ROUND(
            (n * sum_xy - sum_x * sum_y) /
            (SQRT((n * sum_x2 - POW(sum_x, 2)) * (n * sum_y2 - POW(sum_y, 2)))),
            2
        ) AS correlation_with_attraction_index
    FROM stats
)

SELECT correlation_with_attraction_index
FROM correlation_attraction; 
-- There is no correlation between Guest Satisfaction and Attraction Index


/* 19. What is the average booking value across all cleaned data?
 - Use AVG() function on PRICE column from cleaned data view */
 
 -- Divide Data into Quartiles Using NTILE
WITH price_quartiles AS (
    SELECT
        Price,
        NTILE(4) OVER (ORDER BY Price) AS quartile
    FROM fact_airbnb
)

-- Filter Outliers (Keep Only Q2 and Q3 for Cleaned Data)
, cleaned_data AS (
    SELECT Price
    FROM price_quartiles
    WHERE quartile IN (2, 3)
)

-- Calculate Average Booking Value from Cleaned Data
SELECT ROUND(AVG(Price), 2) AS average_booking_value
FROM cleaned_data;


/* 20. What is the average cleanliness score across all cleaned data? 
- Use AVG() function on CLEANINGNESS_RATING column from cleaned data */

-- Divide Data into Quartiles Using NTILE
WITH price_quartiles AS (
    SELECT
        `Cleanliness Rating`,
        NTILE(4) OVER (ORDER BY `Cleanliness Rating`) AS quartile
    FROM fact_airbnb
)

-- Filter Outliers (Keep Only Q2 and Q3 for Cleaned Data)
, cleaned_data AS (
    SELECT `Cleanliness Rating`
    FROM price_quartiles
    WHERE quartile IN (2, 3)
)

-- Calculate Average Cleanliness Rating from Cleaned Data
SELECT ROUND(AVG(`Cleanliness Rating`), 2) AS average_cleanliness_score
FROM cleaned_data;


/* 21. How do cities rank in terms of total revenue?
 - Use SUM() on PRICE column
 - Group by CITY
 - Use window function ROW_NUMBER() to assign ranks */
 
 -- Calculate Total Revenue for Each City and Rank Them
WITH city_revenue AS (
    SELECT
        dc.City,
        SUM(fa.Price) AS total_revenue,
        ROW_NUMBER() OVER (ORDER BY SUM(fa.Price) DESC) AS tier
    FROM fact_airbnb fa
    JOIN dim_city dc ON fa.CityID = dc.CityID
    GROUP BY dc.City
)

-- Select the Ranked Cities and Their Total Revenue
SELECT 
    tier,
    City,
    ROUND(total_revenue, 2) AS total_revenue
FROM city_revenue
ORDER BY tier;







 
 




