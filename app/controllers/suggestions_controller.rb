class SuggestionsController < InheritedResources::Base
  def index
    @suggestions = Suggestion.all
  
    render :layout => false
  end
end
