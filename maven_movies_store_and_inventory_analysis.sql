/*
Project: Maven Movies – Store, Inventory, and Revenue Analysis
Author: Kimberly Frock
Purpose: Evaluate store performance, inventory exposure, and customer value
*/



use mavenmovies;

/* 
SECTION 1: Store Overview
Objective:
My partner and I want to come by each of the stores in person and meet the managers. 
Please send over the managers’ names at each store, with the full address 
of each property (street address, district, city, and country please).  
*/ 
SELECT
	store.store_id AS store,
    staff.first_name AS manager_first_name,
    staff.last_name AS manager_last_name,
    address.address AS street_address,
    address.district AS district,
    city.city AS city,
    country.country AS country
FROM store
LEFT JOIN staff ON store.manager_staff_id = staff.staff_id
LEFT JOIN address ON store.address_id = address.address_id
LEFT JOIN city ON address.city_id = city.city_id
LEFT JOIN country ON city.country_id = country.country_id;


/* SECTION 2: Store performance scorecard
Objective: 
Store - level performance comparison. Which store is performing better? 
Revenue per inventory item, rentals per inventory item, average rental rate by store, revenue by month, rental count by month*/ 

SELECT
	i.store_id AS store,
    COUNT(DISTINCT r.rental_id) AS total_rentals,
    ROUND(SUM(p.amount),2) AS total_revenue,
    ROUND(AVG(f.rental_rate), 2) AS avg_rental_rate,
    COUNT(DISTINCT CASE WHEN c.active = 1 THEN c.customer_id END) AS active_spending_customers
    
FROM payment p
	INNER JOIN rental r
		ON p.rental_id = r.rental_id
	INNER JOIN inventory i
		ON r.inventory_id = i.inventory_id
	INNER JOIN film f
		ON i.film_id = f.film_id
	INNER JOIN customer c
		ON r.customer_id = c.customer_id
GROUP BY
	i.store_id
ORDER BY 
	total_revenue DESC;
    
-- Inventory size by store
SELECT
	store_id AS store,
    COUNT(inventory_id) AS inventory_count
FROM inventory
GROUP BY 
	store_id;

-- Monthly trends (rentals by month, revenue by month)
SELECT
	i.store_id AS store,
    DATE_FORMAT(p.payment_date, '%Y-%m') AS month,
    COUNT(DISTINCT r.rental_id) AS monthly_rentals,
    ROUND(SUM(p.amount), 2) AS monthly_revenue
FROM payment p 
	INNER JOIN rental r 
		ON p.rental_id = r.rental_id
	INNER JOIN inventory i 
		ON r.inventory_id = i.inventory_id
GROUP BY
	i.store_id,
    DATE_FORMAT(p.payment_date, '%Y-%m')
ORDER BY
	i.store_id,
    month;


	
/* SECTION 3: Inventory Detail
Objective:
I would like to get a better understanding of all of the inventory that would come along with the business. 
Please pull together a list of each inventory item you have stocked, including the store_id number, 
the inventory_id, the name of the film, the film’s rating, its rental rate and replacement cost. 
*/

SELECT
	i.store_id AS store,
    i.inventory_id AS stocked_inventory,
    f.title AS film_name,
    f.rating AS film_rating,
    f.rental_rate AS rental_rate,
    f.replacement_cost AS replacement_cost
FROM inventory i
	INNER JOIN film f
		ON i.film_id = f.film_id
ORDER BY i.store_id, i.inventory_id;




/* SECTION 4: Inventory summaries and exposure
Objective:
From the same list of films you just pulled, please roll that data up and provide a summary level overview 
of your inventory. We would like to know how many inventory items you have with each rating at each store. 
*/

SELECT
	i.store_id AS store,
    f.rating AS rating,
    COUNT(i.inventory_id) AS inventory_count
FROM film f 
	INNER JOIN inventory i 
		ON f.film_id = i.film_id
GROUP BY 
	i.store_id,
    f.rating
ORDER BY 
	i.store_id,
    f.rating;



/* 
Objective:
Similarly, we want to understand how diversified the inventory is in terms of replacement cost. We want to 
see how big of a hit it would be if a certain category of film became unpopular at a certain store.
We would like to see the number of films, as well as the average replacement cost, and total replacement cost, 
sliced by store and film category. 
*/ 

SELECT
	i.store_id,
    c.name AS category,
	COUNT(i.inventory_id) AS inventory_items,
    COUNT(DISTINCT i.film_id) AS distinct_films,
    ROUND(AVG(f.replacement_cost), 2) AS average_replacement_cost,
    ROUND(SUM(f.replacement_cost), 2) AS total_replacement_cost
FROM inventory i
	LEFT JOIN film f 
		ON f.film_id = i.film_id
	LEFT JOIN film_category fc
		ON i.film_id = fc.film_id
	LEFT JOIN category c
		ON fc.category_id = c.category_id

GROUP BY
	i.store_id,
    c.name
ORDER BY
	i.store_id,
    Total_Replacement_Cost DESC;


/* Objective:
category profitability proxy. Categories with high replacement costs but low rental volume, strong rental activity relative to asset value  */
SELECT
	i.store_id AS store_location,
    c.name AS category,
    COUNT(DISTINCT r.rental_id) AS total_rentals,
    SUM(p.amount) AS total_rental_revenue,
    ROUND(SUM(p.amount) / NULLIF(SUM(f.replacement_cost), 0), 2) AS revenue_per_inventory_dollar
FROM payment p
	INNER JOIN rental r
		ON p.rental_id = r.rental_id
	INNER JOIN inventory i
		ON r.inventory_id = i.inventory_id
	INNER JOIN film f 
		ON i.film_id = f.film_id
	INNER JOIN film_category fc
		ON i.film_id = fc.film_id
	INNER JOIN category c
		ON fc.category_id = c.category_id
GROUP BY 
	i.store_id,
    c.name
ORDER BY
	i.store_id,
    total_rental_revenue DESC,
    revenue_per_inventory_dollar DESC;



/* SECTION 5: Customer Analysis
Objective:
We want to make sure you folks have a good handle on who your customers are. Please provide a list 
of all customer names, which store they go to, whether or not they are currently active, 
and their full addresses – street address, city, and country. 
*/ 
SELECT
	c.store_id AS store,
    c.active AS active,
    c.first_name AS first_name,
    c.last_name AS last_name,
    a.address AS street_address,
    ci.city AS city,
    co.country AS country
FROM customer c
	LEFT JOIN address a
		ON c.address_id = a.address_id
	LEFT JOIN city ci
		ON ci.city_id = a.city_id
	LEFT JOIN country co
		ON co.country_id = ci.country_id
ORDER BY
	c.store_id,
    c.active;



/* Top customers / LTV
Objective:
We would like to understand how much your customers are spending with you, and also to know 
who your most valuable customers are. Please pull together a list of customer names, their total 
lifetime rentals, and the sum of all payments you have collected from them. It would be great to 
see this ordered on total lifetime value, with the most valuable customers at the top of the list. 
*/

SELECT 
	c.store_id AS store,
	c.first_name AS first_name,
    c.last_name AS last_name,
    COUNT(DISTINCT r.rental_id) AS lifetime_rentals,
    SUM(p.amount) AS total_payments
FROM customer c
	LEFT JOIN rental r
		ON c.customer_id = r.customer_id
	LEFT JOIN payment p
		ON r.rental_id = p.rental_id
GROUP BY 
	c.customer_id,
	c.store_id,
    c.first_name,
    c.last_name	
ORDER BY
	total_payments DESC,
    lifetime_rentals DESC;

    
/* SECTION 6: Governance
Objective:
My partner and I would like to get to know your board of advisors and any current investors.
Could you please provide a list of advisor and investor names in one table? 
Could you please note whether they are an investor or an advisor, and for the investors, 
it would be good to include which company they work with. 
*/

SELECT
	'Advisor' AS type,
    a.first_name AS first_name,
    a.last_name AS last_name,
    Null AS company
FROM advisor a

UNION ALL

SELECT
	'Investor' AS type,
	i.first_name AS first_name,
    i.last_name AS last_name,
    i.company_name AS company
FROM investor i
;




/* SECTION 7: Strategic content coverage
Objective:
We're interested in how well you have covered the most-awarded actors. 
Of all the actors with three types of awards, for what % of them do we carry a film?
And how about for actors with two types of awards? Same questions. 
Finally, how about actors with just one award? 
*/

WITH actor_enriched AS (
	SELECT
    aa.actor_id,
    
    -- normalize text
    LOWER(TRIM(aa.awards)) AS awards_norm,
    
    -- award-type flags
    CASE WHEN LOWER(aa.awards) LIKE '%emmy%' THEN 1 ELSE 0 END AS has_emmy,
    CASE WHEN LOWER(aa.awards) LIKE '%oscar%' THEN 1 ELSE 0 END AS has_oscar,
    CASE WHEN LOWER(aa.awards) LIKE '%tony%' THEN 1 ELSE 0 END AS has_tony,    
    
    -- do we carry at least one film with this actor?
    CASE
		WHEN aa.actor_id IS NULL THEN 0
        WHEN EXISTS(
			SELECT 1
            FROM film_actor fa
            JOIN inventory i ON i.film_id = fa.film_id
            WHERE fa.actor_id = aa.actor_id
		) THEN 1
        ELSE 0
		END AS carried_flag
	FROM actor_award aa
),
bucketed AS (
	SELECT 
		actor_id,
        (has_emmy + has_oscar + has_tony) AS award_type_count,
        carried_flag
	FROM actor_enriched
)
SELECT
	CASE
		WHEN award_type_count = 3 THEN '3 Awards'
        WHEN award_type_count = 2 THEN '2 Awards'
        WHEN award_type_count = 1 THEN '1 Award'
        ELSE '0 Awards'
	END AS number_of_awards,
    
    COUNT(DISTINCT actor_id) AS actors_in_bucket,
    SUM(carried_flag) AS actors_with_film_carried,
    ROUND((AVG(carried_flag)) *100, 0) AS pct_of_actors_we_carry
FROM bucketed
GROUP BY 
	CASE
		WHEN award_type_count = 3 THEN '3 Awards'
        WHEN award_type_count = 2 THEN '2 Awards'
        WHEN award_type_count = 1 THEN '1 Award'
        ELSE '0 Awards'
	END
ORDER BY
	number_of_awards DESC;















