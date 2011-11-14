# JavaScript Expansions
ActionView::Helpers::AssetTagHelper.register_javascript_expansion(
  :defaults => [
    "jquery.min.js",
    "jquery-ui.min.js",
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
