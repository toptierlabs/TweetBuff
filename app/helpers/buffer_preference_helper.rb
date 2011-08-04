module BufferPreferenceHelper

  def tweet_mode_selected(comp, mode)
    mode.to_s.include?(comp.to_s) ? "ui-selected" : ""
  end

end