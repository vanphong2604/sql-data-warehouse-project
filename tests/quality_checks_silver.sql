/*
===============================================================================
Quality Checks: quality checks for silver layer tables
===============================================================================
Script Purpose:
    This script performs quality checks on the tables in the 'silver' schema to 
    ensure data integrity and consistency.
    It checks for nulls, duplicates, unwanted spaces, invalid date orders, and 
    data standardization & consistency.
    The quality checks are performed on the following tables:
    - silver.crm_cust_info
    - silver.crm_prd_info
    - silver.crm_sales_details
    - silver.erp_cust_az12
    - silver.erp_loc_a101
    - silver.erp_px_cat_g1v2
*/

/* 
==========================================================
Quality Checks for crm_cust_info table in bronze schema
==========================================================
*/
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT cst_id, COUNT(*)
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
	
-- Check for unwanted spaces
-- Expectaion: No Result
SELECT cst_firstname 
FROM bronze.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname )


SELECT cst_lastname 
FROM bronze.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname )

SELECT cst_gndr 
FROM bronze.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr )

SELECT cst_material_status  
FROM bronze.crm_cust_info
WHERE cst_material_status != TRIM(cst_material_status )

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr 
FROM bronze.crm_cust_info

SELECT DISTINCT cst_material_status  
FROM bronze.crm_cust_info
/* 
===========================================================
After loading data into silver.crm_cust_info, 
perform quality checks to ensure data integrity and consistency.
===========================================================
*/
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT cst_id, COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL
	
-- Check for unwanted spaces
-- Expectaion: No Result
SELECT cst_firstname 
FROM silver.crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname )

SELECT cst_lastname 
FROM silver.crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname )

SELECT cst_gndr 
FROM silver.crm_cust_info
WHERE cst_gndr != TRIM(cst_gndr )

SELECT cst_material_status  
FROM silver.crm_cust_info
WHERE cst_material_status != TRIM(cst_material_status )

-- Data Standardization & Consistency
SELECT DISTINCT cst_gndr 
FROM silver.crm_cust_info

SELECT DISTINCT cst_material_status  
FROM silver.crm_cust_info

/* 
==========================================================
Quality Checks for crm_prd_info table in bronze schema
==========================================================
*/
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT prd_id, COUNT(*)
FROM bronze.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
	
-- Check for unwanted spaces
-- Expectaion: No Result
SELECT prd_nm  
FROM bronze.crm_prd_info
WHERE prd_nm != TRIM(prd_nm )

-- Check for NULLs or Negative Numbers
-- Expectation: No Result
SELECT prd_cost 
FROM bronze.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL 

-- Data Standardization & Consistency
SELECT DISTINCT prd_line  
FROM bronze.crm_prd_info

-- Check for Invalid Date Orders
SELECT *
FROM bronze.crm_prd_info cpi 
WHERE cpi.prd_end_dt < cpi.prd_start_dt 

/* 
===========================================================
After loading data into silver.crm_prd_info, 
perform quality checks to ensure data integrity and consistency.
===========================================================
*/
-- Check for Nulls or Duplicates in Primary Key
-- Expectation: No Result
SELECT prd_id, COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL
	
-- Check for unwanted spaces
-- Expectaion: No Result
SELECT prd_nm  
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nm )

-- Check for NULLs or Negative Numbers
-- Expectation: No Result
SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL 

-- Data Standardization & Consistency
SELECT DISTINCT prd_line  
FROM silver.crm_prd_info

-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_prd_info cpi 
WHERE cpi.prd_end_dt < cpi.prd_start_dt 

/* 
==========================================================
Quality Checks for crm_sales_details table in bronze schema
==========================================================
*/
-- Check for Invalid Dates
SELECT
	sls_order_dt
FROM
	bronze.crm_sales_details
WHERE
	sls_order_dt <= 0
	OR length(sls_order_dt::text) != 8
	OR sls_order_dt > 20500101
	OR sls_order_dt < 19000101
	

SELECT
	sls_ship_dt
FROM
	bronze.crm_sales_details
WHERE
	sls_ship_dt <= 0
	OR length(sls_ship_dt::text) != 8
	OR sls_ship_dt > 20500101
	OR sls_ship_dt < 19000101
	

SELECT
	sls_due_dt
FROM
	bronze.crm_sales_details
WHERE
	sls_due_dt <= 0
	OR length(sls_due_dt::text) != 8
	OR sls_due_dt > 20500101
	OR sls_due_dt < 19000101
	
-- Check for Invalid Date Orders
SELECT *
FROM bronze.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check data consistency: between sales, quantity, and price
-- >> Sales = quanity * price
-- >> values must not be NULL, zero or negative.
SELECT DISTINCT 
	sls_sales,
	sls_quantity,
	sls_price
FROM
	bronze.crm_sales_details
WHERE
	sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL
	OR sls_sales <= 0
	OR sls_quantity <= 0
	OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

-- Expectation:
-- If sales is negative, zero or null, derive it using quantity and price
-- If price is zero or null, calculate it using sales and quantity
-- If price is negative, convert it to a postive value
SELECT DISTINCT 
	sls_sales AS old_sls_sales,
	sls_quantity,
	sls_price AS old_sls_price,
	CASE
		WHEN sls_sales <= 0 OR sls_sales IS NULL OR sls_sales != sls_quantity * ABS(sls_price)
		THEN sls_quantity * ABS(sls_price)
		ELSE sls_sales
	END AS sls_sales,
	CASE 
		WHEN sls_price IS NULL OR sls_price <= 0 THEN sls_sales / sls_quantity
		ELSE sls_price
	END AS sls_price
	
FROM
	bronze.crm_sales_details
WHERE
	sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL
	OR sls_sales <= 0
	OR sls_quantity <= 0
	OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

/* 
===========================================================
After loading data into silver.crm_sales_details, 
perform quality checks to ensure data integrity and consistency.
===========================================================
*/
-- Check for Invalid Date Orders
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt

-- Check data consistency: between sales, quantity, and price
-- >> Sales = quanity * price
-- >> values must not be NULL, zero or negative.
SELECT DISTINCT 
	sls_sales,
	sls_quantity,
	sls_price
FROM
	silver.crm_sales_details
WHERE
	sls_sales != sls_quantity * sls_price
	OR sls_sales IS NULL
	OR sls_quantity IS NULL
	OR sls_price IS NULL
	OR sls_sales <= 0
	OR sls_quantity <= 0
	OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price

/* 
==========================================================
Quality Checks for erp_cust_az12 table in bronze schema
==========================================================
*/
-- Identify Out-of-range Dates
SELECT DISTINCT bdate
FROM bronze.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > now()

-- Data Standardization & Consistency
SELECT DISTINCT gen
FROM bronze.erp_cust_az12 

/* 
===========================================================
After loading data into silver.crm_sales_details, 
perform quality checks to ensure data integrity and consistency.
===========================================================
*/
-- Identify Out-of-range Dates
SELECT DISTINCT bdate
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' OR bdate > now()

-- Data Standardization & Consistency
SELECT DISTINCT gen
FROM silver.erp_cust_az12 

/* 
==========================================================
Quality Checks for erp_loc_a101 table in bronze schema
==========================================================
*/
-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101

/* 
===========================================================
After loading data into silver.erp_loc_a101, 
perform quality checks to ensure data integrity and consistency.
===========================================================
*/
-- Data Standardization & Consistency
SELECT DISTINCT cntry
FROM silver.erp_loc_a101

/* 
==========================================================
Quality Checks for erp_loc_a101 table in bronze schema
==========================================================
*/
-- Check for unwanted spaces
SELECT * FROM bronze.erp_px_cat_g1v2
WHERE cat != TRIM(cat) OR subcat != TRIM(subcat) OR maintenance != TRIM(maintenance)

-- Data Standardization & Consistency
SELECT DISTINCT cat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT subcat
FROM bronze.erp_px_cat_g1v2

SELECT DISTINCT maintenance
FROM bronze.erp_px_cat_g1v2
