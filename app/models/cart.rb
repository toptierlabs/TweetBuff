class Cart < ActiveRecord::Base
  has_many :line_items, :dependent => :destroy

  def paypal_url(return_url, notify_url)
    values = {
      :business => 'seller_1317095351_biz@41studio.com',
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :invoice => id,
      :notify_url => notify_url
    }
    line_items.each_with_index do |item, index|
      values.merge!({
        "amount_#{index+1}" => item.plan.price,
        "item_name_#{index+1}" => item.plan.name,
        "item_number_#{index+1}" => item.id,
        "quantity_#{index+1}" => item.qty
      })
    end
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end

end
