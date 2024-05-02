/*							///////////////////////////
 							/E-COMMERCE SALES ANALYSIS/
							///////////////////////////
*/
-------------------------------------------------------------------------
--1. Memfilter bulan dengan total nilai transaksi paling besar di 2021 --
-------------------------------------------------------------------------
SELECT 
	EXTRACT(month FROM order_date) as month_,
    sum(after_discount) total_transaction
FROM 
	order_detail
WHERE 
	EXTRACT(year FROM order_date) = 2021 AND
    is_valid = 1
GROUP by 1
order by 2 DESC
LImit 1;
---------------------------------------------------------------------
--2. Memfilter kategori dengan nilai transaksi paling besar di 2022--
---------------------------------------------------------------------
SELECT *
FROM
	sku_detail;

SELECT 
	s.category,
    sum(o.after_discount) total_transaction
FROM order_detail o left JOIN sku_detail s ON o.sku_id = s.id
WHERE
	EXTRACT(YEAR FROM o.order_date) = 2022 AND
	is_valid = 1
GROUP by 1
order by 2 DESC
LIMIT 1;
----------------------------------------------------------------------------------------------
-- 3. Membandingkan nilai transaksi dari masing-masing kategori pada tahun 2021 dengan 2022 --
-- dan kategori apa saja yang mengalami peningkatan dan penurunan                           --
----------------------------------------------------------------------------------------------
SELECT 
    category,
    total_transaction_2021,
    total_transaction_2022,
    CASE
        WHEN total_transaction_2022 > total_transaction_2021 THEN 'Peningkatan'
        WHEN total_transaction_2022 < total_transaction_2021 THEN 'Penurunan'
        ELSE 'Tidak berubah'
    END AS trend
FROM
(SELECT 
    sd.category,
    SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2021 THEN od.after_discount ELSE 0 END) AS total_transaction_2021,
    SUM(CASE WHEN EXTRACT(YEAR FROM od.order_date) = 2022 THEN od.after_discount ELSE 0 END) AS total_transaction_2022
FROM 
    order_detail od
    INNER JOIN sku_detail sd ON od.sku_id = sd.id
WHERE 
    EXTRACT(YEAR FROM od.order_date) IN (2021, 2022)
    AND od.is_valid = 1
GROUP BY 
    sd.category
) as transaction_summary
order by trend;
------------------------------------------------------------------------------------
-- 4. Memfilter top 5 metode pembayaran yang paling populer digunakan selama 2022 --
------------------------------------------------------------------------------------
SELECT 
	pd.payment_method,
    COUNT(DISTINCT od.id) as total_order
FROM 
	order_detail od LEFT JOIN payment_detail pd on od.payment_id = pd.id
WHERE
	EXTRACT(YEAR FROM od.order_date) = 2022
    AND is_valid = 1
GROUP by 1
order by 2 DESC
limit 5;

SELECT * FROM sku_detail

---------------------------------------------------------
--5. Memfilter top 5 produk dengan transaksi terbanyak --
---------------------------------------------------------

  
WITH transaction_table AS (
  SELECT 
    CASE
      WHEN LOWER(sd.sku_name) LIKE '%samsung%' THEN 'Samsung'
      WHEN LOWER(sd.sku_name) LIKE '%apple%' OR LOWER(sd.sku_name) LIKE '%iphone%' OR LOWER(sd.sku_name) LIKE '%macbook%' THEN 'Apple'
      WHEN LOWER(sd.sku_name) LIKE '%sony%' THEN 'Sony'
      WHEN LOWER(sd.sku_name) LIKE '%huawei%' THEN 'Huawei'
      WHEN LOWER(sd.sku_name) LIKE '%lenovo%' THEN 'Lenovo'
    END AS product_brand,
    SUM(od.after_discount) AS transaction_value
  FROM 
    order_detail od 
  LEFT JOIN 
    sku_detail sd ON od.sku_id = sd.id
  WHERE
    is_valid = 1
  GROUP BY 
    product_brand
  ORDER BY 
    transaction_value DESC
)

SELECT * FROM transaction_table
WHERE product_brand IS NOT NULL;
