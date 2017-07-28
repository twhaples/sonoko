# frozen_string_literal: true

require 'sqlite3'

module Sonoko
  class Tracer
    class Base
      def self.build(
            ignored_classes: ['RSpec', 'Sonoko'],
            repo_root: Config.repo_root
          )

        ignored = ignored_classes.map do |c|
          "\Q#{c}\E(?:::|$)"
        end.join('|')
        ignore_regex = /^(?:#{ignored}|#<)/

        new(ignore_regex: ignore_regex, repo_root: repo_root)
      end
      def initialize(repo_root:, ignore_regex:)
        @repo_root = repo_root
        @ignore_regex = ignore_regex
        reset
      end

      def reset
        @current_events = []
      end

      def install
        repo_root = @repo_root
        base_regex = /^#{repo_root}/
        ignore_regex = @ignore_regex

        trace = proc do |event, file, _line, id, _binding, classname|
          if event == 'call' &&
             classname.to_s !~ ignore_regex &&
             file =~ base_regex
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
