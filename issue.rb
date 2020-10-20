require 'bundler/inline'

gemfile do
  source "https://rubygems.org"

  gem 'ddtrace', '~> 0.37.0'
  gem 'mongo', '~> 2.10.5'
  gem 'bson', '~> 4.4.2'
  gem 'mongoid', '7.1.2'
end

Datadog.configure do |c|
  c.use :mongo
end

Mongoid.load!('/code/mongoid.yml', :test)

Mongoid.configure do |config|
  default = config.clients[:default]

  config.clients[:secondary_preferred] = default.deep_merge(options: { read: { mode: :secondary_preferred} })
end

Mongo::Logger.logger = Logger.new(STDERR).tap do |logger|
  logger.level = Logger::DEBUG
end
Mongo::Logger.logger = Mongoid.logger


Datadog.configure(Mongoid.client(:secondary_preferred), service_name: 'mongodb-secondary')

class User
  include Mongoid::Document
end

i = 0

$stderr.puts "Starting..."

loop do
  # default client
  User.create!

  #override client
  Mongoid.override_client(:secondary_preferred)
  count = User.count
  Mongoid.override_client(nil)

  $stderr.puts count if i % 100 == 0
  i += 1
end
