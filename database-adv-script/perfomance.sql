-- Task 3: Implement Indexes for Optimization
-- ALX Airbnb Database Project

-- High-usage columns analysis and index creation

-- Indexes for User table
-- Email is already indexed (UNIQUE constraint creates index)
-- Additional indexes for frequently queried columns
CREATE INDEX idx_user_role ON User(role);
CREATE INDEX idx_user_created_at ON User(created_at);

-- Indexes for Property table
-- host_id already has index from schema
CREATE INDEX idx_property_location ON Property(location);
CREATE INDEX idx_property_pricepernight ON Property(pricepernight);
CREATE INDEX idx_property_created_at ON Property(created_at);
CREATE INDEX idx_property_name ON Property(name);

-- Composite index for property search (location + price range)
CREATE INDEX idx_property_location_price ON Property(location, pricepernight);

-- Indexes for Booking table
-- property_id and user_id already have indexes from schema
CREATE INDEX idx_booking_start_date ON Booking(start_date);
CREATE INDEX idx_booking_end_date ON Booking(end_date);
CREATE INDEX idx_booking_status ON Booking(status);
CREATE INDEX idx_booking_created_at ON Booking(created_at);

-- Composite indexes for booking queries
CREATE INDEX idx_booking_dates ON Booking(start_date, end_date);
CREATE INDEX idx_booking_property_dates ON Booking(property_id, start_date, end_date);
CREATE INDEX idx_booking_user_status ON Booking(user_id, status);

-- Indexes for Payment table
-- booking_id already has index from schema
CREATE INDEX idx_payment_date ON Payment(payment_date);
CREATE INDEX idx_payment_method ON Payment(payment_method);
CREATE INDEX idx_payment_amount ON Payment(amount);

-- Indexes for Review table
-- property_id and user_id already have indexes from schema
CREATE INDEX idx_review_rating ON Review(rating);
CREATE INDEX idx_review_created_at ON Review(created_at);

-- Composite index for review analysis
CREATE INDEX idx_review_property_rating ON Review(property_id, rating);

-- Indexes for Message table
-- sender_id and recipient_id already have indexes from schema
CREATE INDEX idx_message_sent_at ON Message(sent_at);

-- Composite index for message queries
CREATE INDEX idx_message_conversation ON Message(sender_id, recipient_id, sent_at);

-- Performance optimization indexes for common query patterns

-- Index for finding available properties in date range
CREATE INDEX idx_booking_availability ON Booking(property_id, start_date, end_date, status);

-- Index for user activity analysis
CREATE INDEX idx_user_activity ON User(role, created_at);

-- Index for property performance analysis
CREATE INDEX idx_property_performance ON Property(host_id, created_at, pricepernight);

-- Index for financial reporting
CREATE INDEX idx_payment_reporting ON Payment(payment_date, payment_method, amount);

-- Show existing indexes (for verification)
-- SHOW INDEX FROM User;
-- SHOW INDEX FROM Property;
-- SHOW INDEX FROM Booking;
-- SHOW INDEX FROM Payment;
-- SHOW INDEX FROM Review;
-- SHOW INDEX FROM Message;

-- Task 4: Optimize Complex Queries
-- ALX Airbnb Database Project

-- =====================================================
-- INITIAL QUERY (Before Optimization)
-- =====================================================
-- This query retrieves all bookings with user details, property details, and payment details

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
    
    -- Payment details
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_date,
    pay.payment_method
    
FROM 
    Booking b
    JOIN User u ON b.user_id = u.user_id
    JOIN Property p ON b.property_id = p.property_id
    JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY 
    b.created_at DESC, b.booking_id;

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
    u.user_id,
    u.first_name,
    u.last_name,
    u.email,
    p.property_id,
    p.name AS property_name,
    p.location,
    p.pricepernight,
    h.user_id AS host_id,
    h.first_name AS host_first_name,
    h.last_name AS host_last_name,
    pay.payment_id,
    pay.amount AS payment_amount,
    pay.payment_method
FROM 
    Booking b
    JOIN User u ON b.user_id = u.user_id
    JOIN Property p ON b.property_id = p.property_id
    JOIN User h ON p.host_id = h.user_id
    LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
ORDER BY 
    b.created_at DESC;

-- =====================================================
-- REFACTORED QUERY (After Optimization)
-- =====================================================
-- Optimization techniques applied:
-- 1. Reduced number of columns (removed unnecessary fields)
-- 2. Added WHERE clause for filtering
-- 3. Added LIMIT clause
-- 4. Used CONCAT to reduce column count
-- 5. Removed TEXT columns that cause high I/O

SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    
    -- Concatenated user name (reduced columns)
    CONCAT(u.first_name, ' ', u.last_name) AS guest_name,
    u.email AS guest_email,
    
    -- Essential property details only
    p.name AS property_name,
    p.location,
    p.pricepernight,
    
    -- Concatenated host name
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
    b.status IN ('confirmed', 'pending')
    
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
    b.status IN ('confirmed', 'pending')
ORDER BY 
    b.created_at DESC
LIMIT 1000;