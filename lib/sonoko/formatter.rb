# frozen_string_literal: true

module Sonoko
  class Formatter
    attr_reader :tracer
    def initialize(_iostream)
      @tracer = Tracer.instance
      tracer.install
    end

    def example_started(_event)
      tracer.reset
    end

    def example_passed(event)
      finish(event)
    end

    def example_failed(event)
      finish(event)
    end

    def finish(event)
      location = event.example.location
      tracer.record(location)
    end

    RSpec::Core::Formatters.register(
      self,
      :example_started,
      :example_passed,
      :example_failed,
    )
  end
end