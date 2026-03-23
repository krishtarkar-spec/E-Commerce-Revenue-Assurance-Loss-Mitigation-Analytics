-- Main Table
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    customer_country,
    customer_state,
    customer_city,
    category_name,
    product_name,

    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS active_users,

    ROUND(SUM(sales), 2) AS total_revenue,
    ROUND(SUM(order_profit_per_order), 2) AS total_profit,
    SUM(order_item_quantity) AS total_products_sold,

    COUNT(*) FILTER (
        WHERE order_status = 'CANCELED'
    ) AS canceled_orders,

    COUNT(*) FILTER (
        WHERE order_status = 'SUSPECTED_FRAUD'
    ) AS suspected_fraud_orders,

    COUNT(*) FILTER (
        WHERE order_status IN ('CANCELED','SUSPECTED_FRAUD')
    ) AS return_related_orders,

    COALESCE(
        ROUND(
            SUM(order_item_total) FILTER (
                WHERE order_status IN ('CANCELED','SUSPECTED_FRAUD')
            ), 2
        ), 0
    ) AS revenue_lost,

    COALESCE(
        ROUND(
            SUM(order_profit_per_order) FILTER (
                WHERE order_status IN ('CANCELED','SUSPECTED_FRAUD')
            ), 2
        ), 0
    ) AS profit_lost

FROM sales_data
WHERE order_date >= DATE '2015-01-01'
AND order_date < DATE '2018-01-01'

GROUP BY
    year,
    customer_country,
    customer_state,
    customer_city,
    category_name,
    product_name

ORDER BY
    year,
    category_name,
    total_revenue DESC;
