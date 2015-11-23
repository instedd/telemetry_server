source 'https://rubygems.org'


gem 'rails', '4.2.5'
gem 'pg'
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem 'coffee-rails', '~> 4.1.0'
gem 'jquery-rails'
gem 'turbolinks'
gem 'jbuilder', '~> 2.0'
gem 'sdoc', '~> 0.4.0', group: :doc
gem 'haml-rails', '~> 0.9'
gem 'rest-client'
gem 'elasticsearch'
gem 'geoip'
gem 'puma'
gem 'devise'
gem 'bootstrap-sass'
gem 'listings'
gem 'sinatra', :require => nil

group :development, :test do
  gem 'pry-byebug' unless ENV["TRAVIS"]
  gem 'rspec-rails', '~> 3.0'
  gem 'factory_girl_rails'
end

group :development do
  gem 'web-console', '~> 2.0'
  gem 'spring'
end

group :production do
  gem 'sidekiq', '~> 3.5.0'
end

group :test do
  gem 'shoulda-matchers'
  gem 'faker'
  gem 'webmock'
  gem 'timecop'
end
