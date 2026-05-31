USE BikeStores

create synonym o for sales.orders
create synonym c for sales.customers
create synonym s for sales.stores
create synonym stf for sales.staffs
create synonym oi for sales.order_items
create synonym p for production.products
create synonym ctg for production.categories
create synonym stc for production.stocks
create synonym b for production.brands

-- Case Study 1. Find customers who have placed orders in every single store available in the database.
Create table customers(
CName nvarchar(100));
GO
INSERT INTO customers
SELECT CONCAT(first_name,' ', last_name) [Customer]
FROM  o INNER JOIN sales.customers c
ON o.customer_id = c.customer_id
group by CONCAT(first_name,' ', last_name)
having count(store_id) = (
	SELECT COUNT (store_id)
	FROM s
)
-----------------------------------------
-----------------------------------------
-- Case Study 2. For each store, show the maximum total sales amount among all orders.
CREATE TABLE NewStores(
storeID INT Primary key,
MaxValue Float)

INSERT INTO NewStores
SELECT store_id, MAX(totalSales) 
FROM (
	SELECT store_id,o.order_id as orderID,SUM((quantity*list_price)*(1-discount)) as totalSales
	FROM oi inner join o
	ON o. order_id = oi.order_id
	group by store_id, o.order_id
)t 
GROUP BY store_id

---------------------------------------------------------------------
---------------------------------------------------------------------
--Case Study 3. List the brands that do not have any product with a list_price less than $500.
CREATE TABLE LowBrands(
brandname nvarchar(50)
)

INSERT INTO LowBrands
SELECT brand_name
FROM b
JOIN p
ON b.brand_id = p.brand_id
GROUP BY brand_name
HAVING MIN(list_price) > 500;

------------------------------------
------------------------------------
-- Case Study 4. List customers who have bought the exact same product in two or more different orders.
CREATE TABLE CustDiffProduct(
Cname nvarchar(50),
PID INT,
#Orders INT
)
INSERT INTO CustDiffProduct
select first_name, product_id, COUNT(item_id)
from c INNER JOIN o 
ON c.customer_id = o.customer_id
INNER JOIN oi 
ON o.order_id = oi.order_id
group by first_name, product_id
HAVING COUNT(item_id) >= 2

-------------------------------------------------------
-- Case Study 5. Find categories that contribute more than 20% of the total company revenue
CREATE TABLE SpecialCtgr(
CName nvarchar(50),
salesPrec float
)

INSERT INTO SpecialCtgr
SELECT category_name, [SalesPrecentage]
FROM 
(SELECT category_name, 
SUM((quantity*oi.list_price)*(1-discount))/
(SELECT SUM((quantity*oi.list_price)*(1-discount)) FROM oi) * 100.0 [SalesPrecentage]
FROM ctg INNER JOIN p
ON ctg.category_id = p.category_id
INNER JOIN oi 
ON P.product_id = oi.product_id
GROUP BY category_name) t
WHERE [SalesPrecentage] > 20

-------------------------------------
-- Case Study 6. Find the order_id that contains products from the highest number of different categoriess
CREATE TABLE ORDRCTGR(
OrderID INT Primary key,
#catg int
)
INSERT INTO ORDRCTGR
SELECT TOP 1 order_id, COUNT(DISTINCT category_id)  #Categories
FROM oi INNER JOIN p
ON P.product_id = oi.product_id
GROUP BY order_id
ORDER BY #Categories DESC
------------------------------------------------------------------
------------------------------------------------------------------
-- Case Study 7. Find pairs of products that are frequently bought together in the same order (show top 5 pairs).
CREATE TABLE PaireProducts(
product1 int, 
product2 int, 
TBT INT
)

INSERT INTO PaireProducts
SELECT TOP 5 oi1.product_id AS Product1,
       oi2.product_id AS Product2,
       COUNT(*) AS TimesBoughtTogether
FROM oi oi1
INNER JOIN oi oi2
ON oi1.order_id = oi2.order_id
AND oi1.product_id < oi2.product_id
GROUP BY oi1.product_id,oi2.product_id
ORDER BY TimesBoughtTogether DESC;
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--Case Study 8. Which store has the longest average delay between the order_date and the shipped_date?
CREATE TABLE StoresDelay(
SName nvarchar(50),
AvgDelay int
)

INSERT INTO StoresDelay
SELECT TOP 1 store_name, AVG(DATEDIFF(DAY,order_date,shipped_date)) AvgDelay
FROM s INNER JOIN o
ON s.store_id = o.store_id
GROUP BY store_name
ORDER BY AvgDelay Desc

----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
--Case Study 9. Find orders where a product was sold with a discount higher than the average discount for that specific product's category
CREATE TABLE OrderBiggerAvgDisc(
OrderID int primary key
)

INSERT INTO OrderBiggerAvgDisc
SELECT DISTINCT order_id
FROM p INNER JOIN
(SELECT category_id, AVG(discount) AVGDiscount
FROM oi oi2 INNER JOIN p p2
ON oi2.product_id = p2.product_id
GROUP BY category_id) t 
ON p.category_id = t.category_id
INNER JOIN oi 
ON oi.product_id = p.product_id
WHERE discount > AVGDiscount

 ------------------------------------------------------------------------------ 
-------------------------------------------------------------------------------
--Case Study 10. Find the name of the staff member who ranks 3rd in the number of orders processed.
CREATE TABLE thirdStaff(
SName nvarchar(50),
#orders int
)
INSERT INTO thirdStaff
SELECT top 3 first_name, #Orders
FROM 
(SELECT top 3 first_name, COUNT(order_id) #Orders
FROM stf INNER JOIN o
ON stf.staff_id = o.staff_id
GROUP BY first_name
ORDER BY #Orders DESC) T
ORDER BY #Orders

