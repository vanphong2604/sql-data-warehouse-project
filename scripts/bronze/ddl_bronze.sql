/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
      Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

-- Drop table bronze.crm_cust_info if it already exists
DROP TABLE IF EXISTS bronze.crm_cust_info;

-- Create table bronze.crm_cust_info
CREATE TABLE bronze.crm_cust_info(
	cst_id INT,
	cst_key VARCHAR(50),
	cst_firstname VARCHAR(50),
	cst_lastname VARCHAR(50),
	cst_material_status VARCHAR(50),
	cst_gndr VARCHAR(50),
	cst_create_date DATE
);

-- Drop table bronze.crm_prd_info if it already exists
DROP TABLE IF EXISTS bronze.crm_prd_info;

-- Create table bronze.crm_prd_info
CREATE TABLE bronze.crm_prd_info(
	prd_id INT,
	prd_key VARCHAR(50),
	prd_nm VARCHAR(50),
	prd_cost INT,
	prd_line VARCHAR(1),
	prd_start_dt DATE,
	prd_end_dt DATE
);

-- Drop table bronze.crm_sales_details if it already exists
DROP TABLE IF EXISTS bronze.crm_sales_details;

-- Create table bronze.crm_sales_details
CREATE TABLE bronze.crm_sales_details(
	sls_ord_num VARCHAR(50),
	sls_prd_key VARCHAR(50),
	sls_cust_id INT,
	sls_order_dt INT,
	sls_ship_dt INT,
	sls_due_dt INT,
	sls_sales INT,
	sls_quantity INT,
	sls_price INT
);

-- Drop table bronze.erp_cust_az12 if it already exists
DROP TABLE IF EXISTS bronze.erp_cust_az12;

-- Create table bronze.erp_cust_az12
CREATE TABLE bronze.erp_cust_az12(
	cid VARCHAR(50),
	bdate DATE,
	gen VARCHAR(50)
);

-- Drop table bronze.erp_loc_a101 if it already exists
DROP TABLE IF EXISTS bronze.erp_loc_a101;

-- Create table bronze.erp_loc_a101
CREATE TABLE bronze.erp_loc_a101(
	cid VARCHAR(50),
	cntry VARCHAR(50)
);

-- Drop table bronze.erp_px_cat_g1v2 if it already exists
DROP TABLE IF EXISTS bronze.erp_px_cat_g1v2;

-- Create table bronze.erp_px_cat_g1v2
CREATE TABLE bronze.erp_px_cat_g1v2(
	id VARCHAR(50),
	cat VARCHAR(50),
	subcat VARCHAR(50),
	maintenance VARCHAR(50)
);