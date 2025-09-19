-- Task 5: Partitioning Large Tables
-- ALX Airbnb Database Project

-- Step 1: Create a new partitioned Booking table
-- Note: We'll create a new table and then migrate data

-- First, let's create the partitioned version of the Booking table
CREATE TABLE Booking_Partitioned (
    booking_id UUID NOT NULL,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending','confirmed','canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (booking_id, start_date),  -- Include partition key in PK
    
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
) 
PARTITION BY RANGE (YEAR(start_date)) (
    PARTITION p2020 VALUES LESS THAN (2021),
    PARTITION p2021 VALUES LESS THAN (2022),
    PARTITION p2022 VALUES LESS THAN (2023),
    PARTITION p2023 VALUES LESS THAN (2024),
    PARTITION p2024 VALUES LESS THAN (2025),
    PARTITION p2025 VALUES LESS THAN (2026),
    PARTITION p2026 VALUES LESS THAN (2027),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Alternative: Partition by month for more granular partitioning
CREATE TABLE Booking_Monthly_Partitioned (
    booking_id UUID NOT NULL,
    property_id UUID NOT NULL,
    user_id UUID NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending','confirmed','canceled') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    PRIMARY KEY (booking_id, start_date),
    
    FOREIGN KEY (property_id) REFERENCES Property(property_id),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
)
PARTITION BY RANGE (TO_DAYS(start_date)) (
    PARTITION p202401 VALUES LESS THAN (TO_DAYS('2024-02-01')),
    PARTITION p202402 VALUES LESS THAN (TO_DAYS('2024-03-01')),
    PARTITION p202403 VALUES LESS THAN (TO_DAYS('2024-04-01')),
    PARTITION p202404 VALUES LESS THAN (TO_DAYS('2024-05-01')),
    PARTITION p202405 VALUES LESS THAN (TO_DAYS('2024-06-01')),
    PARTITION p202406 VALUES LESS THAN (TO_DAYS('2024-07-01')),
    PARTITION p202407 VALUES LESS THAN (TO_DAYS('2024-08-01')),
    PARTITION p202408 VALUES LESS THAN (TO_DAYS('2024-09-01')),
    PARTITION p202409 VALUES LESS THAN (TO_DAYS('2024-10-01')),
    PARTITION p202410 VALUES LESS THAN (TO_DAYS('2024-11-01')),
    PARTITION p202411 VALUES LESS THAN (TO_DAYS('2024-12-01')),
    PARTITION p202412 VALUES LESS THAN (TO_DAYS('2025-01-01')),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Step 2: Create indexes on partitioned table
CREATE INDEX idx_booking_part_property ON Booking_Partitioned(property_id);
CREATE INDEX idx_booking_part_user ON Booking_Partitioned(user_id);
CREATE INDEX idx_booking_part_status ON Booking_Partitioned(status);
CREATE INDEX idx_booking_part_dates ON Booking_Partitioned(start_date, end_date);

-- Step 3: Migrate data from original table (if it exists)
-- INSERT INTO Booking_Partitioned 
-- SELECT * FROM Booking;

-- Step 4: Test queries on partitioned table

-- Query 1: Get bookings for a specific date range (will use partition pruning)
SELECT 
    booking_id,
    property_id,
    user_id,
    start_date,
    end_date,
    total_price,
    status
FROM 
    Booking_Partitioned
WHERE 
    start_date >= '2024-01-01' 
    AND start_date < '2024-12-31'
ORDER BY 
    start_date DESC;

-- Query 2: Get bookings for a specific month (optimal for monthly partitioning)
SELECT 
    booking_id,
    start_date,
    end_date,
    total_price
FROM 
    Booking_Partitioned
WHERE 
    start_date >= '2024-06-01' 
    AND start_date < '2024-07-01'
    AND status = 'confirmed';

-- Query 3: Aggregate bookings by year (will scan only relevant partitions)
SELECT 
    YEAR(start_date) as booking_year,
    COUNT(*) as total_bookings,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_booking_value
FROM 
    Booking_Partitioned
WHERE 
    start_date >= '2022-01-01'
GROUP BY 
    YEAR(start_date)
ORDER BY 
    booking_year;

-- Performance testing queries
-- Before partitioning (original table)
EXPLAIN SELECT * FROM Booking 
WHERE start_date >= '2024-01-01' AND start_date < '2024-12-31';

-- After partitioning
EXPLAIN SELECT * FROM Booking_Partitioned 
WHERE start_date >= '2024-01-01' AND start_date < '2024-12-31';

-- Add new partitions for future dates
ALTER TABLE Booking_Partitioned 
ADD PARTITION (
    PARTITION p2027 VALUES LESS THAN (2028),
    PARTITION p2028 VALUES LESS THAN (2029)
);

-- Drop old partitions (if needed)
-- ALTER TABLE Booking_Partitioned DROP PARTITION p2020;