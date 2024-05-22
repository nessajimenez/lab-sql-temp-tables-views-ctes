USE sakila;

-- First, create a view that summarizes rental information for each customer. 
-- The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
CREATE VIEW rental_info AS
	SELECT customer.customer_id AS Customer_ID, 
	CONCAT(first_name, ' ', last_name) AS Customer_Name, 
    email AS Customer_Email,
    COUNT(rental_id) AS Rental_Count
FROM customer
JOIN rental
ON rental.customer_id = customer.customer_id
GROUP BY customer.customer_id;

SELECT *
FROM rental_info;

-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). 
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and 
-- calculate the total amount paid by each customer.
CREATE TEMPORARY TABLE sakila.total_paid
SELECT rental_info.Customer_ID AS customer_id,
	rental_info.Customer_Name AS customer_name,
	rental_info.Rental_Count AS rental_count,
    SUM(payment.amount) AS total_paid
FROM rental_info
JOIN payment
ON payment.customer_id =rental_info.Customer_ID
GROUP BY rental_info.Customer_ID;

SELECT *
FROM sakila.total_paid;

-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. 
-- The CTE should include the customer's name, email address, rental count, and total amount paid.
WITH customer_rentals AS(
						SELECT rental_info.Customer_Name AS customer_name,
							rental_info.Customer_Email AS customer_email,
							rental_info.Rental_Count AS rental_count,
							sakila.total_paid.total_paid AS total_paid
						FROM rental_info
						JOIN sakila.total_paid
						ON rental_info.Customer_ID = total_paid.customer_id)
SELECT *
FROM customer_rentals;

-- using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, 
-- total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.

WITH customer_rentals AS(
						SELECT rental_info.Customer_Name AS customer_name,
							rental_info.Customer_Email AS customer_email,
							rental_info.Rental_Count AS rental_count,
							sakila.total_paid.total_paid AS total_paid
						FROM rental_info
						JOIN sakila.total_paid
						ON rental_info.Customer_ID = total_paid.customer_id)
SELECT customer_name AS customer,
		customer_email AS email,
        rental_count AS amount_of_rentals,
        total_paid AS total_paid_for_rentals,
        ROUND(total_paid/rental_count,2) AS average_payment_per_rental
FROM customer_rentals;