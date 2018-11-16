connection: "thelook_events_redshift"

include: "*.view.lkml"         # include all views in this project
#include: "*.dashboard.lookml"  # include all dashboards in this project

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.
#
# explore: onemarket_filters {
#   from: vintel_viz_filter_in_venue_measure_as_of_ts_poc
#   sql_always_where:  ;;
# }
# explore: order_items_hidden {
#   hidden: yes
#   from: order_items

# }
explore: order_items {
  always_join: [inventory_items]
#   access_filter: {
#     field: products.brand_new
#     user_attribute: brand
#   }
  #sql_always_where: ${order_items.period_over_period_comparison} is not null ;;

  join: user_rev  {
    type:  left_outer
    relationship: many_to_one
    sql_on: ${order_items.user_id} = ${user_rev.id};;
  }
  join: users {
    sql_on: ${order_items.user_id} = ${users.user_id} ;;
    type: inner
    relationship: many_to_one
  }

  join: dt_user_purchase_activity {
    view_label: "User Rentention Cohort"
    sql_on: ${users.user_id} = ${dt_user_purchase_activity.user_id} ;;
    type: left_outer
    relationship: one_to_many
  }
  join: inventory_items {
    sql_on: ${inventory_items.id} = ${order_items.inventory_item_id} ;;
    type: left_outer
    relationship: one_to_one
  }

  join: products {
    sql_on: ${products.id} = ${inventory_items.product_id} ;;
    type: left_outer
    relationship: many_to_one
  }

  join: product_selected {
    type: cross
    relationship: one_to_one
  }

  join: products_selected_brand {
    type:  cross
    relationship: one_to_one
  }

  join: order_running_totals {
    type:  left_outer
    sql_on: ${order_items.id} = ${order_running_totals.o_id} ;;
    relationship: one_to_one
  }

  join: order_user_sequence_facts {
    type: left_outer
    sql_on: ${users.user_id} = ${order_user_sequence_facts.user_id} ;;
    relationship: one_to_one
  }

}
####### Wallet share application  #############
explore: orders_wallet_share {
  view_name: products

  join: product_selected {
    type: cross
    relationship: many_to_many
  }

}



#explore: state_orders {}
# explore: customers {
#   from: users
#   join: user_rev {
#     type: left_outer
#     sql_on: ${customers.user_id} = ${user_rev.id} ;;
#     relationship: one_to_one
#   }
#   }
