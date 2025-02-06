CREATE OR REPLACE TABLE `retail-449009.retailsales.rfm_customers` AS
WITH rfm AS (
  SELECT 
    `Customer ID`,
    DATE_DIFF(CURRENT_DATE(), DATE(InvoiceDate), DAY) AS Recency,  -- Convert InvoiceDate to DATE
    COUNT(DISTINCT Invoice) AS Frequency,  -- Unique number of purchases
    SUM(Price) AS Monetary  -- Total spending
  FROM `retail-449009.retailsales.sales`
  WHERE Price > 0  -- Exclude returns
  GROUP BY `Customer ID`, InvoiceDate
)
SELECT * FROM rfm;


CREATE OR REPLACE MODEL `retail-449009.retailsales.customer_segmentation_model`
OPTIONS(
  model_type='kmeans',
  num_clusters=4  -- Change based on your elbow method analysis
) AS
SELECT Recency, Frequency, Monetary
FROM `retail-449009.retailsales.rfm_customers`;


CREATE OR REPLACE MODEL `retail-449009.retailsales.customer_segmentation_model`
OPTIONS(
  model_type='kmeans',
  num_clusters=4  -- Change based on your elbow method analysis
) AS
SELECT Recency, Frequency, Monetary
FROM `retail-449009.retailsales.rfm_customers`;


CREATE OR REPLACE TABLE `retail-449009.retailsales.customer_clusters` AS
SELECT 
  `Customer ID`,
  Recency,
  Frequency,
  Monetary,
  CENTROID_ID AS Cluster
FROM ML.PREDICT(MODEL `retail-449009.retailsales.customer_segmentation_model`, 
    (SELECT * FROM `retail-449009.retailsales.rfm_customers`)
);



SELECT Cluster, COUNT(*) AS num_customers
FROM `retail-449009.retailsales.customer_clusters`
GROUP BY Cluster
ORDER BY num_customers DESC;



SELECT 
    Cluster,
    ROUND(AVG(Recency), 2) AS avg_recency,
    ROUND(AVG(Frequency), 2) AS avg_frequency,
    ROUND(AVG(Monetary), 2) AS avg_monetary,
    COUNT(*) AS num_customers
FROM `retail-449009.retailsales.customer_clusters`
GROUP BY Cluster
ORDER BY avg_monetary DESC;





SELECT 
  Cluster,
  COUNT(*) AS num_customers,
  CASE
    WHEN Cluster = 0 THEN 'Loyal Customers'
    WHEN Cluster = 1 THEN 'At-Risk Customers'
    WHEN Cluster = 2 THEN 'Low-Value Customers'
    WHEN Cluster = 3 THEN 'High-Value Customers'
  END AS Cluster_Label
FROM `retail-449009.retailsales.customer_clusters`
GROUP BY Cluster
ORDER BY num_customers DESC;



--- Step 5: Automate Predictions for New Customers


SELECT Customer_ID, Recency, Frequency, Monetary, predicted_Cluster AS Cluster
FROM ML.PREDICT(MODEL `retail-449009.retailsales.customer_segmentation_model`,
    (SELECT * FROM `retail-449009.retailsales.new_customers`));





If you need to create the clusters from scratch in BigQuery, you should leverage BigQuery ML (bqml) to perform the RFM segmentation and clustering directly in BigQuery. Below is a step-by-step guide on how to process raw transactional data, calculate RFM scores, and create customer clusters in BigQuery from scratch.

Step 1: Store Your Raw Data in BigQuery
Ensure that your raw transaction data (e.g., customer_transactions) is stored in BigQuery.
If you haven’t uploaded your data yet, you can do so using Pandas:
python
Copy
Edit
from google.cloud import bigquery
import pandas_gbq

# Set Google Cloud project ID and dataset/table names
project_id = "retail-449009"
dataset_id = "retailsales"
table_id = "customer_transactions"

# Load raw transaction data (ensure your DataFrame is named df)
df.to_gbq(destination_table=f"{dataset_id}.{table_id}", project_id=project_id, if_exists="replace")
print("Raw transaction data uploaded to BigQuery")
Step 2: Calculate RFM Metrics in BigQuery
You can compute Recency, Frequency, and Monetary (RFM) metrics using SQL.

sql
Copy
Edit
CREATE OR REPLACE TABLE `retail-449009.retailsales.rfm_customers` AS
WITH rfm AS (
  SELECT 
    Customer_ID,
    DATE_DIFF(CURRENT_DATE(), MAX(InvoiceDate), DAY) AS Recency,  -- Days since last purchase
    COUNT(DISTINCT Invoice) AS Frequency,  -- Unique number of purchases
    SUM(TotalSales) AS Monetary  -- Total spending
  FROM `retail-449009.retailsales.customer_transactions`
  WHERE TotalSales > 0  -- Exclude returns
  GROUP BY Customer_ID
)
SELECT * FROM rfm;
Step 3: Create Customer Clusters Using BigQuery ML (bqml)
Now that we have RFM data, we can apply K-Means clustering to segment customers.

A. Train the K-Means Model
sql
Copy
Edit
CREATE OR REPLACE MODEL `retail-449009.retailsales.customer_segmentation_model`
OPTIONS(
  model_type='kmeans',
  num_clusters=4  -- Change based on your elbow method analysis
) AS
SELECT Recency, Frequency, Monetary
FROM `retail-449009.retailsales.rfm_customers`;
B. Assign Customers to Clusters
Once the model is trained, you can predict customer segments.

sql
Copy
Edit
CREATE OR REPLACE TABLE `retail-449009.retailsales.customer_clusters` AS
SELECT 
  Customer_ID,
  Recency,
  Frequency,
  Monetary,
  predicted_Cluster AS Cluster
FROM ML.PREDICT(MODEL `retail-449009.retailsales.customer_segmentation_model`, 
    (SELECT * FROM `retail-449009.retailsales.rfm_customers`)
);
Step 4: Analyze the Clusters
Once you have clusters assigned, analyze their characteristics.

A. Count of Customers in Each Cluster
sql
Copy
Edit
SELECT Cluster, COUNT(*) AS num_customers
FROM `retail-449009.retailsales.customer_clusters`
GROUP BY Cluster
ORDER BY num_customers DESC;
B. Average RFM Values Per Cluster
sql
Copy
Edit
SELECT 
    Cluster,
    ROUND(AVG(Recency), 2) AS avg_recency,
    ROUND(AVG(Frequency), 2) AS avg_frequency,
    ROUND(AVG(Monetary), 2) AS avg_monetary,
    COUNT(*) AS num_customers
FROM `retail-449009.retailsales.customer_clusters`
GROUP BY Cluster
ORDER BY avg_monetary DESC;
C. Assign Business Labels to Clusters
After analyzing the cluster patterns, you can manually map them to business labels.

sql
Copy
Edit
SELECT 
  Cluster,
  COUNT(*) AS num_customers,
  CASE
    WHEN Cluster = 0 THEN 'Loyal Customers'
    WHEN Cluster = 1 THEN 'At-Risk Customers'
    WHEN Cluster = 2 THEN 'Low-Value Customers'
    WHEN Cluster = 3 THEN 'High-Value Customers'
  END AS Cluster_Label
FROM `retail-449009.retailsales.customer_clusters`
GROUP BY Cluster
ORDER BY num_customers DESC;
Step 5: Automate Predictions for New Customers
Whenever new transactions are added, you can predict customer clusters automatically.

sql
Copy
Edit
SELECT Customer_ID, Recency, Frequency, Monetary, predicted_Cluster AS Cluster
FROM ML.PREDICT(MODEL `retail-449009.retailsales.customer_segmentation_model`,
    (SELECT * FROM `retail-449009.retailsales.new_customers`));
Step 6: Automate Using Cloud Composer or Scheduled Queries
If you want daily updates, create a scheduled query to refresh the clusters.
You can also use Cloud Composer (Airflow) to fully automate the workflow.
sql
Copy
Edit
CREATE OR REPLACE SCHEDULED QUERY `retail-449009.retailsales.daily_customer_clustering`
OPTIONS(
  schedule_expression="EVERY 24 HOURS",
  destination_table="retail-449009.retailsales.customer_clusters",
  write_disposition="WRITE_TRUNCATE"
) AS
SELECT 
  Customer_ID, Recency, Frequency, Monetary, predicted_Cluster AS Cluster
FROM ML.PREDICT(MODEL `retail-449009.retailsales.customer_segmentation_model`,
    (SELECT * FROM `retail-449009.retailsales.rfm_customers`));
