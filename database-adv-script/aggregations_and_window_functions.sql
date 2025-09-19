-- Task 2: Apply Aggregations and Window Functions
-- ALX Airbnb Database Project

-- 1. Aggregation: Find the total number of bookings made by each user using COUNT and GROUP BY
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    COUNT(b.booking_id) AS total_bookings
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name, u.email
ORDER BY 
    total_bookings DESC, u.last_name;

-- Additional aggregations for comprehensive analysis
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) AS total_bookings,
    COALESCE(SUM(b.total_price), 0) AS total_spent,
    COALESCE(AVG(b.total_price), 0) AS avg_booking_value
FROM 
    User u
LEFT JOIN 
    Booking b ON u.user_id = b.user_id
GROUP BY 
    u.user_id, u.first_name, u.last_name
HAVING 
    COUNT(b.booking_id) > 0
ORDER BY 
    total_bookings DESC;

-- 2. Window Functions: Rank properties based on the total number of bookings they have received
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (ORDER BY COUNT(b.booking_id) DESC) AS row_number,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS rank_by_bookings,
    DENSE_RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS dense_rank_by_bookings
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    total_bookings DESC, p.name;

-- Additional window function: Properties ranked by price within each location
SELECT 
    p.property_id,
    p.name,
    p.location,
    p.pricepernight,
    COUNT(b.booking_id) AS total_bookings,
    ROW_NUMBER() OVER (PARTITION BY p.location ORDER BY p.pricepernight DESC) AS price_rank_in_location,
    RANK() OVER (PARTITION BY p.location ORDER BY COUNT(b.booking_id) DESC) AS booking_rank_in_location
FROM 
    Property p
LEFT JOIN 
    Booking b ON p.property_id = b.property_id
GROUP BY 
    p.property_id, p.name, p.location, p.pricepernight
ORDER BY 
    p.location, price_rank_in_location;

-- Window function with running totals
SELECT 
    b.booking_id,
    b.start_date,
    b.total_price,
    u.first_name,
    u.last_name,
    SUM(b.total_price) OVER (
        PARTITION BY b.user_id 
        ORDER BY b.start_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS running_total_spent
FROM 
    Booking b
JOIN 
    User u ON b.user_id = u.user_id
ORDER BY 
    u.user_id, b.start_date;