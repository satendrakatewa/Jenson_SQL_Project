# Question 1:- Find the total number of products sold by each store along with the store name.

SELECT s.store_name, SUM(oi.quantity) AS total_sold  
FROM stores s  
JOIN orders o ON s.store_id = o.store_id  
JOIN order_items oi ON oi.order_id = o.order_id  
GROUP BY s.store_name;









# Question 2:- Calculate the cumulative sum of quantities sold for each product over time.

WITH cte AS (  
    SELECT p.product_name, o.order_date, oi.quantity  
    FROM products p  
    JOIN order_items oi ON p.product_id = oi.product_id  
    JOIN orders o ON oi.order_id = o.order_id  
)  
SELECT *,  
       SUM(quantity) OVER (PARTITION BY product_name ORDER BY order_date DESC) AS cum_qty  
FROM cte;





# Question 3:- Find the product with the highest total sales (quantity * price) for each category.

WITH sales_data AS (
    SELECT c.category_name, p.product_name, 
           SUM(oi.quantity * oi.list_price) AS total_sales
    FROM categories c
    JOIN products p ON c.category_id = p.category_id
    JOIN order_items oi ON oi.product_id = p.product_id
    GROUP BY c.category_name, p.product_name
)
SELECT * FROM (
    SELECT *, DENSE_RANK() OVER (PARTITION BY category_name ORDER BY total_sales DESC) AS rnk 
    FROM sales_data
) ranked_sales
WHERE rnk = 1;

# Question 4:- Find the customer who spent the most money on orders.

SELECT c.customer_id,  
       CONCAT(c.first_name, ' ', c.last_name) AS full_name,  
       SUM(oi.quantity * oi.list_price) AS sales  
FROM customers c  
JOIN orders o ON c.customer_id = o.customer_id  
JOIN order_items oi ON oi.order_id = o.order_id  
GROUP BY 1, 2  
ORDER BY sales DESC  
LIMIT 1;


# Question 5:- Find the highest-priced product for each category name.

SELECT c.customer_id,  
       CONCAT(c.first_name, ' ', c.last_name) AS full_name,  
       SUM(oi.quantity * oi.list_price) AS sales  
FROM customers c  
JOIN orders o ON c.customer_id = o.customer_id  
JOIN order_items oi ON oi.order_id = o.order_id  
GROUP BY c.customer_id, full_name  
ORDER BY sales DESC;

# Question 6:- Find the total number of orders placed by each customer per store.

SELECT c.customer_id,  
       c.first_name,  
       s.store_name,  
       COUNT(o.order_id) AS no_of_orders  
FROM customers c  
LEFT JOIN orders o ON c.customer_id = o.customer_id  
JOIN stores s ON s.store_id = o.store_id  
GROUP BY c.customer_id, c.first_name, s.store_name;

# Question 7:- Find the names of staff members who have not made any sales.

SELECT s.staff_id,  
       CONCAT(s.first_name, ' ', s.last_name) AS staff_full_name,  
       o.order_id  
FROM staffs s  
LEFT JOIN orders o ON s.staff_id = o.staff_id  
WHERE o.order_id IS NULL;


# Question 8:- Find the top 3 most sold products in terms of quantity.

SELECT oi.product_id, p.product_name,  
       SUM(oi.quantity) AS total_quantity_sold  
FROM order_items oi  
JOIN products p ON oi.product_id = p.product_id  
GROUP BY oi.product_id, p.product_name  
ORDER BY total_quantity_sold DESC  
LIMIT 3;



# Question 9:- Find the median value of the price list. 

WITH a AS (
    SELECT list_price, 
           ROW_NUMBER() OVER (ORDER BY list_price) AS rn,
           COUNT(*) OVER() AS n 
    FROM products
)
SELECT CASE
    WHEN MOD(n, 2) = 0 
        THEN (SELECT AVG(list_price) FROM a WHERE rn IN (n/2, (n/2) + 1))
    ELSE 
        (SELECT list_price FROM a WHERE rn = (n + 1) / 2)
END AS median
FROM a 
LIMIT 1;


# Question 10:- List all products that have never been ordered.(use Exists).


SELECT p.product_name  
FROM products p  
WHERE NOT EXISTS (  
    SELECT 1 FROM order_items oi  
    WHERE oi.product_id = p.product_id  
);


# Question 11:- List the names of staff members who have made more sales than the average number of sales by all staff members.

WITH sales_data AS (
    SELECT s.staff_id, s.first_name, 
           COALESCE(SUM(oi.quantity * oi.list_price), 0) AS sales
    FROM staffs s  
    LEFT JOIN orders o ON s.staff_id = o.staff_id  
    LEFT JOIN order_items oi ON o.order_id = oi.order_id  
    GROUP BY s.staff_id, s.first_name  
)  
SELECT * FROM sales_data WHERE sales > (SELECT AVG(sales) FROM sales_data);



# Question 12:- Identify the customers who have ordered all types of products (i.e., from every category).


SELECT c.customer_id, c.first_name,  
       COUNT(oi.product_id) AS total_orders  
FROM customers c  
JOIN orders o ON c.customer_id = o.customer_id  
JOIN order_items oi ON o.order_id = oi.order_id  
JOIN products p ON p.product_id = oi.product_id  
GROUP BY c.customer_id, c.first_name  
HAVING COUNT(DISTINCT p.category_id) = (SELECT COUNT(*) FROM categories);





