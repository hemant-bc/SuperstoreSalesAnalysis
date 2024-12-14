use superstore;

select * from orders;

/*
What are the total sales, profit, and quantity sold by:
Region
Category
Sub-Category
Customer segment?
*/

select 
	Region,
    sum(sales) as total_sales,
    sum(profit) as total_profit,
    sum(quantity) as total_quantity
from orders
group by region
order by total_sales DESC;
-- --
select 
	Category,
    sum(sales) as total_sales,
    sum(profit) as total_profit,
    sum(quantity) as total_quantity
from orders
group by Category
order by total_sales DESC;

-- --
select 
	segment as customer_segment,
    sum(sales) as total_sales,
    sum(profit) as total_profit,
    sum(quantity) as total_quantity
from orders
group by Segment
order by total_sales DESC;

-- --
select 
	Sub_Category,
    sum(sales) as total_sales,
    sum(profit) as total_profit,
    sum(quantity) as total_quantity
from orders
group by Sub_Category
order by total_sales DESC;
-- --

SELECT 
    Region,
    Category,
    Sub_Category,
    Segment AS Customer_Segment,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    SUM(Quantity) AS Total_Quantity
FROM orders
GROUP BY 
    Region, 
    Category, 
    Sub_Category, 
    Segment
ORDER BY 
    Region, 
    Category, 
    Sub_Category, 
    Customer_Segment;

-- Which are the top 10 cities in terms of sales and profit?
SELECT 
	CITY,
    sum(SALES) AS TOTAL_SALES,
    sum(PROFIT) AS TOTAL_PROFIT
FROM orders
group by CITY
order by TOTAL_SALES AND TOTAL_PROFIT DESC
LIMIT 10;

/* 2. Returns Analysis
What percentage of total orders were returned?
Which products, categories, or regions have the highest return rates?
How do returns impact overall profitability? */

SELECT 
    (COUNT(DISTINCT pr.Order_ID) * 100.0 / COUNT(DISTINCT o.Order_ID)) AS Returned_Percentage
FROM Orders o
LEFT JOIN product_return pr ON o.Order_ID = pr.Order_ID;

-- --
SELECT 
    o.Category,
    COUNT(DISTINCT pr.Order_ID) AS Returned_Orders,
    COUNT(DISTINCT o.Order_ID) AS Total_Orders,
    (COUNT(DISTINCT pr.Order_ID) * 100.0 / COUNT(DISTINCT o.Order_ID)) AS Return_Rate
FROM Orders o
LEFT JOIN product_return pr ON o.Order_ID = pr.Order_ID
GROUP BY o.Category
ORDER BY Return_Rate DESC;

-- ---
SELECT 
    'Before Returns' AS Scenario,
    SUM(o.Profit) AS Total_Profit,
    SUM(o.Sales) AS Total_Sales,
    (SUM(o.Profit) * 100.0 / SUM(o.Sales)) AS Profit_Margin
FROM Orders o

UNION ALL

SELECT 
    'After Returns' AS Scenario,
    SUM(o.Profit) - SUM(IF(pr.Order_ID IS NOT NULL, o.Profit, 0)) AS Total_Profit,
    SUM(o.Sales) - SUM(IF(pr.Order_ID IS NOT NULL, o.Sales, 0)) AS Total_Sales,
    ((SUM(o.Profit) - SUM(IF(pr.Order_ID IS NOT NULL, o.Profit, 0))) * 100.0 / 
     (SUM(o.Sales) - SUM(IF(pr.Order_ID IS NOT NULL, o.Sales, 0)))) AS Profit_Margin
FROM Orders o
LEFT JOIN product_return pr ON o.Order_ID = pr.Order_ID;
-- -------
-- Discount Effectiveness
-- What is the relationship between discounts and sales/profit?
SELECT 
    Discount,
    AVG(Sales) AS Average_Sales_Per_Order,
    AVG(Profit) AS Average_Profit_Per_Order,
    (AVG(Profit) * 100.0 / AVG(Sales)) AS Average_Profit_Margin
FROM Orders
GROUP BY Discount
ORDER BY Discount ASC;

-- ----
-- Do higher discounts lead to higher sales or lower profits?
select 
	Discount,
    count(*) as Number_of_Orders,
    sum(sales) as Total_sales,
    sum(profit) as Total_profit,
    sum(sales) / count(*) as Avg_sales_per_order,
    sum(profit) / COUNT(*) as Avg_profit_per_order,
    sum(profit)*100.0/sum(sales) as Profit_Margin
from orders
group by discount
order by discount asc;
-- ----
-- Identify the optimal discount range that maximizes profit.

SELECT 
    Discount,
    COUNT(*) AS Number_of_Orders,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    (SUM(Profit) * 100.0 / SUM(Sales)) AS Profit_Margin
FROM Orders
GROUP BY Discount
ORDER BY Total_Profit DESC
LIMIT 1; -- Get the discount level with the highest total profit

-- Shipping Mode
-- Which shipping mode is most commonly used, and how does it affect delivery times?
select 
	ship_mode,
    count(*) as Number_of_orders,
    avg(datediff(ship_date,order_date)) as avg_delivery_time
from orders
group by Ship_Mode
order by Number_of_orders desc;

-- --------
-- How do different shipping modes impact profitability?
SELECT 
    Ship_Mode,
    COUNT(*) AS Number_of_Orders,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    (SUM(Profit) * 100.0 / SUM(Sales)) AS Profit_Margin,
    (SUM(Profit) / COUNT(*)) AS Avg_Profit_Per_Order
FROM Orders
GROUP BY Ship_Mode
ORDER BY Total_Profit DESC;
-- -------
-- Regional and Personnel Insights
-- Which regions generate the highest revenue and profit?

SELECT 
    Region,
    SUM(Sales) AS Total_Revenue,
    SUM(Profit) AS Total_Profit,
    (SUM(Profit) * 100.0 / SUM(Sales)) AS Profit_Margin,
    COUNT(*) AS Number_of_Orders
FROM Orders
GROUP BY Region
ORDER BY Total_Revenue DESC, Total_Profit DESC;
-- ---------------
-- Are there performance differences between regions managed by different personnel?
SELECT 
    p.Person AS Manager,
    o.Region,
    COUNT(o.Order_ID) AS Number_of_Orders,
    SUM(o.Sales) AS Total_Sales,
    SUM(o.Profit) AS Total_Profit,
    (SUM(o.Profit) * 100.0 / SUM(o.Sales)) AS Profit_Margin
FROM Orders o
JOIN People p
ON o.Region = p.Region
GROUP BY p.Person, o.Region
ORDER BY Total_Profit DESC;
-- --------
-- Product Analysis
-- What are the best-selling products and sub-categories?
-- sub-categories
SELECT 
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    COUNT(*) AS Number_of_Orders,
    SUM(Profit) AS Total_Profit
FROM Orders
GROUP BY Sub_Category
ORDER BY Total_Sales DESC
LIMIT 10; -- Top 10 best-selling sub-categories

-- best selling product
SELECT 
    Product_Name,
    Sub_Category,
    SUM(Sales) AS Total_Sales,
    COUNT(*) AS Number_of_Orders,
    SUM(Profit) AS Total_Profit
FROM Orders
GROUP BY Product_Name, Sub_Category
ORDER BY Total_Sales DESC
LIMIT 10; -- Top 10 best-selling products

-- Which products generate the most profit and which are the least profitable?
-- most-profitable products
SELECT 
    Product_Name,
    Sub_Category,
    SUM(Profit) AS Total_Profit,
    SUM(Sales) AS Total_Sales,
    (SUM(Profit) * 100.0 / SUM(Sales)) AS Profit_Margin,
    COUNT(*) AS Number_of_Orders
FROM Orders
GROUP BY Product_Name, Sub_Category
ORDER BY Total_Profit DESC
LIMIT 10; -- Top 10 most profitable products

-- least profitable products
SELECT 
    Product_Name,
    Sub_Category,
    SUM(Profit) AS Total_Profit,
    SUM(Sales) AS Total_Sales,
    (SUM(Profit) * 100.0 / SUM(Sales)) AS Profit_Margin,
    COUNT(*) AS Number_of_Orders
FROM Orders
GROUP BY Product_Name, Sub_Category
ORDER BY Total_Profit ASC
LIMIT 10; -- Top 10 least profitable products


-- Are there any patterns or trends in product sales by category?
-- Monthly Sales Trends by Category

SELECT 
    DATE_FORMAT(Order_Date, '%Y-%m') AS Month,
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(*) AS Number_of_Orders
FROM Orders
GROUP BY DATE_FORMAT(Order_Date, '%Y-%m'), Category
ORDER BY Month, Total_Sales DESC;

-- Yearly Sales Trends by Category
SELECT 
    YEAR(Order_Date) AS Year,
    Category,
    SUM(Sales) AS Total_Sales,
    SUM(Profit) AS Total_Profit,
    COUNT(*) AS Number_of_Orders
FROM Orders
GROUP BY YEAR(Order_Date), Category
ORDER BY Year, Total_Sales DESC;









