
view: product_selected {
  # Or, you could make this view a derived table, like this:
  derived_table: {
    sql: select p.category, p.name, p.brand from products p
          where {% condition item_name %} p.name {% endcondition %}
            ;;
  }

  # Define your dimensions and measures here, like this:
  filter: item_name {
    suggest_dimension: products.name
    suggest_explore: order_items
  }

  dimension: category {
    type: string
    sql: ${TABLE}.category ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: brand {
    type: string
    sql: ${TABLE}.brand ;;
  }

  dimension: comparison {
  sql:
  case
    when ${products.name} = ${product_selected.name}        then '(1) '|| ${products.name}
    when ${products.brand_new} = ${product_selected.brand}  then '(2) Rest of '||${products.brand_new}
    else '(3) Rest Of Population'
  end
  ;;
  }

}
