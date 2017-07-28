# frozen_string_literal: true

module Sonoko
  class Tracer
    attr_accessor :current_events, :event_examples

    def self.instance
      @instance ||= new
    end

    def initialize
      reset
    end

    def reset
      @current_events = []
      @event_examples = {}
    end
    def install
      repo_root = Config.repo_root
      base_regex = /^#{repo_root}/
      rspec_regex = /^RSpec::/

      trace = proc do |event, file, _line, id, _binding, classname|
        if event == "call" &&
            file =~ base_regex &&
            classname.to_s !~ rspec_regex
          current_events << "#{classname}##{id}"
        end
      end

      set_trace_func(trace)
    end

    def record(location)
      current_events.each do |event|
        event_examples[event] ||= []
        event_examples[event] << location
      end
    end
  end
end
