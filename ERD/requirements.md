# Airbnb Database - Entity Relationship Diagram (ERD)

This document describes the entities, attributes, and relationships for the Airbnb-like database designed for the DataScape project.

---

## **Entities and Attributes**

### **User**
- `user_id` (UUID, Primary Key)
- `first_name` (VARCHAR, NOT NULL)
- `last_name` (VARCHAR, NOT NULL)
- `email` (VARCHAR, UNIQUE, NOT NULL)
- `password_hash` (VARCHAR, NOT NULL)
- `phone_number` (VARCHAR, NULL)
- `role` (ENUM: guest, host, admin, NOT NULL)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### **Property**
- `property_id` (UUID, Primary Key)
- `host_id` (UUID, Foreign Key → User.user_id)
- `name` (VARCHAR, NOT NULL)
- `description` (TEXT, NOT NULL)
- `location` (VARCHAR, NOT NULL)
- `pricepernight` (DECIMAL, NOT NULL)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- `updated_at` (TIMESTAMP, ON UPDATE CURRENT_TIMESTAMP)

### **Booking**
- `booking_id` (UUID, Primary Key)
- `property_id` (UUID, Foreign Key → Property.property_id)
- `user_id` (UUID, Foreign Key → User.user_id)
- `start_date` (DATE, NOT NULL)
- `end_date` (DATE, NOT NULL)
- `total_price` (DECIMAL, NOT NULL)
- `status` (ENUM: pending, confirmed, canceled, NOT NULL)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### **Payment**
- `payment_id` (UUID, Primary Key)
- `booking_id` (UUID, Foreign Key → Booking.booking_id)
- `amount` (DECIMAL, NOT NULL)
- `payment_date` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)
- `payment_method` (ENUM: credit_card, paypal, stripe, NOT NULL)

### **Review**
- `review_id` (UUID, Primary Key)
- `property_id` (UUID, Foreign Key → Property.property_id)
- `user_id` (UUID, Foreign Key → User.user_id)
- `rating` (INT, 1–5, NOT NULL)
- `comment` (TEXT, NOT NULL)
- `created_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

### **Message**
- `message_id` (UUID, Primary Key)
- `sender_id` (UUID, Foreign Key → User.user_id)
- `recipient_id` (UUID, Foreign Key → User.user_id)
- `message_body` (TEXT, NOT NULL)
- `sent_at` (TIMESTAMP, DEFAULT CURRENT_TIMESTAMP)

---

## **Relationships**

- **User → Booking:** One user can make many bookings.  
- **Property → Booking:** One property can have many bookings.  
- **Booking → Payment:** One booking has one payment.  
- **Property → Review:** One property can have many reviews.  
- **User → Review:** One user can write many reviews.  
- **User → Message:** One user can send and receive many messages.  
- **Property → User (Host):** One property is hosted by one user (host).

---

## **Notes**
- Primary keys (PK) uniquely identify each entity.  
- Foreign keys (FK) ensure referential integrity between related entities.  
- This ERD is designed to satisfy **3NF**, minimizing redundancy while supporting real-world Airbnb functionality.  
