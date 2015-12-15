class KibanaProxy < Rack::Proxy
  def rewrite_env(env)
    env['HTTP_HOST'] = ENV['KIBANA_HOST'] || "localhost"
    env['SERVER_PORT'] = ENV['KIBANA_PORT'].try(:to_i) || 5601
    env['SCRIPT_NAME'] = nil
    env['CONTENT_TYPE'] = env['KIBANA_CONTENT_TYPE']
    env
  end
end
