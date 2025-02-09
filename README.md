# Knowing-Your-Customers-A-Data-Driven-Approach

This repository contains a comprehensive analysis for customer churn, segmentation, and Customer Lifetime Value (CLV) estimation using a data-driven approach. The analysis is implemented in a Google Colab notebook and leverages a wide range of machine learning and statistical techniques.

## Overview

The notebook demonstrates an end-to-end workflow on an online retail dataset (using `online_retail_II.xlsx`), including:
- **Data Loading and Preprocessing:** Cleaning the data by removing missing and invalid entries, computing total sales per transaction.
- **RFM Calculation, Scoring & Segmentation:** Computing Recency, Frequency, and Monetary (RFM) metrics; scoring and segmenting customers using both equal-frequency binning and custom quantile-based scoring.
- **Clustering:** Applying log transformation and standard scaling, then performing K-Means clustering with an elbow method to determine the optimal number of clusters. Cluster summaries are visualized.
- **Classification:** Training and evaluating both a RandomForest classifier and a Neural Network to predict customer clusters.
- **CLV Estimation:** Estimating CLV using BG/NBD and Gamma-Gamma models, applying several data transformations (log, Box-Cox, winsorization) and outlier treatments, and computing a *weighted CLV* metric using scaled values for CLV, Frequency, and Recency.
- **Customer Journey Mapping:** Aggregating monthly CLV data to create pivot tables and interactive visualizations (Sunburst chart and heatmap) that illustrate customer transitions across segments.
- **Optional:** Integration code for loading data from Google BigQuery is also provided.

## Github Page of Report
github page: https://mahesh7667.github.io/Knowing-Your-Customers-A-Data-Driven-Approach/

## Data Source

site: https://archive.ics.uci.edu/dataset/502/online+retail+ii

## Requirements

The analysis requires the following Python libraries:

- `pandas`
- `numpy`
- `matplotlib`
- `seaborn`
- `scikit-learn`
- `tensorflow` (for neural networks)
- `lifetimes`
- `plotly`
- `google-cloud-bigquery` (optional, for BigQuery integration)
- `openpyxl`

You can install these dependencies via pip:

```bash
pip install tensorflow pandas numpy matplotlib scikit-learn lifetimes plotly seaborn google-cloud-bigquery openpyxl
```



## Notebook Structure

The Colab notebook is divided into these key sections:

1. Data Loading and Preprocessing
Objective: Load the online_retail_II.xlsx file and perform data cleaning.
Key Steps: Drop rows with missing Customer IDs, filter for positive Quantity and Price, compute TotalSales, and convert dates.
2. RFM Calculation, Scoring & Segmentation
Objective: Compute RFM metrics for each customer.
Key Steps:
Calculate Recency (days since last purchase), Frequency (number of unique invoices), and Monetary (total sales).
Score these metrics using both pd.qcut (equal-frequency binning) and custom quantile methods.
Segment customers into groups such as Champions, Potential Loyalists, At Risk Customers, and Lost.
Visualization: Bar charts of segment counts.
3. Clustering
Objective: Identify distinct customer clusters using K-Means.
Key Steps:
Apply log transformation and standard scaling to RFM features.
Use the elbow method to help determine the optimal number of clusters.
Visualize cluster summaries (e.g., average Recency, Frequency, Monetary).
4. Classification (RandomForest & Neural Network)
Objective: Predict customer clusters using supervised learning.
Key Steps:
Split the data into training and testing sets.
Train a RandomForest classifier and a Neural Network.
Evaluate the models using classification reports and confusion matrices.
Results: Achieve high accuracy (~98% for RandomForest and ~96% for the Neural Network).
5. Customer Lifetime Value (CLV) Estimation
Objective: Estimate the CLV for each customer.
Key Steps:
Fit the BG/NBD model for purchase predictions and the Gamma-Gamma model for monetary predictions.
Apply multiple transformations (log, Box-Cox, winsorization) to handle skewed data.
Revised Weighted CLV Calculation: Scale CLV, Frequency, and Recency to [0, 1] and combine them using assigned weights.
Example Output: The top customer by weighted CLV has a value around 0.52, making it easier to compare customer value on a normalized scale.
Visualization: Histograms for raw CLV, transformed CLV, and weighted CLV distributions.
6. Customer Journey Mapping
Objective: Visualize the evolution of customer value over time.
Key Steps:
Aggregate monthly CLV values per customer.
Create pivot tables to track customer movements.
Generate interactive visualizations such as a Sunburst diagram and a heatmap showing transition patterns.
7. (Optional) Google BigQuery Data Loading
Objective: Load additional data from BigQuery if needed.
Key Steps:
Authenticate and query BigQuery.
Merge BigQuery results with the main dataset.
Results and Observations
RFM Segmentation:
Customers are segmented into distinct groups (e.g., Champions, At Risk) based on their RFM scores.

Clustering:
K-Means clustering reveals clear customer groups with differing purchasing behaviors. The elbow method confirms the chosen number of clusters.

Classification:
Both the RandomForest and Neural Network models achieve excellent accuracy, demonstrating the robustness of the segmentation.

CLV Estimation:
The raw CLV values are highly variable. The weighted CLV metric, which normalizes CLV, Frequency, and Recency, provides a more intuitive ranking of customer value.

Customer Journey Mapping:
Interactive visualizations help in understanding customer transitions over time, which is crucial for targeted marketing and retention strategies.

### Running the Notebook

Open the provided Colab notebook in Google Colab.
Upload the online_retail_II.xlsx file to your Colab environment.
Run the notebook cell-by-cell. If you plan to use BigQuery integration, follow the authentication prompts.
Review the inline outputs and visualizations to understand the analysis and results.

## Conclusion
This project provides a robust technical framework for customer churn analysis, segmentation, and CLV estimation. It is designed for a technical audience and is intended to be a starting point for further enhancements and customizations. Feel free to fork the repository and adapt the analysis to your specific needs.


