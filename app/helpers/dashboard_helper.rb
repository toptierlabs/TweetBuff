module DashboardHelper
  def profile_image(m, state, w, h)
    image_tag m.profile_image_url.gsub(state,""), :width => w, :height => h
  end
end
