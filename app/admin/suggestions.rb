ActiveAdmin.register Suggestion do
  filter :text

  index do
    column "Tweet Suggestion", :text
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :user, :label_method => :email
      f.input :twitter_user
      f.input :category, :label_method => :name_of_category
      f.input :text
    end
    f.buttons
  end
end
