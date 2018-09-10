view: pitstop {
  # # You can specify the table name if it's different from the view name:
   sql_table_name: my_schema_name.pitstop ;;
  #
  # # Define your dimensions and measures here, like this:

  dimension: pitstop_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.pitstop_id ;;
  }

  dimension: car_id {
    type: number
    sql: ${TABLE}.car_id ;;
  }

  dimension: racer_id {
    type: number
    sql: ${TABLE}.racer_id ;;
  }

  dimension_group: start_time {
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
    sql: ${TABLE}.start_time ;;
  }

  dimension_group: end_time {
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
    sql: ${TABLE}.end_time ;;
  }

  dimension: num_pit_crew_mem {
    type:  number
    sql:  ${TABLE}.number_of_pit_crew_members ;;
  }

  dimension: time_spent_in_pit {
    type:  number
    sql: DATEDIFF(seconds, ${start_time_date}, ${end_time_date}) ;;
  }

  measure: total_time_spent {
    type:  sum
    sql: ${time_spent_in_pit} ;;
  }

  measure: avg_time {
    type: average
    sql: ${time_spent_in_pit} ;;
  }


  # dimension: user_id {
  #   description: "Unique ID for each user that has ordered"
  #   type: number
  #   sql: ${TABLE}.user_id ;;
  # }
  #
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

# view: pitstop {
#   # Or, you could make this view a derived table, like this:
#   derived_table: {
#     sql: SELECT
#         user_id as user_id
#         , COUNT(*) as lifetime_orders
#         , MAX(orders.created_at) as most_recent_purchase_at
#       FROM orders
#       GROUP BY user_id
#       ;;
#   }
#
#   # Define your dimensions and measures here, like this:
#   dimension: user_id {
#     description: "Unique ID for each user that has ordered"
#     type: number
#     sql: ${TABLE}.user_id ;;
#   }
#
#   dimension: lifetime_orders {
#     description: "The total number of orders for each user"
#     type: number
#     sql: ${TABLE}.lifetime_orders ;;
#   }
#
#   dimension_group: most_recent_purchase {
#     description: "The date when each user last ordered"
#     type: time
#     timeframes: [date, week, month, year]
#     sql: ${TABLE}.most_recent_purchase_at ;;
#   }
#
#   measure: total_lifetime_orders {
#     description: "Use this for counting lifetime orders across many users"
#     type: sum
#     sql: ${lifetime_orders} ;;
#   }
# }

# 2. Imagine a company that collects data on car races. Specifically, for this use case, they have one large table for pitstops with the following columns:
# Pitstop_id (int)
# Car_id (int)
# Racer_id (int)
# Start_time (UTC timestamp)
# End_time (UTC timestamp)
# Number_of_pit_crew_members (int)
# Given this information, create a model that would allow for the following metrics/analyses:
# The total amount of time, in seconds, spent in the pit.
# The average of the total time spent in the pit by racer.
# See the average length of a pitstop over time. (assume there is only a single race which is 4 hours long, and we want to see the average pitstop time that occur over 15 minute intervals).
# The average pitstop time per racer, per car, and per number of members of the pit crew (assume there are between 8 and 16 members in the pit crew)
# The total number of pit stops per racer.
# The average length of pit stops by which pitstop it is in sequence for the racers.
# I want to see what the difference is, by individual racer, in the length of a pitstop from one pit stop to the next. Does this increase over each subsequent pitstop, or go down. I want one metric that is the average of all of this.
