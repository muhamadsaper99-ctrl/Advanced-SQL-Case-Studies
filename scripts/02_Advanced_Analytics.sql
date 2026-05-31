-- 1.Generate a monthly revenue report per store including the Running Total 
--and a comparison with the previous month and  Categorize the trend as "Growth" or "Decline"

WITH MonthRevenue AS (
SELECT 
	store_name,
	YEAR(o.order_date) Y,
	MONTH(o.order_date)M,
	SUM((list_price*quantity)*(1-discount)) [Revenue]
FROM s INNER JOIN o
ON s.store_id = o.store_id
INNER JOIN oi 
ON o.order_id = oi.order_id
GROUP BY store_name,
	YEAR(o.order_date),
	MONTH(o.order_date)
)

SELECT *, 
	SUM(Revenue) OVER (PARTITION BY Store_name ORDER BY y, m)[Running Total],
	LAG(Revenue) OVER (PARTITION BY Store_name ORDER BY y, m)[Previous Month],
	Case 
		WHEN Revenue > 
			LAG(Revenue) OVER (PARTITION BY Store_name ORDER BY y, m)
			THEN 'Growth'
		WHEN Revenue < 
			LAG(Revenue) OVER (PARTITION BY Store_name ORDER BY y, m)
		THEN 'Decline'
		ELSE 'No Change'
	END AS [Trend]
FROM MonthRevenue
ORDER BY y, M, store_name
GO

--------------------------------------------------------------------
--2.Calculate the average shipping duration  per store. Rank stores by speed and calculate the 
--"Time Gap" between each store and the fastest performer in the company
WITH AvgShipping AS (
SELECT store_name, AVG(DATEDIFF(DAY,order_date,shipped_date)) [AvgShippingdays]
FROM s INNER JOIN o
ON s.store_id = o.store_id
GROUP BY store_name
)
SELECT *,
	DENSE_RANK() OVER (ORDER BY Avgshippingdays ) [Fasteset Store Rank],
	AvgShippingdays - 
		MIN(AvgShippingdays) OVER(ORDER BY AvgShippingdays) [Time Gap]

FROM AvgShipping
Go

---------------------------------------------------------------------------------
--3.Identify the maximum "Dry Period" (days with no orders) for each store and compare it to the
--store's average inter-order interval to detect operational anomalies
WITH DryPeriods AS (
SELECT store_name, order_id, order_date,
	LAG(order_date) OVER(PARTITION BY store_name order by order_date) [PrevOrderDate]
FROM s INNER JOIN o
ON s.store_id = o.store_id
),

dryDays AS
(SELECT store_name, order_id,order_date, PrevOrderDate,
	DATEDIFF(DAY,PrevOrderDate, order_date) [Dry_Period]
FROM DryPeriods

)
SELECT store_name, AVG(Dry_Period)[StoreAvgDryDay], MAX(Dry_Period)[MaxDryPeriod] 
FROM dryDays
GROUP BY store_name
GO

------------------------------------------------------------------------------------
-- 4.Identify product categories that have active stock in a store but have recorded
--zero sales in the last 6 months

SELECT DISTINCT stc.store_id, category_name
FROM stc INNER JOIN p
ON stc.product_id = p.product_id
INNER JOIN ctg
ON p.category_id = ctg.category_id
LEFT JOIN (
    SELECT o.store_id, p.category_id
    FROM o INNER JOIN oi
    ON o.order_id = oi.order_id
    INNER JOIN p
    ON oi.product_id = p.product_id
    WHERE o.order_date >= DATEADD(MONTH, -6, GETDATE()) 
)t
ON stc.store_id = t.store_id
AND p.category_id = t.category_id
WHERE stc.quantity > 0
AND t.category_id IS NULL


GO

--------------------------------------------------------------------
--5.Identify staff members who demonstrated a "Consistent Growth Pattern" by increasing
--their sales month-over-month for an entire Fiscal Quarter
WITH Sales AS (
SELECT first_name, 
	YEAR(order_date) y,
	DATEPART(QUARTER, order_date) q,
	MONTH(order_date) m,
	SUM((list_price* quantity)*(1-discount)) AS CurrentSales
FROM stf INNER JOIN o
ON stf.staff_id = o.staff_id
INNER JOIN oi 
ON o.order_id = oi.order_id
GROUP BY first_name,YEAR(order_date), DATEPART(QUARTER, order_date), MONTH(order_date) 
),
PrevSales AS (
SELECT *,
	LAG(CurrentSales) OVER(PARTITION BY first_name,y, q ORDER BY y,m ) PrevSales
FROM Sales),

StatusCTE AS (SELECT *,
	case 
	 WHEN CurrentSales > PrevSales 
	 THEN 1
	 ELSE 0
	 END AS Status
FROM PrevSales
),

Growth AS (
SELECT first_name, y, q,
	SUM(status) as GrowthCount
FROM StatusCTE
GROUP BY  first_name, y, q
)
SELECT * FROM Growth 
WHERE GrowthCount = 2
GO

---------------------------------------------------------------------
-- 6.Identify staff members handling order volumes significantly higher than their store's average.

WITH StaffOrders AS 
(SELECT o.store_id,first_name, COUNT(order_id) OrderVolumes
FROM stf INNER JOIN o
ON stf.staff_id = o.staff_id
GROUP BY o.store_id,first_name 
),

StoreAvg AS
(SELECT *, 
	AVG(OrderVolumes) OVER (PARTITION BY store_id ) [AvgStoreVolume]
FROM StaffOrders)
SELECT * FROM StoreAvg
WHERE OrderVolumes > AvgStoreVolume
GO

-------------------------------------------------------------------------------
-- 7.Identify the dominant product category in each store and calculate its percentage share relative
--to the total sales of that same category across all stores.
WITH Sales AS(
SELECT store_name, category_id, 
	SUM((oi.list_price * quantity)*(1- discount)) TotalSales
FROM p INNER JOIN oi
ON P.product_id = oi.product_id
INNER JOIN o
ON o.order_id = oi.order_id
INNER JOIN s
ON s.store_id = o.store_id
GROUP BY store_name, category_id
),
Ranking AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY store_name ORDER BY TotalSales Desc) RN
FROM Sales
),

CatSales AS ( 
SELECT category_id,
    SUM((oi.list_price * quantity)*(1-discount)) AS CategorySales
FROM p INNER JOIN oi
ON p.product_id = oi.product_id
GROUP BY category_id)

SELECT store_name, R.category_id, 
	FORMAT((TotalSales / CategorySales) * 100,'N2') AS SharePrecent 
FROM Ranking r INNER JOIN CatSales c
ON r.category_id = c.category_id
WHERE RN =1 
GO

---------------------------------------------------------------------
-- 8.Compare each staff member's sales against the average sales of all other employees in the same store
--(excluding the employee themselves) to calculate the Performance Gap.
WITH StaffSales AS
(
SELECT o.store_id, staff_id,
	SUM((list_price * quantity)*(1-discount)) EmplyeeSales
FROM o INNER JOIN oi
ON o.order_id = oi.order_id
GROUP BY o.store_id, staff_id
),

StoreStats AS
(
SELECT *,
	SUM(EmplyeeSales) OVER(PARTITION BY store_id) StoreTotalSales,
	COUNT(staff_id) OVER(PARTITION BY store_id) EmployeeCount
FROM StaffSales)

SELECT store_id, staff_id, EmplyeeSales,
	(StoreTotalSales - EmplyeeSales) / (EmployeeCount -1) AS AvgOtherEmployeesSales,
	EmplyeeSales -((StoreTotalSales - EmplyeeSales) / (EmployeeCount -1)) AS PerformanceGap
FROM StoreStats
GO

----------------------------------------------------------------------------------

-- 9. Identify the top-selling brand for each store. Then, calculate the percentage of its sales
--relative to the total sales of the same brand across all other stores.

WITH BrandSalesStoreCTE AS(
SELECT store_id, brand_name,
	SUM((oi.list_price*quantity)*(1-discount)) [BrandSalesStore]
FROM b INNER JOIN p 
ON b.brand_id = p.brand_id
INNER JOIN oi
ON p.product_id = oi.product_id
INNER JOIN o 
ON o.order_id = oi.order_id
GROUP BY store_id, brand_name
),
Ranking AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY Store_id ORDER BY BrandSalesStore Desc) RN
FROM BrandSalesStoreCTE
),
BrandSalesCTE AS
( SELECT brand_name,
	SUM(BrandSalesStore) [BrandSales]
FROM Ranking
GROUP BY brand_name 
)

SELECT store_id, r.brand_name,
	(BrandSalesStore / BrandSales * 100) AS [Market Share]
FROM Ranking r INNER JOIN BrandSalesCTE Bs
ON r.brand_name = Bs.brand_name
WHERE RN =1
ORDER BY store_id

-- 10.Classify stores based on the count of active staff. Criteria: Understaffed (< 3), 
--Optimal (3-5), and Overstaffed (> 5)
WITH StoreClassify AS 
(SELECT Store_id, 
	Count(staff_id) NoStaff
FROM stf
WHERE active = 1
GROUP BY store_id
)
SELECT *,
	CASE 
		WHEN NoStaff < 3 
			THEN 'Understaffed'
		WHEN NoStaff >= 3 AND NoStaff <= 5
			THEN 'Optimal'
		ELSE 'Overstaffed'
	END AS StoreClassiffication
FROM StoreClassify

