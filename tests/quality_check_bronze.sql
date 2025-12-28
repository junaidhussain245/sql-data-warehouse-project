/* ===============================================================
Bronze Layer QA - Source Data Diagnostics
Purpose: Detect raw data issues before Silver transformations
Notes: No fixes, NVARCHAR-only assumptions
=============================================================== */

SET NOCOUNT ON;

-----------------------------------------------------------------
-- crm_cust_info
-----------------------------------------------------------------

-- PK null or blank
SELECT cst_id
FROM bronze.crm_cust_info
WHERE cst_id IS NULL
   OR LTRIM(RTRIM(cst_id)) = '';

-- PK duplicates
SELECT cst_id, COUNT(*) AS cnt
FROM bronze.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- Marital status domain check
SELECT DISTINCT cst_marital_status
FROM bronze.crm_cust_info;

-- Gender domain check
SELECT DISTINCT cst_gndr
FROM bronze.crm_cust_info;

-- Invalid create dates
SELECT cst_create_date
FROM bronze.crm_cust_info
WHERE cst_create_date IS NOT NULL
  AND (
        LEN(cst_create_date) <> 10
     OR TRY_CONVERT(DATE, cst_create_date, 23) IS NULL
  );

-----------------------------------------------------------------
-- crm_prd_info
-----------------------------------------------------------------

-- Product ID null or blank
SELECT prd_id
FROM bronze.crm_prd_info
WHERE prd_id IS NULL
   OR LTRIM(RTRIM(prd_id)) = '';

-- Product line domain check
SELECT DISTINCT prd_line
FROM bronze.crm_prd_info;

-- Non-numeric product cost
SELECT prd_cost
FROM bronze.crm_prd_info
WHERE prd_cost IS NOT NULL
  AND TRY_CONVERT(DECIMAL(18,2), prd_cost) IS NULL;

-- Invalid start dates
SELECT prd_start_dt
FROM bronze.crm_prd_info
WHERE prd_start_dt IS NOT NULL
  AND TRY_CONVERT(DATE, prd_start_dt, 23) IS NULL;

-----------------------------------------------------------------
-- crm_sales_details
-----------------------------------------------------------------

-- Non-numeric sales
SELECT sls_sales
FROM bronze.crm_sales_details
WHERE sls_sales IS NOT NULL
  AND TRY_CONVERT(DECIMAL(18,2), sls_sales) IS NULL;

-- Non-numeric quantity
SELECT sls_quantity
FROM bronze.crm_sales_details
WHERE sls_quantity IS NOT NULL
  AND TRY_CONVERT(DECIMAL(18,2), sls_quantity) IS NULL;

-- Non-numeric price
SELECT sls_price
FROM bronze.crm_sales_details
WHERE sls_price IS NOT NULL
  AND TRY_CONVERT(DECIMAL(18,2), sls_price) IS NULL;

-- Invalid order dates (YYYYMMDD)
SELECT sls_order_dt
FROM bronze.crm_sales_details
WHERE sls_order_dt IS NOT NULL
  AND (
        LEN(sls_order_dt) <> 8
     OR TRY_CONVERT(DATE, sls_order_dt, 112) IS NULL
  );

-- Invalid ship dates
SELECT sls_ship_dt
FROM bronze.crm_sales_details
WHERE sls_ship_dt IS NOT NULL
  AND (
        LEN(sls_ship_dt) <> 8
     OR TRY_CONVERT(DATE, sls_ship_dt, 112) IS NULL
  );

-- Invalid due dates
SELECT sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt IS NOT NULL
  AND (
        LEN(sls_due_dt) <> 8
     OR TRY_CONVERT(DATE, sls_due_dt, 112) IS NULL
  );

-----------------------------------------------------------------
-- erp_cust_az12
-----------------------------------------------------------------

-- Invalid birth dates
SELECT bdate
FROM bronze.erp_cust_az12
WHERE bdate IS NOT NULL
  AND TRY_CONVERT(DATE, bdate, 23) IS NULL;

-- Gender domain check
SELECT DISTINCT gen
FROM bronze.erp_cust_az12;

-----------------------------------------------------------------
-- erp_loc_a101
-----------------------------------------------------------------

-- Country code consistency
SELECT DISTINCT cntry
FROM bronze.erp_loc_a101;

-----------------------------------------------------------------
-- erp_px_cat_g1v2
-----------------------------------------------------------------

-- Whitespace violations
SELECT *
FROM bronze.erp_px_cat_g1v2
WHERE cat         <> TRIM(cat)
   OR subcat      <> TRIM(subcat)
   OR maintenance <> TRIM(maintenance);
