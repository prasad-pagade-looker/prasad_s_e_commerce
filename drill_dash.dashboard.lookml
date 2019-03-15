- dashboard: custom_drill_test
  title: custom drill test
  layout: newspaper
  elements:
  - title: New Tile
    name: New Tile
    model: prasad_s_ecommerce
    explore: order_items
    type: table
    fields:
    - order_items.created_date
    - users.gender
    - order_items.total_sale_price
    sorts:
    - order_items.created_date desc
    limit: 500
    column_limit: 50
    row: 0
    col: 0
    width: 8
    height: 6
