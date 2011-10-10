class BitlyApisController < InheritedResources::Base
  def create_or_update
    bitly = BitlyApi.find(current_user.id)
    if bitly
      bitly.update_attributes(params[:bitly_api])
      redirect_to :back, :notice => "Your bitly detail successfully updated."
    else
      @bitly = BitlyApi.new(params[:bitly_api])
      if @bitly.save
        redirect_to :back, :notice => "Your bitly detail successfully saved."
      end
    end
  end
end
