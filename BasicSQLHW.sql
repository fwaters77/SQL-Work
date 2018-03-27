USE sakila;

# 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name
FROM actor
LIMIT 10;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(UCASE(first_name), " ", UCASE(last_name)) as 'Actor Name'
FROM actor
LIMIT 10;

# 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name
FROM actor
WHERE first_name = 'Joe';

# 2b. Find all actors whose last name contain the letters GEN:
SELECT *
FROM actor
WHERE last_name LIKE '%gen%';

# 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT *
FROM actor
WHERE last_name LIKE '%LI%'
ORDER BY last_name, first_name;

# 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT *
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

# 3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor
ADD COLUMN middle_name VARCHAR(30) 
AFTER first_name;

# 3b. You realize that some of these actors have tremendously long last names. Change the data type of the middle_name column to blobs
ALTER TABLE actor
MODIFY middle_name BLOB;

# 3c. Now delete the middle_name column.
ALTER TABLE actor
DROP middle_name;

# 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(last_name) AS 'Number of Actors'
FROM actor
GROUP BY last_name; 

# 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(last_name) AS 'Number of Actors'
FROM actor
GROUP BY last_name
HAVING COUNT(last_name) > 1;

# 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'WILLIAMS';

# 4d. Perhaps we were too hasty in changing GROUCHO to HARPO
UPDATE actor
SET first_name = CASE
WHEN first_name = 'HARPO'
THEN 'GROUCHO'
ELSE 'MUCHOGROUCHO'
END
WHERE actor_id = 172;

# 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW COLUMNS from sakila.address;
SHOW CREATE TABLE sakila.address;

# 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT first_name, last_name, address FROM staff
INNER JOIN address ON staff.address_id = address.address_id;

# 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT staff.staff_id, first_name, last_name, SUM(amount) as 'Total Amount Rung Up'
FROM staff
INNER JOIN payment ON staff.staff_id = payment.staff_id
GROUP BY staff_id;

# 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT film.title, COUNT(film_actor.actor_id) AS 'Number of Actors'
From film
INNER JOIN film_actor ON film.film_id = film_actor.film_id
GROUP BY film.film_id; 

# 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, COUNT(inventory.inventory_id) as 'Number of Actors'
FROM film
INNER JOIN inventory ON film.film_id = inventory.film_id
GROUP BY film.film_id
HAVING title = 'Hunchback Impossible';

# 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.last_name, customer.first_name, SUM(payment.amount) as 'Total Paid'
FROM customer
INNER JOIN payment ON customer.customer_id = payment.customer_id
GROUP BY payment.customer_id
ORDER BY last_name, first_name;

# 7a. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT title 
FROM film
WHERE language_id IN (SELECT language_id FROM language WHERE name = 'English')
AND (title LIKE 'K%') OR (title LIKE 'Q%');

#  7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name
FROM actor
WHERE actor_id IN
(
SELECT actor_id 
FROM film_actor
WHERE film_id IN
(
SELECT film_id
FROM film
WHERE title = 'Alone Trap'));

# 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

SELECT customer.first_name, customer.last_name, customer.email, country.country
FROM customer
LEFT JOIN address
ON customer.address_id = address.address_id
LEFT JOIN city
ON city.city_id = address.city_id
LEFT JOIN country
ON country.country_id = city.country_id
WHERE country = 'Canada';

# 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as famiy films.

SELECT *
FROM film
WHERE film_id IN
(
SELECT film_id
FROM film_category
WHERE category_id IN
(
SELECT category_id
FROM category
WHERE name = 'Family'));

# 7e. Display the most frequently rented movies in descending order.

SELECT film.title , COUNT(rental.rental_id) AS 'Number of Rentals'
FROM film
RIGHT JOIN inventory
ON film.film_id = inventory.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
GROUP BY film.title
ORDER BY COUNT(rental.rental_id) DESC;

# 7f. Write a query to display how much business, in dollars, each store brought in.

SELECT store.store_id, SUM(amount) as 'Revenue'
FROM store
RIGHT JOIN staff
ON store.store_id = staff.store_id
LEFT JOIN payment
ON staff.staff_id = payment.staff_id
GROUP BY store.store_id;

# 7g. Write a query to display for each store its store ID, city, and country.

SELECT store.store_id, city.city, country.country
FROM store
JOIN address
ON store.address_id = address.address_id
JOIN city
ON address.city_id = city.city_id
JOIN country
ON city.country_id = country.country_id;

# 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

SELECT category.name, sum(payment.amount) as 'Revenue per Category'
FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
JOIN payment
ON payment.rental_id = rental.rental_id
GROUP BY name
ORDER BY COUNT('Revenue per Category')DESC
LIMIT 5;

# 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW top_five_by_genre AS
SELECT category.name, sum(payment.amount) as 'Revenue per Category'
FROM category
JOIN film_category
ON category.category_id = film_category.category_id
JOIN inventory
ON film_category.film_id = inventory.film_id
JOIN rental
ON rental.inventory_id = inventory.inventory_id
JOIN payment
ON payment.rental_id = rental.rental_id
GROUP BY name
ORDER BY COUNT('Revenue per Category')DESC
LIMIT 5;

# 8b. How would you display the view that you created in 8a?
SELECT *
FROM top_five_by_genre;

# 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_five_by_genre;






