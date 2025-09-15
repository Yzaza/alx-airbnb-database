# Normalization of Airbnb Database

## Step 1: First Normal Form (1NF)
- All tables have atomic columns. No multi-valued attributes exist.
- Each row is unique with a defined primary key.

## Step 2: Second Normal Form (2NF)
- All tables are in 1NF.
- All non-key attributes are fully dependent on the primary key.
- Example: In `Booking`, `total_price` depends on `booking_id` and not partially on `property_id` or `user_id`.

## Step 3: Third Normal Form (3NF)
- All tables are in 2NF.
- No transitive dependencies exist:
  - Attributes depend only on the primary key.
  - Example: `Property` table: `name`, `description`, `location`, and `pricepernight` all depend solely on `property_id`.
  
## Conclusion
- All entities (`User`, `Property`, `Booking`, `Payment`, `Review`, `Message`) satisfy 3NF.
- Database design is optimized for data integrity and minimal redundancy.
