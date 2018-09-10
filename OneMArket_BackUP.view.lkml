view: tree_chart_test {
  sql_table_name: shopper_lens_demo.tree_chart_test ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

###### Backup###########################
  # measure: change {
  #   type: sum
  #   sql: ${TABLE}.change ;;
  #   #value_format_name: percent_0
  # }
########################################

  measure: change {
    type: string
    #type: sum
    sql: CONCAT(MAX(CAST(ROUND((${TABLE}.change*100),1) as STRING)), '%' );;

  }

  dimension: measure {
    type: string
    sql: ${TABLE}.measure ;;
  }

  dimension: parentid {
    type: number
    value_format_name: id
    sql: ${TABLE}.parentid ;;
  }
##### BACKUP#############################
#   measure: value_ {
#   #  type: string
#    type: sum
#     sql: ${TABLE}.value_ ;;
#     sql:
#       CASE WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Customer Avg Selling Price' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CAST(${TABLE}.value_ as STRING)))
#           ELSE NULL
#       END
#    ;;
#
#   }
#######################################
  measure: value_ {
    type: string
    # type: sum
    #sql: ${TABLE}.value_ ;;
    sql:
      CASE
            WHEN ${measure} = 'Total Sales' THEN MAX(CONCAT('$',CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3)))) --MAX(CAST(NUMFORMAT(${TABLE}.value_, '###,###') as STRING))    ----Test NUMFORMAT(MyPrice, '$###,###.##')
            WHEN ${measure} = 'Customer Sales' THEN MAX(CONCAT('$',CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3))))
            WHEN ${measure} = 'Non-Customer Linked Sales' THEN MAX(CONCAT('$',CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3))))
            WHEN ${measure} = 'Customer Transactions' THEN MAX(CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3)))
            WHEN ${measure} = 'Customer Frequency' THEN MAX(CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3)))
            WHEN ${measure} = 'Non-Customer Avg Selling Price' THEN MAX(CONCAT('$',CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3))))
           WHEN ${measure} = 'Customer Avg Selling Price' THEN MAX(CONCAT('$',CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3))))
           WHEN ${measure} = 'Customer Items Per Basket' THEN MAX(CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3)))
           WHEN ${measure} = 'Customer Transaction Value' THEN MAX(CONCAT('$',CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3))))
           WHEN ${measure} = 'Non-Customer Items Per Basket' THEN MAX(CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3)))
          WHEN ${measure} = 'Customers' THEN MAX(CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3)))
          WHEN ${measure} = 'Non-Customer Transactions' THEN MAX(CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3)))
          WHEN ${measure} = 'Non-Customer Transaction Value' THEN MAX(CONCAT('$',CONCAT(FORMAT("%'d", CAST(${TABLE}.value_ AS int64)), SUBSTR(FORMAT("%.2f", CAST(${TABLE}.value_ AS float64)), -3))))
          ELSE NULL
      END
   ;;

    }

    measure: count {
      type: count
      drill_fields: [id]
    }
  }
