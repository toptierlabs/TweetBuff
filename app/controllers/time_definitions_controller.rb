class TimeDefinitionsController < ApplicationController

  respond_to :json

  def index
    respond_with(@time_definitions)
  end

  def show
    respond_with(@time_definition)
  end

  def new
    @time_definition = TimeDefinition.new
    respond_with(@time_definition)
  end

  def create

    respond_with(@time_definition)
  end

  def edit
    respond_with(@time_definition)
  end

  def update
    respond_with(@time_definition)
  end

  def destroy

    respond_with(@time_definition)
  end

protected

  def get_buffer_preference
    @buffer_preference = current_user.buffer_preferences.find(params[:buffer_id])
  end



end