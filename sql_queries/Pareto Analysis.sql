-- Pareto Analysis 

WITH product_loss AS (
    SELECT
        EXTRACT(YEAR FROM order_date) AS year,
        category_name,
        product_name,

        COALESCE(
            SUM(order_item_total) FILTER (
                WHERE order_status IN ('CANCELED','SUSPECTED_FRAUD')
            ), 0
        ) AS revenue_lost

    FROM sales_data
    WHERE order_date >= DATE '2015-01-01'
    AND order_date < DATE '2018-01-01'

    GROUP BY
        year,
        category_name,
        product_name
),

ranked AS (
    SELECT
        year,
        category_name,
        product_name,
        revenue_lost,

        SUM(revenue_lost) OVER (
            PARTITION BY year, category_name
        ) AS category_total_lost,

        SUM(revenue_lost) OVER (
            PARTITION BY year, category_name
            ORDER BY revenue_lost DESC
        ) AS cumulative_lost

    FROM product_loss
)

SELECT
    year,
    category_name,
    product_name,
    ROUND(revenue_lost, 2) AS revenue_lost,

    ROUND(
        cumulative_lost / NULLIF(category_total_lost, 0) * 100,
        2
    ) AS cumulative_loss_pct

FROM ranked
WHERE cumulative_lost / NULLIF(category_total_lost, 0) <= 0.80

ORDER BY
    year,
    category_name,
    revenue_lost DESC;
