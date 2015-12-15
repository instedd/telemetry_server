module DashboardHelper
  def kibana_path
    "/kibana#/dashboard?_g=(time:(from:now-6M,mode:quick,to:now))"
  end
end
