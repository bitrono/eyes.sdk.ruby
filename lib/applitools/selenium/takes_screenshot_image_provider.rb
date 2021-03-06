module Applitools::Selenium
  # @!visibility private
  class TakesScreenshotImageProvider
    extend Forwardable
    def_delegators 'Applitools::EyesLogger', :logger, :log_handler, :log_handler=

    attr_accessor :driver, :name_enumerator

    # Initialize an Applitools::Selenium::TakesScreenshotImageProvider.
    #
    # @param [Applitools::Selenium::Driver] driver
    # @param [Hash] options The options for taking a screenshot.
    # @option options [Boolean] :debug_screenshot
    # @option options [Enumerator] :name_enumerator The name enumerator.
    def initialize(driver, options = {})
      self.driver = driver
      options = { debug_screenshot: false }.merge! options
      self.debug_screenshot = options[:debug_screenshot]
      self.name_enumerator = options[:name_enumerator]
    end

    # Takes a screenshot.
    #
    # @return [Applitools::Screenshot::Datastream] The screenshot.
    def take_screenshot
      logger.info 'Getting screenshot...'
      if debug_screenshot
        screenshot = driver.screenshot_as(:png) do |raw_screenshot|
          save_debug_screenshot(raw_screenshot)
        end
      else
        screenshot = driver.screenshot_as(:png)
      end
      logger.info 'Done getting screenshot! Creating Applitools::Screenshot...'
      Applitools::Screenshot.from_datastream screenshot
    end

    private

    attr_accessor :debug_screenshot

    def save_debug_screenshot(screenshot)
      ChunkyPNG::Image.from_string(screenshot).save(name_enumerator.next)
    end
  end
end
