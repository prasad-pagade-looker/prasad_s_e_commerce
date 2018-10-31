view: vintel_viz_filter_in_venue_measure_as_of_ts_poc {
  # sql_table_name: vintel_looker_dashboard.vintel_viz_filter_in_venue_measure_as_of_ts_POC ;;
  sql_table_name: public.order_items ;;

  dimension_group: measure_as_of_ts {
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

  dimension_group: month_end {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Month_End_Date ;;
  }

  dimension_group: month_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Month_Start_Date ;;
  }

  dimension_group: prev_month_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Prev_Month_Start_Date ;;
  }

  dimension_group: prev_quarter_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Prev_Quarter_Start_Date ;;
  }

  dimension_group: prev_year_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Prev_Year_Start_Date ;;
  }

  dimension_group: quarter_end {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Quarter_End_Date ;;
  }

  dimension_group: quarter_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Quarter_Start_Date ;;
  }

  dimension_group: year_end {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Year_End_Date ;;
  }

  dimension_group: year_start {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.Year_Start_Date ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  filter:  foo {
    view_label: "with grain"
    # type: date_time
    suggest_dimension: vintel_viz_filter_in_venue_measure_as_of_ts_poc.multi
    suggest_explore: vintel_viz_filter_in_venue_measure_as_of_ts_poc

  }

  dimension: period {
    type: string
    sql:
      case
     WHEN  (${measure_as_of_ts_date} >= ${start_date})
      AND  (${measure_as_of_ts_date} <=  ${end_date})  then 'this_period'
     WHEN  (${measure_as_of_ts_date} >= ${prev_start_date})
          AND  (${measure_as_of_ts_date} <  ${start_date}) then 'prev_period'
      else null ;;
  }

#  filter: multi_filter {
#    type:  string
#   suggest_dimension: vintel_viz_filter_in_venue_measure_as_of_ts_poc.
#
#  }


  dimension: multi {
    view_label: "with grain"
    type: string
    suggest_persist_for: "0 seconds"
    sql:
      {% assign grain = passthrough._sql %}
      {% if grain contains 'Q' %}
        ${quarter}
      {% elsif grain contains 'M' %}
        ${month}
      {% elsif grain contains 'Y' %}
        ${year}
      {% endif %}
      ;;
  }
  dimension: month {
    view_label: "with grain"
    type: string
    sql: ${measure_as_of_ts_month} ;;
  }

  dimension: quarter {
    view_label: "with grain"
    type: string
    sql: ${measure_as_of_ts_quarter} ;;
  }

  dimension: year {
    view_label: "with grain"
    type: string
    sql: cast(${measure_as_of_ts_year} as string);;
  }




  dimension: passthrough {
    view_label: "with grain"
    hidden: yes
    type: string
    sql: {% parameter grain %} ;;
  }

  parameter: grain {
    view_label: "with grain"
    type: unquoted
    default_value: "Y"
    allowed_value: {
      label: "Quarter"
      value: "Q"
    }
    allowed_value: {
      label: "Month"
      value: "M"
    }
    allowed_value: {
      label: "Year"
      value: "Y"
    }
  }


  dimension: start_date {
    view_label: "with grain"
    type: string
    suggest_persist_for: "0 seconds"
    sql:  case
          when {% condition grain %}  'M' {% endcondition %} then ${month_start_date}
           when {% condition grain %}  'Q' {% endcondition %} then ${quarter_start_date}
             when {% condition grain %}  'Y' {% endcondition %} then ${year_start_date}
            else null
          end
            ;;
  }
  dimension: end_date {
    view_label: "with grain"
    type: string
    suggest_persist_for: "0 seconds"
    sql:  case
          when {% condition grain %}  'M' {% endcondition %} then ${month_end_date}
          when {% condition grain %}  'Q' {% endcondition %} then ${quarter_end_date}
          when {% condition grain %}  'Y' {% endcondition %} then ${year_end_date}
          else null
          end
          ;;
  }

  dimension: prev_start_date {
    view_label: "with grain"
    type: string
    suggest_persist_for: "0 seconds"
    sql:  case
          when {% condition grain %}  'M' {% endcondition %} then ${prev_month_start_date}
          when {% condition grain %}  'Q' {% endcondition %} then ${prev_quarter_start_date}
          when {% condition grain %}  'Y' {% endcondition %} then ${prev_year_start_date}
          else null
          end
          ;;
  }


  measure: visitor_this_preiod {
    view_label: "measure"

    type: count_distinct
    sql:
      CASE
      WHEN  (${measure_as_of_ts_date} >= ${start_date})
      AND  (${measure_as_of_ts_date} <=  ${end_date})
      THEN ${vintel_base_measures_attributes_in_venue.master_id}
      ELSE NULL
      END
      ;;
  }

  measure: visitor_prev_preiod {
    view_label: "measure"

    type: count_distinct
    sql:
      CASE
      WHEN  (${measure_as_of_ts_date} >= ${prev_start_date})
      AND  (${measure_as_of_ts_date} <  ${start_date})
      THEN ${vintel_base_measures_attributes_in_venue.master_id}
      ELSE NULL
      END
      ;;
  }

  measure: percent_change {
    view_label: "grain measure"
    type: number
    sql:
            (${visitor_this_preiod} - ${visitor_prev_preiod})*1.0/nullif(${visitor_prev_preiod},0)

          ;;
    value_format_name: percent_1
  }


}
