connection: "thelook_events_redshift"

include: "*.view.lkml"                       # include all views in this project
# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard

## Explore definitions
explore: order_items_ext {
  label: "Order Items"
  view_label: "Order Items"
  fields: [-order_items_ext.date_from_parameter]
  join: inventory_items_ext {
    view_label: "Inventory Items"
    type: full_outer
   sql_on: ${order_items_ext.inventory_item_id} = ${inventory_items_ext.id} ;;
    relationship: many_to_one
  }

  join: products {
    sql_on: ${inventory_items_ext.product_id} = ${products.id} ;;
    relationship: many_to_one
  }
  join: product_sparklines {
    view_label: "Products"
    sql_on: ${products.brand_new} = ${product_sparklines.brand} ;;
    relationship: one_to_one
  }


}

## Custom views - derived tables for Spark lines
view: product_query {
# Let Looker write this query for BRAND, DATE, measureing SALES and ORDER for 30 days
  derived_table: {
    sql: SELECT
        DATE(CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', order_items.created_at)) AS created_date,
        products.brand AS brand,
        COUNT(DISTINCT order_items.id) AS orders_count,
        SUM(order_items.sale_price) AS sales
      FROM public.order_items AS order_items

      LEFT JOIN public.inventory_items AS inventory_items ON order_items.inventory_item_id = inventory_items.id
      LEFT JOIN public.products AS products ON inventory_items.product_id = products.id
      WHERE
        (((order_items.created_at) >= ((CONVERT_TIMEZONE('America/Los_Angeles', 'UTC', DATEADD(day,-29, DATE_TRUNC('day',CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE())) )))) AND (order_items.created_at) < ((CONVERT_TIMEZONE('America/Los_Angeles', 'UTC', DATEADD(day,30, DATEADD(day,-29, DATE_TRUNC('day',CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', GETDATE())) ) ))))))
      GROUP BY 1,2 ;;
  }
}

view: product_possible_values {
  # Get all the possible values for dates and brands combinations so we can zero fill.
  derived_table: {
    sql: SELECT date, brand FROM
        (SELECT DISTINCT created_date as date FROM ${product_query.SQL_TABLE_NAME}) as dates
      CROSS JOIN (SELECT DISTINCT brand FROM ${product_query.SQL_TABLE_NAME}) brands ;;
  }
}

view: product_sparklines {
  derived_table: {
    sql: SELECT
        pv.brand
        , LISTAGG(COALESCE(pq.sales,0.0),',') WITHIN GROUP (ORDER BY pv.date) as sales
        , LISTAGG(COALESCE(pq.orders_count,0),',') WITHIN GROUP (ORDER BY pv.date) as orders
      FROM  ${product_query.SQL_TABLE_NAME} as pq
      RIGHT JOIN  ${product_possible_values.SQL_TABLE_NAME} as pv
        ON pv.date = pq.created_date
         AND pv.brand = pq.brand
      GROUP BY 1 ;;
  }
  dimension: brand {hidden: yes}
  dimension: sales{hidden: yes}
  dimension: orders{hidden: yes}

  dimension: brand_sales_30_days{
    sql: '1';;
    html:
      <img src="https://chart.googleapis.com/chart?chs=200x50&cht=ls&chco=0077CC&chf=bg,s,FFFFFF00&chds=a&chxt=x,y&chd=t:{{sales._value}}&chxr=0,-30,0,4">
    ;;
  }
  dimension: brand_orders_30_days{
    sql: '1';;
    html: |
        <img src="https://chart.googleapis.com/chart?chs=200x50&cht=ls&chco=0077CC&chf=bg,s,FFFFFF00&chds=a&chxt=x,y&chd=t:{{orders._value}}&chxr=0,-30,0,4">
        ;;
  }
}




## View to extend
view: order_items_ext {
  extends: [order_items]
  dimension_group: created {
    type: time
    timeframes: [time, hour, date, week, month, day_of_week, month_num, week_of_year]
    sql:${TABLE}.created_at ;;

  }
}

view: inventory_items_ext {
  extends: [inventory_items]
}
