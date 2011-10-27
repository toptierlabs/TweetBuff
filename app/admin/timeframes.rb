ActiveAdmin.register Timeframe do
  filter :name
  filter :value
  filter :unit

  index do
    column :name
    column :value
    column :unit
    default_actions
  end
end
