module DashboardHelper
  def kibana_url
    host = ENV['KIBANA_HOST'] || 'localhost:5601'

    "http://#{host}/#/dashboard?_g=(time:(from:now-6M,mode:quick,to:now))"
  end
end
