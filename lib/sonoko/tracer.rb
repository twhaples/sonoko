# frozen_string_literal: true

require 'sqlite3'

module Sonoko
  class Tracer
    class Base
      def initialize
        reset
      end

      def reset
        @current_events = []
      end

      def install
        repo_root = Config.repo_root
        base_regex = /^#{repo_root}/
        ignore_regex = /^(?:RSpec::|#<)/

        trace = proc do |event, file, _line, id, _binding, classname|
          if event == 'call' &&
             file =~ base_regex &&
             classname.to_s !~ ignore_regex
            current_events << [classname, id]
          end
        end

        set_trace_func(trace)
      end

      def uninstall
        set_trace_func(nil)
      end

      private

      attr_accessor :current_events
    end

    class Json < Base
      attr_reader :event_examples
      def initialize
        super
        @event_examples = {}
      end

      def record(location)
        current_events.each do |classname, id|
          event = "#{classname}##{id}"
          event_examples[event] ||= []
          event_examples[event] << location
        end
      end
    end

    class Sqlite < Base
      def initialize
        super
        @db_path = File.join(Sonoko::Config.repo_root, 'tests.db')
      end

      def db
        Sonoko::Config.db
      end

      def record(location)
        current_events.each do |classname, method|
          db.insert(classname.to_s, method.to_s, location)
        end
      end
    end
  end
end
