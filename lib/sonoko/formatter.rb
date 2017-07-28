# frozen_string_literal: true

module Sonoko
  class Formatter
    attr_reader :tracer
    def initialize(iostream)
      @tracer = Sonoko::Config.tracer
      @iostream = iostream
      tracer.install
    end

    def example_started(_event)
      tracer.reset
      tracer.install
    end

    def example_passed(event)
      tracer.uninstall
      finish(event)
    end

    def example_failed(event)
      tracer.uninstall
      finish(event)
    end

    def finish(event)
      location = event.example.location
      @iostream.puts location if Sonoko::Config.verbose
      tracer.record(location)
    end

    def self.register
      RSpec::Core::Formatters.register(
        self,
        :example_started,
        :example_passed,
        :example_failed
      )
    end
  end
end
