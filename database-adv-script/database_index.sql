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

-- Performance measurement queries using EXPLAIN and ANALYZE

-- Test query performance BEFORE creating indexes
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.location, p.pricepernight
FROM Property p
WHERE p.location = 'New York' AND p.pricepernight BETWEEN 100 AND 300;

EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.end_date, b.total_price
FROM Booking b
WHERE b.start_date >= '2024-01-01' AND b.end_date <= '2024-12-31';

EXPLAIN ANALYZE
SELECT r.review_id, r.rating, r.comment
FROM Review r
WHERE r.rating >= 4;

-- After creating the indexes above, test the same queries again to measure improvement

-- Test query performance AFTER creating indexes
EXPLAIN ANALYZE
SELECT p.property_id, p.name, p.location, p.pricepernight
FROM Property p
WHERE p.location = 'New York' AND p.pricepernight BETWEEN 100 AND 300;

EXPLAIN ANALYZE
SELECT b.booking_id, b.start_date, b.end_date, b.total_price
FROM Booking b
WHERE b.start_date >= '2024-01-01' AND b.end_date <= '2024-12-31';

EXPLAIN ANALYZE
SELECT r.review_id, r.rating, r.comment
FROM Review r
WHERE r.rating >= 4;

-- Additional performance testing queries
EXPLAIN ANALYZE
SELECT u.user_id, u.first_name, u.last_name, COUNT(b.booking_id) as booking_count
FROM User u
LEFT JOIN Booking b ON u.user_id = b.user_id
WHERE u.role = 'guest'
GROUP BY u.user_id, u.first_name, u.last_name;

EXPLAIN ANALYZE
SELECT p.property_id, p.name, AVG(r.rating) as avg_rating
FROM Property p
LEFT JOIN Review r ON p.property_id = r.property_id
GROUP BY p.property_id, p.name
HAVING AVG(r.rating) > 4.0;

-- Show existing indexes (for verification)
SHOW INDEX FROM User;
SHOW INDEX FROM Property;
SHOW INDEX FROM Booking;
SHOW INDEX FROM Payment;
SHOW INDEX FROM Review;
SHOW INDEX FROM Message;