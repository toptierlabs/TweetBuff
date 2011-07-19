# JavaScript Expansions
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :defaults => [
    "http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js",
    "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/jquery-ui.min.js"
  ]
)

# Stylesheet Expansions
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :jquery => [
    "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/themes/base/jquery-ui.css"
  ]
)
