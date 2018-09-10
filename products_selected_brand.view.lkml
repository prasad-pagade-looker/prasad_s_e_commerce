view: products_selected_brand {
  # You can specify the table name if it's different from the view name:
  derived_table: {
    sql: select p.category, p.name, p.brand from products p
          where {% condition brand_name %} p.brand {% endcondition %}
            ;;
  }

  # Define your dimensions and measures here, like this:
  filter: brand_name {
    suggest_dimension: products.brand_new
    suggest_explore: order_items
  }

  dimension: category {
    type: string
    hidden: yes
    sql: ${TABLE}.category ;;
  }

  dimension: name {
    type: string
    hidden:  yes
    sql: ${TABLE}.name ;;
  }

  dimension: brand {
    type: string
    hidden: yes
    sql: ${TABLE}.brand ;;
  }

  dimension: brand_comparator {
    sql:
    case
      when ${products.brand_new} = ${products_selected_brand.brand} then '(1) '|| ${products.brand_new}
      else '(2) Rest Of Population'
    end
    ;;
  }


}
