-- --------------------------
-- Users
-- --------------------------
INSERT INTO User (user_id, first_name, last_name, email, password_hash, role)
VALUES
(gen_random_uuid(), 'Alice', 'Smith', 'alice@example.com', 'hashedpassword', 'guest'),
(gen_random_uuid(), 'Bob', 'Johnson', 'bob@example.com', 'hashedpassword', 'host'),
(gen_random_uuid(), 'Carol', 'Davis', 'carol@example.com', 'hashedpassword', 'guest'),
(gen_random_uuid(), 'David', 'Brown', 'david@example.com', 'hashedpassword', 'host'),
(gen_random_uuid(), 'Eve', 'Miller', 'eve@example.com', 'hashedpassword', 'admin');

-- --------------------------
-- Properties
-- --------------------------
INSERT INTO Property (property_id, host_id, name, description, location, pricepernight)
VALUES
(gen_random_uuid(), (SELECT user_id FROM User WHERE email='bob@example.com'), 'Sea View Apartment', 'Beautiful apartment by the sea', 'Miami', 150.00),
(gen_random_uuid(), (SELECT user_id FROM User WHERE email='bob@example.com'), 'Mountain Cabin', 'Cozy cabin in the mountains', 'Denver', 120.00),
(gen_random_uuid(), (SELECT user_id FROM User WHERE email='david@example.com'), 'City Center Condo', 'Modern condo in downtown', 'New York', 200.00);

-- --------------------------
-- Bookings
-- --------------------------
INSERT INTO Booking (booking_id, property_id, user_id, start_date, end_date, total_price, status)
VALUES
(gen_random_uuid(), (SELECT property_id FROM Property WHERE name='Sea View Apartment'), 
 (SELECT user_id FROM User WHERE email='alice@example.com'),
 '2025-09-20', '2025-09-25', 750.00, 'confirmed'),

(gen_random_uuid(), (SELECT property_id FROM Property WHERE name='Mountain Cabin'), 
 (SELECT user_id FROM User WHERE email='carol@example.com'),
 '2025-10-05', '2025-10-10', 600.00, 'pending');

-- --------------------------
-- Payments
-- --------------------------
INSERT INTO Payment (payment_id, booking_id, amount, payment_method)
VALUES
(gen_random_uuid(), (SELECT booking_id FROM Booking LIMIT 1), 750.00, 'credit_card'),
(gen_random_uuid(), (SELECT booking_id FROM Booking OFFSET 1 LIMIT 1), 600.00, 'paypal');

-- --------------------------
-- Reviews
-- --------------------------
INSERT INTO Review (review_id, property_id, user_id, rating, comment)
VALUES
(gen_random_uuid(), (SELECT property_id FROM Property WHERE name='Sea View Apartment'),
 (SELECT user_id FROM User WHERE email='alice@example.com'), 5, 'Amazing stay!'),

(gen_random_uuid(), (SELECT property_id FROM Property WHERE name='Mountain Cabin'),
 (SELECT user_id FROM User WHERE email='carol@example.com'), 4, 'Very cozy, enjoyed the view.');

-- --------------------------
-- Messages
-- --------------------------
INSERT INTO Message (message_id, sender_id, recipient_id, message_body)
VALUES
(gen_random_uuid(),
 (SELECT user_id FROM User WHERE email='alice@example.com'),
 (SELECT user_id FROM User WHERE email='bob@example.com'),
 'Hello! Is the Sea View Apartment available next week?'),

(gen_random_uuid(),
 (SELECT user_id FROM User WHERE email='carol@example.com'),
 (SELECT user_id FROM User WHERE email='bob@example.com'),
 'Can you confirm the Mountain Cabin availability?');
