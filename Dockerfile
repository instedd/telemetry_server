FROM instedd/nginx-rails:2.2

# Install gem bundle
ADD Gemfile /app/
ADD Gemfile.lock /app/
RUN bundle install --jobs 3 --deployment --without development test

# Install the application
ADD . /app

# Precompile assets
RUN bundle exec rake assets:precompile RAILS_ENV=production

# Add scripts
ADD docker/runit-web-run /etc/service/web/run
ADD docker/migrate       /app/migrate

# Add config files
ADD docker/database.yml  /app/config/database.yml
