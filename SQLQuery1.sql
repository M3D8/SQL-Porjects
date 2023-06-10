-- I. Business Problem:
/*
In this SQL project, the objective is to conduct a comprehensive cluster analysis of customer demographics and purchasing behavior 
for a specific company. The primary goal is to gain deep insights into the company's ideal customers, enabling the business to better understand their specific needs,
behaviors, and concerns. By analyzing different customer segments,the company can tailor its products and marketing strategies accordingly.
Rather than indiscriminately targeting all customers, the project aims to identify the most dominant customer segments in terms of numbers and spending habits,
optimizing marketing efforts and maximizing sales potential.
*/
-- II. Asking Questions:
/*
1- What are the customer segments that represent the majority of the company's customers in terms of numbers and spending habits? 
2- What are the most popular products for each of these customer segments?
3- What are the preferred shopping medium (web, catalog or store) for the customers of each of these segments?
4- What is the most successful campaign that returned the highest offer acceptance rate among customers of each segment?
5- What is the complaint rate of the customers of these segments?
*/
-- III. DATA Processing
-- Updating Column Names to Reflect their Content more clearly
EXEC Sp_rename
  'Customer_data.Year_Birth',
  'Birth_Year';

EXEC Sp_rename
  'Customer_data.kidhome',
  'Num_kids';

EXEC Sp_rename
  'Customer_data.Teenhome',
  'Num_Teens';

EXEC Sp_rename
  'Customer_data.Dt_Customer',
  'Membership_Start_Date';

EXEC Sp_rename
  'Customer_data.Recency',
  'Days_Since_Last_Purchase';

EXEC Sp_rename
  'Customer_data.MntWines',
  'Wine_Spending_2Y';

EXEC Sp_rename
  'Customer_data.MntFruits',
  'Fruit_Spending_2Y';

EXEC Sp_rename
  'Customer_data.MntMeatProducts',
  'MeatProducts_Spending_2Y';

EXEC Sp_rename
  'Customer_data.MntFishProducts',
  'Fish_Spending_2Y';

EXEC Sp_rename
  'Customer_data.MntSweetProducts',
  'Sweets_Spending_2Y';

EXEC Sp_rename
  'Customer_data.MntGoldProds',
  'Gold_Spending_2Y';

EXEC Sp_rename
  'Customer_data.AcceptedCmp1',
  'Campaign1_Result';

EXEC Sp_rename
  'Customer_data.AcceptedCmp2',
  'Campaign2_Result';

EXEC Sp_rename
  'Customer_data.AcceptedCmp3',
  'Campaign3_Result';

EXEC Sp_rename
  'Customer_data.AcceptedCmp4',
  'Campaign4_Result';

EXEC Sp_rename
  'Customer_data.AcceptedCmp5',
  'Campaign5_Result';

EXEC Sp_rename
  'Customer_data.Response',
  'Campaign6_Result';

EXEC Sp_rename
  'Customer_data.NumWebVisitsMonth',
  'Num_Web_Visits_Last_Month';

-- Education Column Rearrangement
SELECT education,
       Count(education) AS Total_Holders
FROM   [customer_data].dbo.customer_data
GROUP  BY education
ORDER  BY total_holders DESC;

UPDATE customer_data.dbo.customer_data
SET    education = 'Undergrad'
WHERE  education = 'Graduation';

UPDATE customer_data.dbo.customer_data
SET    education = 'Masters'
WHERE  education = 'Master';

UPDATE customer_data.dbo.customer_data
SET    education = 'High School'
WHERE  education = '2n Cycle';

UPDATE customer_data.dbo.customer_data
SET    education = 'Primary'
WHERE  education = 'Basic'

-- Marital Status Column Rearrangement
SELECT marital_status,
       Count(marital_status) AS Total
FROM   [customer_data].dbo.customer_data
GROUP  BY marital_status
ORDER  BY total DESC;

UPDATE customer_data.dbo.customer_data
SET    marital_status = 'Married'
WHERE  marital_status = 'Together';

UPDATE customer_data.dbo.customer_data
SET    marital_status = 'Single'
WHERE  marital_status = 'Alone';

DELETE FROM customer_data.dbo.customer_data
WHERE  marital_status = 'Absurd'
        OR marital_status = 'YOLO';

/* Rearranged the positions of different table columns in a way that puts columns 
conveying similiar info next to each other, using the 'Design' option in SQL Server
*/

-- IV. DATA Cleaning
-- Checking For and DELETING NULLS 
--From Income Column
SELECT *
FROM   customer_data.dbo.customer_data
WHERE  customer_id IS NULL
-- I checked with every column in the table to verify the absence of NULL values in any of the columns.
-- Turns out Income column had very few NULL values. The best course of action is to delete them.
;

DELETE FROM customer_data.dbo.customer_data
WHERE  income IS NULL;

-- CHECKING FOR DUPLICATES 
--IN Customer_ID Column
SELECT customer_id,
       Count(customer_id)
-- I had to verify the absence of duplicate values in customer_ID column.
FROM   customer_data.dbo.customer_data
GROUP  BY customer_id
ORDER  BY Count(customer_id) DESC;

-- Checking for Outliers
/* When cleaning the Income column, I noticed an unusual very infalted/deflated values compared to the majority of income values. 
I also noticed that there is only 13 rows out of the 2000+ rows that represent customers who are less than the age of 30.
This was after an in-depth analysis of the dataset consisting of adding age and age_group columns and grouping the customers by these categories.
The best COA was to consider these as outliers and delete them. 
*/
SELECT income
FROM   customer_data
ORDER  BY income DESC
-- The majority of income values ranged between $10,245 AND $162,397, the rest of values will be deleted
;

DELETE FROM customer_data
WHERE  income < 10245
        OR income > 162397;

SELECT age
FROM   customer_data.dbo.customer_data
ORDER  BY age DESC
-- The range of Age was between 27 and 130. The top three age values were: 130, 124 and 123.
-- The next smaller age value is 83. The three first age values represent outliers and will be deleted
-- There was only 13 rows out of the 2000+ rows in the dataset that represent customers aging between 18 and 30.
-- These rows will be deleted as well.
;

DELETE FROM customer_data.dbo.customer_data
WHERE  age > 83
        OR age <= 30;

-- V. DATA Analysis: Columns Addition
-- Adding Age Column
ALTER TABLE customer_data.dbo.customer_data
  ADD age INT;

UPDATE customer_data.dbo.customer_data
SET    age = ( Year(Getdate()) - birth_year );

;
-- Adding Age Category Column
ALTER TABLE customer_data.dbo.customer_data
  ADD age_category VARCHAR(50);

UPDATE customer_data.dbo.customer_data
SET    age_category = ( CASE
                          WHEN age < 18 THEN 'CHILD'
                          WHEN age BETWEEN 18 AND 30 THEN 'YOUNG ADULT'
                          WHEN age BETWEEN 30 AND 55 THEN 'ADULT'
                          ELSE 'OLD'
                        END );

;
-- Adding Age Group Column
ALTER TABLE customer_data.dbo.customer_data
  ADD age_group VARCHAR(50);

UPDATE customer_data.dbo.customer_data
SET    age_group = CASE
                     WHEN ( Year(Getdate()) - birth_year ) < 18 THEN '< 18'
                     WHEN ( Year(Getdate()) - birth_year ) BETWEEN 18 AND 30
                   THEN
                     '18 - 30'
                     WHEN ( Year(Getdate()) - birth_year ) BETWEEN 30 AND 55
                   THEN
                     '30 - 55'
                     ELSE '55+'
                   END;

-- Adding Economic Class Column
ALTER TABLE customer_data.dbo.customer_data
  ADD income_class VARCHAR(50);

UPDATE customer_data
SET    income_class = CASE
                        WHEN income < 40000 THEN 'Low'
                        WHEN income BETWEEN 40000 AND 80000 THEN 'Middle'
                        WHEN income > 80000 THEN 'High'
                      END;

-- Adding Children (parental status) column
ALTER TABLE customer_data.dbo.customer_data
  ADD children VARCHAR(50);

UPDATE customer_data.dbo.customer_data
SET    children = CASE
                    WHEN num_kids > 0
                          OR num_teens > 0 THEN 'Yes'
                    ELSE 'No'
                  END;

-- Adding Total Spending for the last 2 years Column
ALTER TABLE customer_data.dbo.customer_data
  ADD total_spending_2y INT;

UPDATE customer_data
SET    total_spending_2y = wine_spending_2y + fruit_spending_2y
                           + meatproducts_spending_2y + fish_spending_2y
                           + sweets_spending_2y + gold_spending_2y;

-- Adding Total Number of Purchases Column
ALTER TABLE customer_data.dbo.customer_data
  ADD total_number_purchases INT;

UPDATE customer_data.dbo.customer_data
SET    total_number_purchases = numwebpurchases + numcatalogpurchases
                                + numstorepurchases;


*/
-- VI. Data Analysis: Clustering 
-- Analyzig the correalation between customer's education level, income class and their overall average spending for the past two years.
SELECT education,
       Avg(income)
       Average_Income,
       income_class,
       Avg(wine_spending_2y)
       Avg_Wine_Spending,
       Avg(fruit_spending_2y)
       Avg_Fruits_Spending,
       Avg(meatproducts_spending_2y)
       Avg_Meat_Spending,
       Avg(fish_spending_2y)
       Avg_Fish_Spending,
       Avg(gold_spending_2y)
       Avg_Gold_Spending,
       Avg(sweets_spending_2y)
       Avg_Sweets_Spending,
       Cast(( ( Avg(wine_spending_2y)
                + Avg(fish_spending_2y)
                + Avg(gold_spending_2y)
                + Avg(sweets_spending_2y)
                + Avg(fruit_spending_2y)
                + Avg(meatproducts_spending_2y) ) / 6.0 ) AS DECIMAL(10, 2)) AS
       Overall_Avg_Spending,
       Count(customer_id)
       Total_Customers
FROM   [customer_data].dbo.[customer_data]
GROUP  BY education,
          income_class
ORDER  BY overall_avg_spending DESC
/* Most of company's customers are middle-class, undergrad degree holders,
however, the customers with the highest overall average spending are high-income, Master's Degree holders followed by high-income, undergrad degree holders,
followed by high-income, PhD holders.
*/
;

-- Analyzig the correlation between customer's marital status, parental status, income class and their overall average spending in the past two years.
WITH kids
     AS (SELECT customer_id,
                CASE
                  WHEN num_kids > 0
                        OR num_teens > 0 THEN 'Yes'
                  ELSE 'No'
                END Have_Kids
         FROM   customer_data.dbo.customer_data cd)
SELECT marital_status,
       have_kids,
       Avg(income)                   Average_Income,
       income_class,
       Count(cd.customer_id)         AS Total_Customers,
       Avg(wine_spending_2y)         Avg_Wine_Spending,
       Avg(fruit_spending_2y)        Avg_Fruits_Spending,
       Avg(meatproducts_spending_2y) Avg_Meat_Spending,
       Avg(fish_spending_2y)         Avg_Fish_Spending,
       Avg(gold_spending_2y)         Avg_Gold_Spending,
       Avg(sweets_spending_2y)       Avg_Sweets_Spending,
       Avg(total_spending_2y)        AS Overall_Avg_Spending_2Y
FROM   [customer_data].dbo.[customer_data] cd
       LEFT JOIN kids k
              ON k.customer_id = cd.customer_id
GROUP  BY marital_status,
          income_class,
          have_kids
ORDER  BY overall_avg_spending_2y DESC,
          CASE
            WHEN marital_status = 'Married' THEN 1
            ELSE 2
          END,
          marital_status,
          have_kids
/* Most of company's customers are from middle-class, married and have at least one kid. However, customers who are single or married 
and have no kids have the highest overall average spending over the past two years, singles being the top 1 group, followed by married customers.
(Widow, single and divroced customers with kids will be neglected despite representing the next 3 categories when it comes to highest-overall-average
spending. This is due to the very few number of customers that represent these categories (1,6 and 3 respectively).
*/
;

-- Analyzing the distribution of the company's customers by age and determining the age group and category that represent the majority of them.
SELECT age_group,
       age_category,
       Avg(total_spending_2y)               Avg_Total_Spending_2Y,
       Count(age_category)                  AS Total_Customers,
       Round(Cast(Count(age_category) * 100.0 /
                  (SELECT Count(*)
                   FROM   customer_data.dbo.customer_data) AS
                        NUMERIC(10, 2)), 2) AS Customer_Percetange
FROM   customer_data.dbo.customer_data cd
GROUP  BY age_category,
          age_group
ORDER  BY total_customers DESC;


;
/* The majority of customers are adults between the ages of 30-55 with a percentage of 56.93%,
while customers aging over 50 represent 43.07 of the total customers.
The overall-spending averages over the past two years did not vary greatly between the two groups.
While old customers had the highest average of spending of $696, adult customers came in a close second with an average of $546.
*/
/* Majority of customers are from middle class, married, have at leas one kids, 
undergrad degree holders and are adults between the age of 30 and 55. 
This group will be referred to as Customer Group 1 (Majority by Numbers) in the upcoming analysis.

The customers with the highest spending over the past two years are mainly singles or married having no kids, 
undergrad degree holders or higher (Masters or PhD), from a high-income class and aging 30 and up.
This group will be referred to as Customer Group 2 (Majority by Spending or Top Spenders) in the upcoming analysis. 
*/
-- Determining the most popular products for the past two years across the two customer groups.
-- Analysis for Customer Group 1: Majority by Numbers
SELECT income_class,
       marital_status,
       education,
       children,
       age_category,
       Sum(wine_spending_2y)          AS Total_Wine_Spending,
       Round(Cast(Sum(wine_spending_2y) * 100.0 / Sum(total_spending_2y) AS
                  NUMERIC(10, 2)), 2) AS Wine_Spending_Percentage,
       Sum(fruit_spending_2y)         AS Total_Fruit_Spending,
       Round(Cast(Sum(fruit_spending_2y) * 100.0 / Sum(total_spending_2y) AS
                  NUMERIC(10, 2)), 2) AS Fruit_Spending_Percentage,
       Sum(meatproducts_spending_2y)  AS Total_Meat_Spending,
       Round(Cast(Sum(meatproducts_spending_2y) * 100.0 / Sum(total_spending_2y)
                  AS
                  NUMERIC(
                        10, 2)), 2)   AS Meat_Spending_Percentage,
       Sum(fish_spending_2y)          AS Total_Fish_Spending,
       Round(Cast(Sum(fish_spending_2y) * 100.0 / Sum(total_spending_2y) AS
                  NUMERIC(10, 2)), 2) AS Fish_Spending_Percentage,
       Sum(sweets_spending_2y)        AS Total_Sweets_Spending,
       Round(Cast(Sum(sweets_spending_2y) * 100.0 / Sum(total_spending_2y) AS
                  NUMERIC(
                  10, 2)), 2)         AS Sweets_Spending_Percentage,
       Sum(gold_spending_2y)          AS Total_Gold_Spending,
       Round(Cast(Sum(gold_spending_2y) * 100.0 / Sum(total_spending_2y) AS
                  NUMERIC(10, 2)), 2) AS Gold_Spending_Percentage,
       Sum(total_spending_2y)         AS Total_2Y_Spending
FROM   customer_data.dbo.customer_data
GROUP  BY income_class,
          marital_status,
          education,
          children,
          age_category
HAVING income_class = 'Middle'
       AND marital_status = 'Married'
       AND children = 'Yes'
       AND education = 'Undergrad'
       AND age_category = 'Adult';

/* Wine is clearly the most popular product of all products for customers of Group 1, 
with a spending percentage of 51.78% of the overall average spending for this group.
*/
-- Analysis for Customer Group 2: Top Spenders
WITH products_g2
     AS (SELECT income_class,
                education,
                marital_status,
                children,
                Sum(wine_spending_2y)          AS Total_Wine_Spending,
                Round(Cast(Sum(wine_spending_2y) * 100.0 /
                           Sum(total_spending_2y) AS
                           NUMERIC(10, 2)), 2) AS Wine_Spending_Percentage,
                Sum(fruit_spending_2y)         AS Total_Fruit_Spending,
                Round(Cast(Sum(fruit_spending_2y) * 100.0 / Sum(
                           total_spending_2y) AS
                           NUMERIC(10, 2)), 2) AS Fruit_Spending_Percentage,
                Sum(meatproducts_spending_2y)  AS Total_Meat_Spending,
                Round(Cast(Sum(meatproducts_spending_2y) * 100.0 /
                           Sum(total_spending_2y) AS
                           NUMERIC(
                                 10, 2)), 2)   AS Meat_Spending_Percentage,
                Sum(fish_spending_2y)          AS Total_Fish_Spending,
                Round(Cast(Sum(fish_spending_2y) * 100.0 /
                           Sum(total_spending_2y) AS
                           NUMERIC(10, 2)), 2) AS Fish_Spending_Percentage,
                Sum(sweets_spending_2y)        AS Total_Sweets_Spending,
                Round(Cast(Sum(sweets_spending_2y) * 100.0 / Sum(
                           total_spending_2y)
                           AS
                           NUMERIC(
                           10, 2)), 2)         AS Sweets_Spending_Percentage,
                Sum(gold_spending_2y)          AS Total_Gold_Spending,
                Round(Cast(Sum(gold_spending_2y) * 100.0 /
                           Sum(total_spending_2y) AS
                           NUMERIC(10, 2)), 2) AS Gold_Spending_Percentage,
                Sum(total_spending_2y)         AS Total_2Y_Spending
         FROM   customer_data.dbo.customer_data
         GROUP  BY income_class,
                   education,
                   marital_status,
                   children
         HAVING income_class = 'High'
                AND children = 'No'
                AND education IN ( 'Undergrad', 'Masters', 'PhD' )
                AND marital_status IN ( 'Single', 'Married' ))
SELECT Round(Cast(Avg(wine_spending_percentage) AS NUMERIC(10, 2)), 2)   AS
       Wine_Spending_Perc_Avg,
       Round(Cast(Avg(fruit_spending_percentage) AS NUMERIC(10, 2)), 2)  AS
       Fruit_Spend_Perc_Avg,
       Round(Cast(Avg(meat_spending_percentage) AS NUMERIC(10, 2)), 2)   AS
       Meat_Spending_Perc_Avg,
       ROUND(CAST(Avg(fish_spending_percentage) AS NUMERIC(10,2)),2)     AS
       Fish_Spending_Perc_Avg,
       Round(Cast(Avg(sweets_spending_percentage) AS NUMERIC(10, 2)), 2) AS
       Sweets_Spending_Perc_Avg,
       Round(Cast(Avg(gold_spending_percentage) AS NUMERIC(10, 2)), 2)   AS
       Gold_Spending_Percentage_Avg
FROM   products_g2;

-- Wine is also the clear winner when it comes to popualarity for customers of Group 2, with a 48.38% of the overall spending average of the group.
-- Wine is by far the most popular product over the past two years among both customer groups.


-- Determining the most popular shopping medium for each of the two groups
-- Customer Group 1
SELECT income_class,
       marital_status,
       education,
       children,
       age_category,
       Sum(numwebpurchases)                 Total_Web_Purchases,
       Round(Cast(Sum(numwebpurchases) * 100.0 / Sum(total_number_purchases) AS
                        NUMERIC(10, 2)), 2) Percentage_Web_Purchases,
       Sum(numcatalogpurchases)             Total_Catalog_Purchases,
       Round(Cast(Sum(numcatalogpurchases) * 100.0 / Sum(total_number_purchases)
                  AS
                  NUMERIC(
                        10, 2)), 2)         Percentage_Catalog_Purchases,
       Sum(numstorepurchases)               Total_Store_Purchases,
       Round(Cast(Sum(numstorepurchases) * 100.0 / Sum(total_number_purchases)
                  AS
                        NUMERIC(10, 2)), 2) Percentage_Store_Purchases,
       Sum(total_number_purchases)          Total
FROM   customer_data.dbo.customer_data
GROUP  BY income_class,
          marital_status,
          education,
          children,
          age_category
HAVING income_class = 'Middle'
       AND marital_status = 'Married'
       AND children = 'Yes'
       AND education = 'Undergrad'
       AND age_category = 'Adult';

/* Most of Customers of Group 1 prefer to shop from the store more than any other shopping medium, representing 46.02% of all the purchase operations across 
all mediums
*/

-- Customer Group 2
WITH shop_gr2
     AS (SELECT income_class,
                education,
                marital_status,
                children,
                Sum(numwebpurchases)                 Total_Web_Purchases,
                Round(Cast(Sum(numwebpurchases) * 100.0 / Sum(
                           total_number_purchases)
                           AS
                                 NUMERIC(10, 2)), 2) Percentage_Web_Purchases,
                Sum(numcatalogpurchases)             Total_Catalog_Purchases,
                Round(Cast(Sum(numcatalogpurchases) * 100.0 /
                           Sum(total_number_purchases) AS
                           NUMERIC(
                                 10, 2)), 2)
                Percentage_Catalog_Purchases,
                Sum(numstorepurchases)               Total_Store_Purchases,
                Round(Cast(Sum(numstorepurchases) * 100.0 / Sum(
                           total_number_purchases)
                           AS
                                 NUMERIC(10, 2)), 2) Percentage_Store_Purchases,
                Sum(total_number_purchases)          Total
         FROM   customer_data.dbo.customer_data
         GROUP  BY income_class,
                   education,
                   marital_status,
                   children
         HAVING income_class = 'High'
                AND children = 'No'
                AND education IN ( 'Undergrad', 'Masters', 'PhD' )
                AND marital_status IN ( 'Single', 'Married' ))
SELECT Round(Cast(Avg(percentage_web_purchases) AS NUMERIC(10, 2)), 2)     AS
       Web_Purchases_Perc_Avg,
       Round(Cast(Avg(percentage_catalog_purchases) AS NUMERIC(10, 2)), 2) AS
       Catalog_Purchases_Perc_Avg,
       Round(Cast(Avg(percentage_store_purchases) AS NUMERIC(10, 2)), 2)   AS
       Store_Purchases_Perc_Avg
FROM   shop_gr2;

/* Most of Customers of Group 2 prefer to shop from the store as well more than any other shopping medium, with a 42.72% of all purchase operations coming from
the store.
*/
-- The store is the most popular shopping place for customers. 


-- Determining the acceptance rate of each campaign across both customer groups
-- Calculating Acceptance rate of Customer Group 1 for each of the six campaigns and determining the most successful campaign
SELECT income_class,
       marital_status,
       education,
       children,
       age_category,
       Round(Cast(Sum(CASE
                        WHEN campaign1_result = 1 THEN 1
                        ELSE 0
                      END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
       Cmp1_Acceptance_Rate,
       Round(Cast(Sum(CASE
                        WHEN campaign2_result = 1 THEN 1
                        ELSE 0
                      END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
       Cmp2_Acceptance_Rate,
       Round(Cast(Sum(CASE
                        WHEN campaign3_result = 1 THEN 1
                        ELSE 0
                      END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
       Cmp3_Acceptance_Rate,
       Round(Cast(Sum(CASE
                        WHEN campaign4_result = 1 THEN 1
                        ELSE 0
                      END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
       Cmp4_Acceptance_Rate,
       Round(Cast(Sum(CASE
                        WHEN campaign5_result = 1 THEN 1
                        ELSE 0
                      END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
       Cmp5_Acceptance_Rate,
       Round(Cast(Sum(CASE
                        WHEN campaign6_result = 1 THEN 1
                        ELSE 0
                      END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
       Cmp6_Acceptance_Rate
FROM   customer_data.dbo.customer_data
GROUP  BY income_class,
          marital_status,
          education,
          children,
          age_category
HAVING income_class = 'Middle'
       AND marital_status = 'Married'
       AND children = 'Yes'
       AND education = 'Undergrad'
       AND age_category = 'Adult';

-- Campaign 4 was the most successful campaign among customers of Group 1, with an acceptance rate of 7.45%.

-- Calculating Acceptance rate of Customer Group 2 for each of the six campaigns and determining the most successful campaign
WITH cmp_gr2
     AS (SELECT income_class,
                education,
                marital_status,
                children,
                Round(Cast(Sum(CASE
                                 WHEN campaign1_result = 1 THEN 1
                                 ELSE 0
                               END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
                Cmp1_Acceptance_Rate,
                Round(Cast(Sum(CASE
                                 WHEN campaign2_result = 1 THEN 1
                                 ELSE 0
                               END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
                Cmp2_Acceptance_Rate,
                Round(Cast(Sum(CASE
                                 WHEN campaign3_result = 1 THEN 1
                                 ELSE 0
                               END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
                Cmp3_Acceptance_Rate,
                Round(Cast(Sum(CASE
                                 WHEN campaign4_result = 1 THEN 1
                                 ELSE 0
                               END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
                Cmp4_Acceptance_Rate,
                Round(Cast(Sum(CASE
                                 WHEN campaign5_result = 1 THEN 1
                                 ELSE 0
                               END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
                Cmp5_Acceptance_Rate,
                Round(Cast(Sum(CASE
                                 WHEN campaign6_result = 1 THEN 1
                                 ELSE 0
                               END) * 100.0 / Count(*) AS NUMERIC(10, 2)), 2) AS
                Cmp6_Acceptance_Rate
         FROM   customer_data.dbo.customer_data
         GROUP  BY income_class,
                   education,
                   marital_status,
                   children
         HAVING income_class = 'High'
                AND children = 'No'
                AND education IN ( 'Undergrad', 'Masters', 'PhD' )
                AND marital_status IN ( 'Single', 'Married' ))
SELECT Round(Cast(Avg(cmp1_acceptance_rate) AS NUMERIC(10, 2)), 2) AS
       Cmp1_Acc_Rate_Avg
       ,
       Round(Cast(Avg(cmp2_acceptance_rate) AS NUMERIC(10, 2)), 2) AS
       Cmp2_Acc_Rate_Avg,
       Round(Cast(Avg(cmp3_acceptance_rate) AS NUMERIC(10, 2)), 2) AS
       Cmp3_Acc_Rate_Avg,
       Round(Cast(Avg(cmp4_acceptance_rate) AS NUMERIC(10, 2)), 2) AS
       Cmp4_Acc_Rate_Avg,
       Round(Cast(Avg(cmp5_acceptance_rate) AS NUMERIC(10, 2)), 2) AS
       Cmp5_Acc_Rate_Avg,
       Round(Cast(Avg(cmp6_acceptance_rate) AS NUMERIC(10, 2)), 2) AS
       Cmp6_Acc_Rate_Avg
FROM   cmp_gr2;

-- Campaign 5 was the most successful campaign among customers of Group 2 with the highest acceptance rate of 50.79%.

-- Calculating complaint rate for the past two years for both customer groups
-- Complaint rate for customers of Group 1
SELECT income_class,
       marital_status,
       education,
       children,
       age_category,
       Sum(CASE
             WHEN complain = 1 THEN 1
             ELSE 0
           END)
       Number_Of_Complaints,
       Round(Cast(Sum(CASE
                        WHEN complain = 1 THEN 1
                        ELSE 0
                      END) * 100.0 / Count(*) AS NUMERIC(10, 3)), 3) AS
       Complaint_Rate
FROM   customer_data.dbo.customer_data
GROUP  BY income_class,
          marital_status,
          education,
          children,
          age_category
HAVING income_class = 'Middle'
       AND marital_status = 'Married'
       AND children = 'Yes'
       AND education = 'Undergrad'
       AND age_category = 'Adult';

-- Complaints were non-existent for cusotmers of Group 1 in this dataset, meaning that customers of Group 1 are satisfied with the company's products and services.
-- Complaint rate for Customers of Group 2
SELECT income_class,
       education,
       marital_status,
       children,
       Sum(CASE
             WHEN complain = 1 THEN 1
             ELSE 0
           END)
       Number_Of_Complaints,
       Round(Cast(Sum(CASE
                        WHEN complain = 1 THEN 1
                        ELSE 0
                      END) * 100.0 / Count(*) AS NUMERIC(10, 3)), 3) AS
       Complaint_Rate
FROM   customer_data.dbo.customer_data
GROUP  BY income_class,
          education,
          marital_status,
          children
HAVING income_class = 'High'
       AND children = 'No'
       AND education IN ( 'Undergrad', 'Masters', 'PhD' )
       AND marital_status IN ( 'Single', 'Married' );
/* According to the data given in this dataset, for both customer groups, the complain rates were none (0%),
meaning that the two groups of customers representing the majority of the company's customers and the top spenders are happy with the company's services.
*/

-- VII. Insights Summary:
/*
1- What are the customer segments that represent the majority of the company's customers in terms of numbers and spending habits? 
--> Majority of customers are from middle class, married, have at leas one kids, 
undergrad degree holders and are adults between the age of 30 and 55. (Group 1)

--> The customers with the highest spending over the past two years are mainly singles or married having no kids, 
undergrad degree holders or higher (Masters or PhD), from a high-income class and aging 30 and up. (Group 2)

2- What are the most popular products for each of these customer segments?
--> Wine is clearly the most popular product of all products for Group 1 customers, 
with a spending percentage of 51.78% of the overall average spending for this group.

--> Wine is also the clear winner when it comes to popualarity for customers of Group 2, with a 48.38% of the overall spending average of the group.

3- What are the preferred shopping medium (web, catalog or store) for the customers of each of these segments?
--> Most of customers of Group 1 prefer to shop from the store more than any other shopping medium, representing 46.02% of all the purchase operations across 
all mediums.

--> Most of Customers of Group 2 prefer to shop from the store as well more than any other shopping medium, with a 42.72% of all purchase operations coming from
the store.

4- What is the most successful campaign that returned the highest offer acceptance rate among customers of each segment?
--> Campaign 4 was the most successful campaign among customers of Group 1, with an acceptance rate of 7.45%.

--> Campaign 5 was the most successful campaign among customers of Group 2 with the highest acceptance rate of 50.79%.

5- What is the complaint rate of the customers of these segments?
--> According to the data given in this dataset, for both customer groups, the complain rates were none (0%),
meaning that the two groups of customers representing the majority of the company's customers and the top spenders are happy with the company's services.

*/