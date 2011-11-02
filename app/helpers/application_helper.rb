module ApplicationHelper
  def get_time_from_now(time,unit,last_tweet,count)
    time = time.to_i * count
    if unit.eql?("minutes")
      time = last_tweet + time.minutes #time.minutes.from_now
    elsif unit.eql?("hours")
      time = last_tweet + time.hours
    end
    time.strftime("%I:%M %p")
  end

  def hour_select(field_name, selected = nil)
    select_tag(field_name,options_for_select([
          ["1", "01"],["2", "02"],["3", "03"],["4 ", "04"],["5 ", "05"],["6 ", "06"],
          ["7", "07"],["8", "08"],["9 ", "09"],["10 ", "10"],["11 ", "11"],["12", "12"]],{:selected => selected}))
  end

  def minute_select(field_name, selected = nil)
    select_tag(field_name,options_for_select([
          ["00", "00"],["01", "01"],["02", "02"],["03", "03"],["04", "04"],["05", "05"],["06", "06"],["07", "07"],["08", "08"],["09", "09"],["10", "10"],
          ["11", "11"],["12", "12"],["13", "13"],["14", "14"],["15", "15"],["16", "16"],["17", "17"],["18", "18"],["19", "19"],["20", "20"],
          ["21", "21"],["22", "22"],["23", "23"],["24", "24"],["25", "25"],["26", "26"],["27", "27"],["28", "28"],["29", "29"],["30", "30"],
          ["31", "31"],["32", "32"],["33", "33"],["34", "34"],["35", "35"],["36", "36"],["37", "37"],["38", "38"],["39", "39"],["40", "40"],
          ["41", "41"],["42", "42"],["43", "43"],["44", "44"],["45", "45"],["46", "46"],["47", "47"],["48", "48"],["49", "49"],["50", "50"],
          ["51", "51"],["52", "52"],["53", "53"],["54", "54"],["55", "55"],["56", "56"],["57", "57"],["58", "58"],["59", "59"],["60", "60"]],{:selected => selected}))
  end

  def meridian(field_name, selected = nil)
    select_tag(field_name, options_for_select([["AM","am"],["PM","pm"]]))
  end

  def timezone_select(field_name, selected = nil)
    select_tag(field_name,time_zone_options_for_select(selected))
  end

  def custom_check_box(user)
    if user.notify
      return check_box("account","notify", :checked => "checked")
    else
      return check_box("account","notify")
    end
  end

  def time_in_word(added_time,run_at)
    tommorow = Time.now + 1.day
    yesterday = Time.now - 1.day
    case run_at
    when 0
      "<span style='color: #fff; font-weight: bold;'>Today</span> <span style='color: #fff; font-weight: bold;'>#{Time.now.strftime('%b %d')}</span>".html_safe
    when 1
      "<span style='color: #fff; font-weight: bold;'>Tommorow</span> <span style='color: #fff; font-weight: bold;'>#{tommorow.strftime('%b %d')}</span>".html_safe
    else
      "<span style='color: #fff; font-weight: bold;'>Today #{run_at.strftime("%b %d")}</span>".html_safe
    end
  end

  def pack_buffer(m, flag)
    #    strret = ""
    #    strret << "<div style='border: 1px solid #000;' id='buffer_list_container_#{flag}'>" if flag != buffer.added_time
    #    strret << "#{buffer.name} <br /><span style='color: #7BC2EE; font-style: italic; font-size: 13px;'>Queued for #{buffer.run_at.strftime('%H:%M %p')}</span> #{flag == buffer.added_time ? "</div>" : ''}"
    #    strret.html_safe
    data = ""
    old_flag = flag.added_time
    m.each_with_index do |buffer,index|
      if old_flag == buffer.added_time
        data = "<div style='padding-top: 7px;'>#{buffer.name} <br /> <span style='color: #7BC2EE; font-style: italic; font-size: 13px;'>Queued for #{buffer.run_at.strftime('%H:%M %p')}</span></div>"
      end
    end
    return data.html_safe
  end

  def other_tf_interval(timeframe)
    ret = "currently your tweet will post automaticly every "
    ret << timeframe.join(",")
  end
 
  def show_buffer_date_title(buffer, active_time = Date.today)
    if buffer.run_at.to_date < active_time
      case (active_time - buffer.run_at.to_date).to_i
      when 1 
        "Yesterday (#{buffer.run_at.strftime('%b %d')})"
      else
        buffer.run_at.strftime('%b %d')
      end
    elsif buffer.run_at.to_date == active_time
      "Today (#{Time.now.strftime('%b %d')})"
    elsif buffer.run_at.to_date > active_time
      case (buffer.run_at.to_date - active_time).to_i
      when 1
        "Tomorrow (#{buffer.run_at.strftime('%b %d')})"
      else
        buffer.run_at.strftime('%b %d')    
      end
    end
  end

  def is_day_of_week_checked?(twitter_user, number_of_day)
    time_setting = twitter_user.time_setting
    return true if time_setting.blank?
    time_setting.day_of_week.split(",").include?(number_of_day.to_s)    
  end
  
end