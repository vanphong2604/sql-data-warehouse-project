/*
=============================================================
Create Schemas
=============================================================
Script Purpose:
    This script creates 3 schemas within the 
    'datawarehouse' database: 'bronze', 'silver', and 'gold'.
*/
-- Create Schemas
CREATE SCHEMA IF NOT EXISTS bronze;
CREATE SCHEMA IF NOT EXISTS silver;
CREATE SCHEMA IF NOT EXISTS gold;