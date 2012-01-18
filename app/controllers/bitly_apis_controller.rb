class BitlyApisController < InheritedResources::Base
  def create_or_update
    @bitly = BitlyApi.find_by_user_id(current_user.id)
    
    render :update do |page|
      unless @bitly.nil?
        @bitly.update_attributes(params[:bitly_api])
        page << "$('#loader-category').hide();"
        page << "$('.display_bitly').show();"
        page << "$('.form_bitly').hide();"
        page << "$('#post_notice').removeClass('error');"
        page << "$('#post_notice').addClass('success');"
        page << "$('#post_notice').show();"
        page << "$('#post_notice').html('Your bitly detail successfully updated.');"
        page << "setTimeout('$(\"#post_notice\").fadeOut(200)',5000)"
      else
        @bitly = BitlyApi.new(params[:bitly_api])
        if @bitly.save
          page << "$('#loader-category').hide();"
          page << "$('.form_bitly').hide();"
          page << "$('.display_bitly').show();"
          
          page.replace_html "display", :partial => "twitter_users/display_bitly", :locals => {:bitly => @bitly}
          
          page << "$('#post_notice').removeClass('error');"
          page << "$('#post_notice').addClass('success');"
          page << "$('#post_notice').show();"
          page << "$('#post_notice').html('Your bitly detail successfully saved.');"
          page << "setTimeout('$(\"#post_notice\").fadeOut(200)',5000)"
        end
      end
    end
  end
  
  def delete_bitly
    bitly_to_delete = BitlyApi.find_by_user_id(params[:id])
    bitly_to_delete.destroy
    
    redirect_to :back, :notice => "Your bitly has been deleted from your account."
  end
end
