ActiveAdmin.register Suggestion do
  filter :text

  index do
    column "Tweet Suggestion", :text
    default_actions
  end

end
