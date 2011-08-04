# JavaScript Expansions
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :defaults => [
    "http://ajax.googleapis.com/ajax/libs/jquery/1.6.2/jquery.min.js",
    "http://ajax.googleapis.com/ajax/libs/jqueryui/1.8.14/jquery-ui.min.js",
    "jquery-hashchange.min.js",
    "jquery.ui.timepicker.js"
  ]
)

# Stylesheet Expansions
ActionView::Helpers::AssetTagHelper.register_stylesheet_expansion(
  :jquery => [
    "jquery-ui-redmond.css",
    "jquery-ui-timepicker.css"
  ]
)
