# spec_helper.rb
require 'simplecov'
SimpleCov.start do
 add_filter "helpers"
 add_filter "mailers"
 add_filter "lib/custom_failure.rb"
 add_filter "services"
 add_filter "config/environment.rb"
 add_filter "app/controllers/application_controller.rb"
end

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end
  config.shared_context_metadata_behavior = :apply_to_host_groups
end