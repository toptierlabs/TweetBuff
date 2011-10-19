module PlansHelper
  def format_price_monthly(price)
    number_to_currency(price)
  end
  
  def format_price_years(price)
    price_year = price * 12
    diskon = (price_year * 15).to_f / 100.to_f
    sum = (price_year - diskon ).to_f / 12.to_f
    
    number_to_currency(sum.round(2))
  end  
end