view: inventory_items {
  sql_table_name: public.inventory_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    value_format_name: id
  }

  dimension: product_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_id ;;
    value_format_name: id
  }

  dimension: distribution_center_id {
    type: number
    hidden: yes
    sql: ${TABLE}.product_distribution_center_id ;;
    value_format_name: id
  }

  dimension: cost {
    type:  number
    sql: ${TABLE}.cost ;;
    value_format_name: usd
  }

  dimension_group: created {
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
    sql: ${TABLE}.created_at ;;
  }

  dimension_group: sold {
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
    sql: ${TABLE}.sold_at ;;
  }

  measure: count {
    type: count
    drill_fields: [
      id,
      created_time,
      sold_time,
      products.name,
      distribution_centers.name
    ]
  }
}
