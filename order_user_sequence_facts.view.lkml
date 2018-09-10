view: order_user_sequence_facts {
  derived_table: {
    sql: select oi.user_id,oi.id as order_id,row_number() over(partition by oi.user_id order by oi.created_at asc ) as order_sequence,
        oi.created_at,
        MIN(oi.created_at) OVER(PARTITION BY oi.user_id) as first_ordered_date,
        LAG(oi.created_at) OVER (PARTITION BY oi.user_id ORDER BY oi.created_at asc) as previous_order_date,
        LEAD(oi.created_at) OVER(partition by oi.user_id ORDER BY oi.created_at) as next_order_date,
        DATEDIFF(DAY,CAST(oi.created_at as date),CAST(LEAD(oi.created_at) over(partition by oi.user_id ORDER BY oi.created_at) AS date)) as repurchase_gap
      from order_items oi
 ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: user_id {
    type: number
    primary_key: yes
    sql: ${TABLE}.user_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension: order_sequence {
    type: number
    sql: ${TABLE}.order_sequence ;;
  }

  dimension_group: created_at {
    type: time
    timeframes: [date,week,month,year]
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: first_ordered_date {
    type: time
    timeframes: [date,week,month,year]
    sql: ${TABLE}.first_ordered_date ;;
  }

  dimension_group: previous_order_date {
    type: time
    timeframes: [date,week,month,year]
    sql: ${TABLE}.previous_order_date ;;
  }

  dimension_group: next_order_date {
    type: time
    timeframes: [date,week,month,year]
    sql: ${TABLE}.next_order_date ;;
  }

  dimension: repurchase_gap {
    type: number
    sql: ${TABLE}.repurchase_gap ;;
  }

  dimension: is_first_purchase {
    type:  yesno
    sql:
        ${order_sequence} = 1
    ;;
  }

  dimension: is_subsequent_purchase {
    type: yesno
    sql:  ${next_order_date_date} is not null ;;
  }

  dimension: within_60_days_purchase {
    type: yesno
    hidden: yes
    sql: ${repurchase_gap} <= 60 ;;
  }

  measure: 60_repeat_purchase_count {
    type: count
    # hidden: yes
    filters: {
      field: within_60_days_purchase
      value: "Yes"
    }
  }

  measure: 60_repeat_purchase_rate  {
    type: number
    sql: 1.0*${60_repeat_purchase_count}/ nullif(${count},0);;
    value_format_name: percent_2
  }

  set: detail {
    fields: [
      user_id,
      order_id,
      order_sequence,
      repurchase_gap
    ]
  }
}
