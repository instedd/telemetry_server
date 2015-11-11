module ApplicationHelper
  def format_error(error)
    error.gsub("\n", "<br/>").gsub("\t", "<span style='margin-left:10px;'></span>").html_safe
  end
end
