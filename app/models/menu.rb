class Menu
  include Haml::Helpers
  cattr_accessor  :menus
  attr_accessor   :name, :items

  # Class Methods

  # Load and process all Rails.root/**/config/menus/*.yml files
  def self.load_hash
    menu_files = Dir.glob(File.join(Rails.root,"**","menus","*.yml"))    
    Rails.logger.debug("[MENUS] Loading menu files: #{menu_files.inspect}")
    menu_hash = {}
    
    menu_files.each do |file|
      # Get the menu items provided
      new_menu_hash = Menu.load_file(file)
      # Merge menu items into hash
      menu_hash = Menu.merge_menu_hash(menu_hash, new_menu_hash)
    end
    
    menu_hash
  end
  
  # Build menu objects from a hash
  def self.build(hash = Menu.load_hash)
    @@menus = {}
    Menu.parse_menu_hash(hash)
  end

  # Retrieve a menu
  def self.get(menu_name, render_stack = [])
    menu_name = menu_name.to_s
    render_stack << menu_name
    
    # Check to see if we are in an infinite loop before we have a stack overflow
    # This is easy to do because menus must have unique names
    raise "Infinite tree traversal in menus.  Ensure a submenu does not link a parent menu!" if render_stack.uniq.size != render_stack.size
    
    if @@menus.blank?
      Rails.logger.debug("[MENUS] Menus disappeared, rebuilding")
      hash = defined?(MENU_HASH) ? MENU_HASH : Menu.load_hash
      Menu.build(hash)
    end
    
    # Grab menu from list of menus
    menu = @@menus[menu_name]
    
    # Iterate over the menu and inject submenus
    menu.items.each do |menu_item|
      submenu = menu_item.submenu
      # Skip if no submenu or submenu has already been injected
      next if submenu.nil? or submenu.is_a?(Menu)
      # Replace submenu with retrieved menu
      menu_item.submenu = Menu.get(submenu.to_s)
    end
    
    return menu
  end

  # Instance Methods
  
  def initialize(name,items = [])
    @name   = name
    @items  = []
    self.inject_items(items) if not items.blank?
  end
  
  # Render the entire menu
  def render(current_uri, options)
    init_haml_helpers
    return capture_haml do
      haml_tag(:ul, {:class => [:nav], :id => @name}) do
        @items.each do |menu_item|
          haml_concat(menu_item.render(current_uri, options))
        end
      end
    end
  end

protected 
  
  # Class Methods
  
  # Perform a reverse merge on existing menus and insertion on non-existing menus
  def self.merge_menu_hash(old_menu_hash, new_menu_hash)
    new_menu_hash.each_pair do |name, menu_items|
      menu_name = name.to_s
      if old_menu_hash.key?(menu_name)
        old_menu_hash[menu_name].reverse_merge!(menu_items)
      else
        old_menu_hash[menu_name] = menu_items
      end
    end
    
    old_menu_hash
  end  
    
  # Load a yaml file
  def self.load_file(filename)
    YAML.load_file(filename).symbolize_keys
  end
  
  # Parse a hash into menus and items
  def self.parse_menu_hash(menu_hash)
    # process the items
    menu_hash.each_pair do |k,v|
      # k is the menu name
      # v is the menu items
      menu_name = k.to_s
      
      menu_items = parse_menu_item_hash(v)
      
      # Add our items to this menu object
      if @@menus.key?(menu_name)
        menu = @@menus[menu_name].inject_items(menu_items)
      else
        menu = Menu.new(menu_name, menu_items)
      end
      
      # Store the menu object
      @@menus[menu_name] = menu
    end
  end
  
  # Parse a hash into menu items  
  def self.parse_menu_item_hash(menu_items)
    compiled_items = []
    menu_items.each_pair do |name, settings|
      compiled_items << MenuItem.new(name.to_s, settings.symbolize_keys)
    end
    compiled_items
  end
  
  # Instance Methods
  
  # Add pre-parsed menu items to our list of items
  def inject_items(menu_items)
    menu_items.each do |menu_item|
      menu_item.menu = self
      @items.push(menu_item)
    end
  end
  
end