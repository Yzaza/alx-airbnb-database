-- Task 4: Optimize Complex Queries
-- ALX Airbnb Database Project

-- =====================================================
-- INITIAL QUERY (Before Optimization)
-- =====================================================
-- This query retrieves all bookings along with the user details, property details, and payment details

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price AS booking_total,
    b.status AS booking_status,
    b.created_at AS booking_created,
    
    -- User details
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    
    -- Property details
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location,
    p.pricepernight,
    
    -- Host details
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    h.phone_number AS host_phone,
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
    
FROM 
    Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date >= '2024-01-01' 
    AND b.status = 'confirmed'
ORDER BY 
    b.created_at DESC;

-- =====================================================
-- ANALYZE INITIAL QUERY PERFORMANCE USING EXPLAIN
-- =====================================================

EXPLAIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price AS booking_total,
    b.status AS booking_status,
    b.created_at AS booking_created,
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    u.phone_number,
    u.role,
    p.property_id,
    p.name AS property_name,
    p.description AS property_description,
    p.location,
    p.pricepernight,
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    h.email AS host_email,
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
FROM 
    Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date >= '2024-01-01' 
    AND b.status = 'confirmed'
ORDER BY 
    b.created_at DESC;

-- =====================================================
-- IDENTIFIED INEFFICIENCIES
-- =====================================================
-- 1. Retrieving all columns including large TEXT fields (description)
-- 2. No LIMIT clause causing large result sets
-- 3. Multiple JOINs without proper indexing
-- 4. Redundant host information columns
-- 5. Not using composite indexes effectively

-- =====================================================
-- REFACTORED QUERY (After Optimization)
-- =====================================================
-- Optimization techniques applied:
-- 1. Reduced number of columns (removed unnecessary fields)
-- 2. Added LIMIT clause to control result set size
-- 3. Used CONCAT to reduce column count
-- 4. Removed TEXT columns (description) that cause high I/O
-- 5. Better use of indexes with WHERE clause

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Concatenated user name (reduced columns)
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    
    -- Essential property details only (removed description)
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    -- Concatenated host name (reduced columns)
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    
    -- Payment details
    pay.amount AS payment_amount,
    pay.payment_method
    
FROM 
    Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
    
WHERE 
    b.start_date >= '2024-01-01' 
    AND b.status IN ('confirmed', 'pending')
    
ORDER BY 
    b.created_at DESC
LIMIT 1000;

-- =====================================================
-- ANALYZE REFACTORED QUERY PERFORMANCE
-- =====================================================

EXPLAIN
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    CONCAT(h.first_name, ' ', h.last_name) AS host_name,
    pay.amount AS payment_amount,
    pay.payment_method
FROM 
    Booking b
    INNER JOIN User u ON b.user_id = u.user_id
    INNER JOIN Property p ON b.property_id = p.property_id
    INNER JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
WHERE 
    b.start_date >= '2024-01-01' 
    AND b.status IN ('confirmed', 'pending')
ORDER BY 
    b.created_at DESC
LIMIT 1000;