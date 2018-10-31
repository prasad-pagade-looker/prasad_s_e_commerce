view: order_items {
  sql_table_name: public.order_items ;;

######### Custom Filters #########

  filter: reporting_period {
    description: "Use with Dynamic Measure Type for Dynamic Period Analysis"
    type: date
    convert_tz: no
  }

  dimension: reporting_period_days {
    hidden: yes
    type: number
    sql: datediff(days,{% date_start reporting_period  %}, {% date_end reporting_period %} ) ;;
  }

  dimension: comparison_period_start {
    hidden: yes
    type: date
    convert_tz: no
    sql: {% date_start reporting_period  %} - ${reporting_period_days}  ;;
  }

  dimension: comparison_period_end {
    hidden: yes
    type: date
   convert_tz: no
    sql: {% date_start reporting_period  %} - 1 ;;
  }

  dimension: period_over_period_comparison {
    description: "Use with Dynamic Measure"
    type: string
    sql:
        Case when ${created_date} >= ${comparison_period_start} and ${created_date} <= ${comparison_period_end} then 'Previous Period'
             when ${created_date} >= {% date_start reporting_period  %} and ${created_date} <= {% date_end reporting_period  %} then 'Current Period'
        else null
        end
    ;;
  }

  parameter: dynamic_measure_type {
    description: "Use with Reporting Period filter"
    type: string
    #suggestions: ["total_sale_price","counts"]
    allowed_value: {
      label: "Total Sales Price"
      value: "total_sale_price"
    }
    allowed_value: {
      label: "Order Counts"
      value: "order_counts"
    }
  }

  measure: dynamic_measure {
   description: "Use with period_over_period_comparison"
   label_from_parameter: dynamic_measure_type
    type: number
    sql:
        CASE WHEN {% parameter dynamic_measure_type  %} = 'total_sale_price' then ${total_sale_price}
             WHEN {% parameter dynamic_measure_type  %} = 'order_counts'     then ${count}
        ELSE NULL
        END
    ;;
    value_format_name: decimal_0
  }
################################################################################
  dimension: id {
    hidden: yes
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension_group: created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      hour,
      minute,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.created_at ;;
  }

###### Try the parameterized filters #######
  parameter: date_granularity {
    type: string
    allowed_value: {label: "3 Quarters ago" value: "Quarter"}
    allowed_value: {label:"3 Weeks ago" value: "Week"}
    allowed_value: {label:"3 Days ago" value: "Day"}
  }

  dimension: date_from_parameter {
    label_from_parameter: date_granularity
    type: number
    sql:
      CASE
        WHEN {% parameter date_granularity %} = 'Quarter' THEN
               DATEDIFF(qtr, 3 ,current_date)::VARCHAR
             -- ${created_quarter}-3::VARCHAR
             WHEN {% parameter date_granularity %} = 'Week' THEN
               DATEDIFF(w, 3, current_date)::VARCHAR
              --${created_week}-3::VARCHAR
             WHEN {% parameter date_granularity %} = 'Day' THEN
               DATEDIFF(dd, 3, current_date)::VARCHAR
              --${created_date}-3::VARCHAR
             ELSE
               NULL
      END
      ;;
  }
#############################################################
  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: recog_rev {
    type: string
    sql:
      case when ${status} = 'Cancelled' then 'Recognized rev'
      when ${status} = 'Complete' then 'More rev'
      else 'Nothing'
      end
    ;;
  }

  dimension_group: delivered {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      month_num,
      quarter,
      year
    ]
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      week_of_year,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
    value_format_name: usd_0
  }


  dimension: cost_price {
    type: number
    sql: ${inventory_items.cost} ;;
    value_format_name: usd
  }

  dimension: price_range {
    case: {
      when: {
        sql: ${sale_price} < 20 ;;
        label: "Inexpensive"

      }
      when: {
        sql: ${sale_price} > 20 and ${sale_price} <= 100 ;;
        label: "Affordable"

      }
      when: {
        sql: ${sale_price} > 100 ;;
        label: "Expensive"
      }
    }
  }



  dimension_group: shipped {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.shipped_at ;;
  }

  measure: total_sale_price  {
    label: "Total Revenue(sale_price)"
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: average_sale_price {
    #view_label: "Acverage Sale Price"
    type: average
    sql: ${sale_price} ;;
    value_format_name: usd
  }

  measure: max_item {
    #view_label: "Most expensive item"
    type: max
    sql: ${sale_price} ;;
  }
  measure: min_item {
    #view_label: "Least expensive item"
    type:  min
    sql: ${sale_price} ;;
  }

  measure: count {
    type: count
    drill_fields: [id,
                  created_time,
                  shipped_time,
                  delivered_time,
                  returned_time,
                  sale_price,
                  status,
                  products.name
                  ]
  }

  measure: count_orders_this_week {
    type: count
    filters: {
      field: created_week
      value: "this week"
    }
  }

#   measure: returned_count {
#     type: count
#     filters: {
#       field: status
#       value: "Returned"
#     }
#     drill_fields: [id,
#                   created_time,
#                   shipped_time,
#                   delivered_time,
#                   returned_time,
#                   sale_price,
#                   status,
#                   products.name]
#
#   }

  measure: percent_returned {
    type:  number
    sql: 1.0* ${returned_count}/ ${count} ;;
    value_format_name: "percent_1"
  }

  dimension: profit {
    description: "Profit made on any one item"
    hidden:  yes
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  measure: number_items_returned {
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: status
      value: "Returned"
    }

  }

  measure: item_return_rate {
    type:  number
    sql:  1.0*${number_items_returned}/ ${count} ;;
    value_format_name: percent_2
  }

  measure: total_profit {
    # DO not use this one
    type:  sum
    sql: ${profit} ;;
    drill_fields: [products.category, products.brand, sale_price]
    value_format_name: usd
  }

#   measure: total_gross_profit {
#     type: number
#     sql: 1.0* (${total_profit} )/ ${total_sale_price} ;;
#   }
  dimension: gross_margin {
    type: number
    value_format_name: usd
    sql: ${sale_price} - ${inventory_items.cost} ;;
  }

  dimension: item_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${gross_margin}/NULLIF(${sale_price},0) ;;
  }

  dimension: item_gross_margin_percentage_tier {
    type: tier
    sql: 100*${item_gross_margin_percentage} ;;
    tiers: [0, 10, 20, 30, 40, 50, 60, 70, 80, 90]
    style: interval
  }

  measure: total_gross_margin {
    type: sum
    value_format_name: usd
    sql: ${gross_margin} ;;
    #drill_fields: [detail*]
  }

  measure: median_sale_price {
    type: median
    value_format_name: usd
    sql: ${sale_price} ;;
    #drill_fields: [detail*]
  }

  measure: average_gross_margin {
    type: average
    value_format_name: usd
    sql: ${gross_margin} ;;
    #drill_fields: [detail*]
  }

  measure: total_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${total_gross_margin}/ NULLIF(${total_sale_price},0) ;;
  }

  measure: average_spend_per_user {
    type: number
    value_format_name: usd
    sql: 1.0 * ${total_sale_price} / NULLIF(${users.user_count},0) ;;
    #drill_fields: [detail*]
  }

########## Return Information ##########

  dimension: is_returned {
    type: yesno
    sql: ${returned_raw} IS NOT NULL ;;
  }

  measure: returned_count {
    type: count_distinct
    sql: ${id} ;;
    filters: {
      field: is_returned
      value: "yes"
    }

  }

  measure: returned_total_sale_price {
    type: sum
    value_format_name: usd
    sql: ${sale_price} ;;
    filters: {
      field: is_returned
      value: "yes"
    }
  }

  measure: return_rate {
    type: number
    value_format_name: percent_2
    sql: 1.0 * ${returned_count} / nullif(${count},0) ;;
  }

  ########### Total gross sales #########
#   measure: total_gross_sales_minus_rc {
#     hidden:  yes
#     type:  number
#     sql: ${sale_price} ;;
#       filters: {
#         field: status
#         value: "-Cancelled"
#       }
#     filters: {
#       field: status
#       value: "-Returned"
#     }
#     value_format_name: usd
#     }

########## Parameterized Filters ##################################

parameter: select_measure{
  description: "Select the measure to calucate the measure"
  type: string
  allowed_value: {
    label: "Sum"
    value: "SUM"
  }
  allowed_value: {
    label: "MAX"
    value: "MAX"
  }
  allowed_value: {
    label: "MIN"
    value: "MIN"
  }
}

measure: sales_dynamic_measure {
  description: "Use with select measure"
  type: number
  sql:
    CASE
      WHEN {% parameter select_measure %} = 'SUM' THEN SUM(${sale_price})
      WHEN {% parameter select_measure %} = 'MAX' THEN MAX(${sale_price})
      WHEN {% parameter select_measure %} = 'MIN' THEN MIN(${sale_price})
    ELSE
      NULL
    END
  ;;
  value_format_name: usd
}


####################################################################

####### Average Spend per Customer #################################

  measure: avg_spend_per_customer {
    type:  number
    sql:  1.0*${total_sale_price}/ nullif(${count},0) ;;
    value_format_name: usd_0
  }

}


###### Running totals ###############################################
view: order_running_totals {
  derived_table: {
    sql:
select id, order_id, user_id, inventory_item_id, status, created_at,
  sum(sale_price) over (order by created_at asc rows unbounded preceding) as running_total
  FROM public.order_items  ;;
  }

  dimension: o_id {
    primary_key: yes
    hidden: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}.user_id ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: status {
    type: string
    sql:  ${TABLE}.status ;;
  }


  dimension: sales_running_total {
    type: number
    sql: ${TABLE}.running_total ;;
    value_format_name: usd
  }






}
