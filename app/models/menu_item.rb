class MenuItem < Hashie::Dash
  include Haml::Helpers
  
  property :title
  property :path
  property :select
  property :auth
  property :submenu,  :default => nil
  property :menu,     :default => nil
  property :priority, :default => 0
  
  
  def initialize(title, settings)
    @title    = title
    @path     = settings.key?(:path) ? settings.delete(:path)       : "/"
    @select   = settings.key?(:select) ? settings.delete(:select)   : "/^\/$/"
    @auth     = settings.key?(:auth) ? settings.delete(:auth)       : "any"
    @submenu  = settings.key?(:submenu) ? settings.delete(:submenu) : nil
    @menu     = settings.key?(:menu) ? settings.delete(:menu)       : nil
  end
  
  def selected(uri)
    uri =~ Regexp.new(@select)
  end
  
  # def menu=(menu)
  #   @menu = menu
  # end
  
  def authorized?(authorization)
    Rails.logger.debug("[MENU] authorization check -- User signed in? #{authorization} :: Menu item auth level: #{@auth}")
    
    return case @auth
    when "any" # Any state
      true
    when "in" # Must be signed in
      authorization == true
    when "out" # Must be signed out
      authorization == false
    end
  end
  
  def render(current_uri, options)
    Rails.logger.debug("[MENUS] Rendering menu item for #{@title}")
    raise "option :state not set in MenuItem render" unless options.key?(:state)
    
    item_classes    = options.key?(:class) ? [options[:class]].flatten : []
    render_submenus = options.key?(:render_submenus) ? options[:render_submenus] : false
    authorization   = options[:state] # true or false
    
    # Return nothing if we shouldn't show this node
    return "" if not authorized?(authorization)
    
    # Check to see if we are selected
    is_selected = self.selected(current_uri)
    # Add selection class if we are selected
    item_classes.push(is_selected ? :selected : nil).compact!
    # Add options to list item
    li_hash = item_classes.empty? ? {} : {:class => item_classes}
    
    init_haml_helpers
    return capture_haml do
      haml_tag(:li, li_hash) do
        # If there is a submenu and (we want to render submenus || we are selected)
        if self.is_submenu? && (render_submenus ? true : self.selected)
          haml_concat(self.submenu.render(current_uri, options))
        else
          if @path.eql?("/users/sign_out")
            haml_tag(:a, I18n.t(self.translation_key), {"data-method" => :delete, :href => @path})
          else
            haml_tag(:a, I18n.t(self.translation_key), {:href => @path})
          end
        end
      end
    end
    
  end
  
  def is_submenu?
    !(self.submenu.nil?)
  end
  
  def translation_key
    "menu.#{self.menu.name.underscore}.#{@title}"
  end

end
  
