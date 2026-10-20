
DROP TABLE IF EXISTS zepto;

CREATE TABLE zepto (
    sku_id SERIAL PRIMARY KEY,
    category VARCHAR(120),
    name VARCHAR(150) NOT NULL,
    mrp NUMERIC(8,2),
    discountPercent NUMERIC(5,2),
    availableQuantity INTEGER,
    discountedSellingPrice NUMERIC(8,2),
    weightInGms INTEGER,
    outOfStock BOOLEAN,    
    quantity INTEGER
);


-- DATA EXPLORATION


-- Q1. Total rows in the dataset
SELECT COUNT(*) FROM zepto;

-- Q2. Peek at sample data
SELECT * FROM zepto LIMIT 10;

-- Q3. Check if any NULL values exist
SELECT * FROM zepto
WHERE name IS NULL
   OR category IS NULL
   OR mrp IS NULL
   OR discountPercent IS NULL
   OR discountedSellingPrice IS NULL
   OR weightInGms IS NULL
   OR availableQuantity IS NULL
   OR outOfStock IS NULL
   OR quantity IS NULL;

-- Q4. Unique product categories
SELECT DISTINCT category
FROM zepto
ORDER BY category;

-- Q5. In-stock vs Out-of-stock product counts
SELECT outOfStock, COUNT(sku_id)
FROM zepto
GROUP BY outOfStock;

-- Q6. Detect duplicate product names
SELECT name, COUNT(sku_id) AS "Number of SKUs"
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY COUNT(sku_id) DESC;

-------------------------------------
-- DATA CLEANING
-------------------------------------

-- Q7. Products with invalid prices
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0;

DELETE FROM zepto
WHERE mrp = 0;

-- Q8. Convert prices from paise to rupees
UPDATE zepto
SET mrp = mrp / 100.0,
    discountedSellingPrice = discountedSellingPrice / 100.0;

-- DATA ANALYSIS


-- Q9. Which are the top 10 products with highest discount?
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;

-- Q10. High MRP products that are out of stock
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = TRUE AND mrp > 300
ORDER BY mrp DESC;

-- Q11. Total estimated revenue by category
SELECT category,
       SUM(discountedSellingPrice * availableQuantity) AS total_revenue
FROM zepto
GROUP BY category
ORDER BY total_revenue DESC;

-- Q12. Products with MRP above 500 but discount < 10%
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC;

-- Q13. Top 5 categories with highest average discount %
SELECT category,
       ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY category
ORDER BY avg_discount DESC
LIMIT 5;

-- Q14. Price per gram for products above 100g
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
       ROUND(discountedSellingPrice/weightInGms,2) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q15. Classify products into weight categories
SELECT DISTINCT name, weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
     WHEN weightInGms < 5000 THEN 'Medium'
     ELSE 'Bulk'
END AS weight_category
FROM zepto;

-- Q16. Total inventory weight per category
SELECT category,
       SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight DESC;

-- Q17. Which categories contribute the most to total stock value (MRP)?
SELECT category,
       SUM(mrp * availableQuantity) AS stock_value
FROM zepto
GROUP BY category
ORDER BY stock_value DESC;

-- Q18. Top 5 most expensive products (based on MRP)
SELECT name, mrp
FROM zepto
ORDER BY mrp DESC
LIMIT 5;

-- Q19. Average discount per product (not just category)
SELECT name,
       ROUND(AVG(discountPercent),2) AS avg_discount
FROM zepto
GROUP BY name
ORDER BY avg_discount DESC;

-- Q20. Products with huge stock but low discounts (slow-moving risk)
SELECT name, availableQuantity, discountPercent
FROM zepto
WHERE availableQuantity > 500 AND discountPercent < 5
ORDER BY availableQuantity DESC;

-- Q21. Category with maximum number of SKUs
SELECT category, COUNT(sku_id) AS num_skus
FROM zepto
GROUP BY category
ORDER BY num_skus DESC;

s 