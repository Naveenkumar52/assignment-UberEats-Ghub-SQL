# assignment-UberEats-Ghub-SQL

# Analyzing the Impact of Business Hour Mismatch on Order Volume in the Food Delivery Industry: A Case Study of UEats and Ghub

**Prompt**

- It is important for a store to have consistent business hours across all food delivery platforms to avoid operational inconsistencies.
- If a store's business hours on one platform do not match the hours listed on another platform, it can create potential problems.
- Ensuring that a store's business hours are the same across all food delivery platforms is a key operational metric.

**Example** of business hours in Doordash

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/9b01eb2b-f52b-49a9-9458-39a346cba6ab/Untitled.png)

**Goal** 

The goal of this interview is to come up with a query to understand differences in the business hours for a store across all platforms. You will compute a metric called business hour mismatch between a store on Grubhub and a store on UberEats

For this problem statement, we will only focus on Grubhub and UberEats.

1. Write a SQL query/set of queries that 
    1. Computes Business Hours Mismatch between a restaurant on two platforms. For the sake of simplicity, we will assume UberEats as the **ground truth.** We will then try to find the issues in Grubhub store hours. 
        1. Identify if Grubhub Hours are within the range of UberEats hours (column:is_out_of_range: “In Range”, “Out of Range with 5 mins difference”, “Out of Range”) 

1) **Computing Business Hour Mismatch** 

**Data**

Note all the data is sample data available in BigQuery. (To view the data, open your personal BigQuery console and run these queries).

| UberEats | SELECT * FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_ubereats_hours` LIMIT 1000; |
| --- | --- |
| Grubhub | SELECT * FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours` LIMIT 1000; |

Note: The (b_name,vb_name) tuple can be used as a key to identify the same store and join across the two tables.

Input 

**Uber Eats Business Hours** 

Take the first key value pair in the menu dictionary and the first section and assume that as the store business hours. 

Note: daysBitArray starts with Monday and indicates the days of the week for this time window is applicable. The might be more than element in the regularHours array. 

![Screen Shot 2022-10-11 at 10.39.59 PM.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/8055c4a3-bc72-4c10-9068-817525dc53c7/Screen_Shot_2022-10-11_at_10.39.59_PM.png)

**Grubhub Business Hours** 

Grubhub

| Virtual Restaurant ID (slug)  | JSON response (response) | Link to Block |
| --- | --- | --- |
| johnspizz_sicilianpi_gh | SELECT response FROM `arboreal-vision-339901.take_home_v2.virtual_kitchen_grubhub_hours` LIMIT 1000; |  |
|  |  |  |

![Untitled](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/8ae8a8a1-398a-4ce4-b63c-0e20c7551b47/Untitled.png)

**Output** 

| Grubhub slug | Virtual Restuarant Business Hours | Uber Eats slug | Uber Eats Business Hours | is_out_range **(expected output)** |
| --- | --- | --- | --- | --- |
|  |  |  |  | In Range |
|  |  |  |  | Out of Range  |
|  |  |  |  | Out of Range with 5 mins difference between GH and UE |

**Submission instructions**

1. Send us a SQL or sets of SQL that ouputs data in this format. 

## Tips

1. Please use your personal BigQuery, it is free. ( https://cloud.google.com/bigquery/public-data/  ⇒ click on Go to analytics hub , 
https://cloud.google.com/blog/products/data-analytics/query-without-a-credit-card-introducing-bigquery-sandbox , https://towardsdatascience.com/bigquery-without-a-credit-card-discover-learn-and-share-199e08d4a064 ) 
    
    ![Screen Shot 2023-06-15 at 11.56.53 PM.png](https://s3-us-west-2.amazonaws.com/secure.notion-static.com/eb6fadab-4492-4516-8aed-903ef6f96383/Screen_Shot_2023-06-15_at_11.56.53_PM.png)
    
2. You can view the data once you open BigQuery and run from this table. 
3. Please use json parsing and do not use regex. 
4. There is a way to write the SQL without brute forcing all day combinations etc, we would strongly prefer that. 
    1. Some starting point that might help https://stackoverflow.com/questions/34890339/how-to-extract-all-the-keys-in-a-json-object-with-bigquery 
5. Slug is a unique idenfitier for a store
6. If there are multiple entries for a store, use the one with the latest timestamp.  
7. You can use unnest to flatten business hours array in JSON
