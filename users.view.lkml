view: users {
  # # You can specify the table name if it's different from the view name:
  # sql_table_name: my_schema_name.tester ;;
  sql_table_name: public.users ;;
  #
  # # Define your dimensions and measures here, like this:
  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  dimension: user_id {
    primary_key: yes
    hidden: yes
    sql: ${TABLE}.id ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.first_name || ' ' || ${TABLE}.last_name ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}.city ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}.state ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}.zip ;;
  }

  dimension: country {
    type: string
    sql: ${TABLE}.country ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}.age ;;
  }

  dimension: age_bucket {
    type: tier
    tiers: [15,26,36,56,66]
    style: integer
    sql: ${age} ;;
  }

  dimension: gender {
    type: string
    sql: ${TABLE}.gender ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: traffic_source {
    type: string
    sql: ${TABLE}.traffic_source ;;
  }

  dimension: latitude {
    type: number
    sql: ${TABLE}.latitude ;;
  }

  dimension: longitude {
    type: number
    sql: ${TABLE}.longitude ;;
  }

  dimension: location {
    type: location
    sql_latitude: ${latitude} ;;
    sql_longitude: ${longitude} ;;
  }

  dimension: approx_location {
    type: location
    drill_fields: [location]
    sql_latitude: round(${TABLE}.latitude,1) ;;
    sql_longitude: round(${TABLE}.longitude,1) ;;
  }

  measure: user_count {
    type:  count
  }

  measure: count_cali_users {
    description: "users from California State only"
    label: "California users"
    type:  count
    filters: {
      field: state
      value: "California"
    }
    drill_fields: [customer_name,
                  city,age,email]
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

############Month-to-date and YEAR-TO-DATE####################

  dimension: is_before_mtd {
    type: yesno
    sql: ( ${TABLE}.created_at not between DATE_TRUNC('month', CURRENT_TIMESTAMP) and CURRENT_TIMESTAMP ) ;;
  }
  dimension: is_before_ytd {
    type: yesno
    sql: ( ${TABLE}.created_at  not between DATE_TRUNC('year', CURRENT_TIMESTAMP) and CURRENT_TIMESTAMP ) ;;
  }


##########  New Customer details ##########

dimension: is_new_customer {
  type:  yesno
  sql: datediff(days, ${created_date}, current_date) < 90 ;;
}

dimension: new_users_vs_old_user {
  type:  string
  case: {
    when: {
      sql: ${is_new_customer} = 1 ;;
      label: "New Customer"
    }
    else: "Old Customer"
  }

}



###### PS Case Study 2  ########
  dimension: days_since_signup {
    type: number
    sql: DATEDIFF(d, ${created_raw}, current_date) ;;
    value_format_name: id
  }

  dimension: months_since_signup {
    type: number
    sql: DATEDIFF(mm, ${created_raw}, current_date)  ;;
    value_format_name: id
  }

  dimension: months_since_signup_cohort{
    type: number
    sql: datediff('month',${users.created_raw},${order_items.created_raw});;
  }


  dimension: months_since_signup_bucket {
    type: tier
    tiers: [0,5,10,15,20,25,30,35,40,45,50,75,100]
    style: integer
    sql: ${days_since_signup} ;;
  }

  measure: avg_days_since_signup {
    type:  average
    sql: ${days_since_signup} ;;
    value_format_name: id
  }

  measure: avg_months_since_signup {
    type: average
    sql: ${months_since_signup} ;;
    value_format_name: id
  }



#   #One dimension of each of the following types
# Number, case, string, tier, distance, location, zipcode, yesno
# One measure of each of the following types
# Min, max, average, sum, sum_distinct

  # dimension: lifetime_orders {
  #   description: "The total number of orders for each user"
  #   type: number
  #   sql: ${TABLE}.lifetime_orders ;;
  # }
  #
  # dimension_group: most_recent_purchase {
  #   description: "The date when each user last ordered"
  #   type: time
  #   timeframes: [date, week, month, year]
  #   sql: ${TABLE}.most_recent_purchase_at ;;
  # }
  #
  # measure: total_lifetime_orders {
  #   description: "Use this for counting lifetime orders across many users"
  #   type: sum
  #   sql: ${lifetime_orders} ;;
  # }
}
