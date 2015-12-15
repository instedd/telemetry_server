class KibanaMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    # Remove content type from the requests to Kibana
    # This avoids errors raised by Rails while parsing some ElasticSearch queries
    if env['REQUEST_PATH'].start_with?('/kibana/')
      env['KIBANA_CONTENT_TYPE'] = env['CONTENT_TYPE']
      env['CONTENT_TYPE'] = nil
    end

    @app.call(env)
  end
end

Rails.application.config.middleware.insert_before ActionDispatch::ParamsParser, KibanaMiddleware
