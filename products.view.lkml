view: products {
  sql_table_name: public.products ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
    value_format_name: id
  }

  dimension: cost {
    type: number
    sql: ${TABLE}.cost ;;
    value_format_name: usd
  }

  dimension: retail_price {
    type: number
    sql: ${TABLE}.retail_price ;;
    value_format_name: usd
  }

  dimension: sku {
    type: string
    sql: ${TABLE}.sku ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.department ;;
  }

#   dimension: brand {
#     type: string
#     sql: ${TABLE}.brand ;;
#     link: {
#       label: "Google Search"
#       url: "http://www.google.com/search?q={{ value }}+Clothing"
#       icon_url: "http://google.com/favicon.ico"
#     }
#   }

  dimension: brand_new {
    type: string
    sql: ${TABLE}.brand ;;
    drill_fields: [brand_drill*]
    link: {
      label: "Google Search"
      url: "http://www.google.com/search?q={{ value }}+Clothing"
      icon_url: "http://google.com/favicon.ico"
    }
    link: {
      label: "Facebook Search"
      url: "https://www.facebook.com/search?q= {{value}}+Clothing"
      icon_url: "https://www.facebook.com/favicon.ico"
    }
  }

  ##### Set for brand's drill down ######

  set: brand_drill {
    fields: [
      name,
      category
    ]
  }
###########################################
  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  measure: total_cost {
    type: sum
    sql: ${cost} ;;
    value_format_name: usd
  }

  measure: count {
    type: count
    drill_fields: [
      id,
      cost,
      retail_price,
      sku,
      department,
      brand_new,
      name,
      category
    ]
  }
}
