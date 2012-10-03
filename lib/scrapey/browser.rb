require 'selenium-webdriver'
require 'capybara/dsl'
require 'capybara-webkit'

Capybara.run_server = false
Capybara.current_driver = :webkit

class Browser
  include Capybara::DSL
end
@browser = Browser.new