module ApplicationHelper
  def format_error(error)
    error.gsub("\n", "<br/>").gsub("\t", "<span style='margin-left:10px;'></span>").html_safe
  end

  def section(name, path, controllers = [])
    controllers = Array.wrap(controllers)
    html_class = controllers.map(&:to_s).include?(params[:controller]) ? 'active' : ''

    content_tag(:li, class: html_class) do
      link_to name, path
    end
  end
end
