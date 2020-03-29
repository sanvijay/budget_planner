source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.6.3'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 6.0.2', '>= 6.0.2.1'
# Use Puma as the app server
gem 'puma', '~> 4.1'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.7'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# Use Active Model has_secure_password
# gem 'bcrypt', '~> 3.1.7'
gem 'devise'
gem 'devise-jwt', '~> 0.5.9'

# MongoDB
gem 'bson_ext'
gem 'mongoid'
gem 'mongoid_paranoia'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '>= 1.4.2', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
gem 'rack-cors'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug',        platforms: [:mri, :mingw, :x64_mingw]

  # Precommits
  gem 'brakeman'
  gem 'bundler-audit'
  gem 'database_cleaner'
  gem 'rspec-rails'
  gem 'rubocop',       require: false
  gem 'rubocop-rspec', require: false
  gem 'simplecov',     require: false
end

group :development do
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'capistrano',            '3.5'
  gem 'capistrano-bundler',    '~> 1.1.4'
  gem 'capistrano-rails',      '~> 1.1'
  gem 'capistrano-rvm',        '~> 0.1'
  gem 'capistrano3-puma'
end

group :production do
  gem 'rails_12factor' # For heroku
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw, :jruby]
