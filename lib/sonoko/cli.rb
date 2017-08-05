# frozen_string_literal: true

require 'thor'
require 'sonoko/config'

module Sonoko
  class CLI < Thor
    class_option :repo,
                 type: :string,
                 default: '.',
                 desc: 'Location of the git repository to analyze'
    class_option :db_path,
                 type: :string,
                 default: 'tests.db',
                 desc: 'Location to place SQLite test database'
    class_option :verbose,
                 type: :boolean,
                 default: false,
                 desc: 'Print more messages'

    desc 'analyze [rspec-options]', 'Analyzes tests and builds a database'
    option :keepalive,
           type: :numeric,
           desc: 'Print a . every [keepalive] calls, to prevent timeouts '\
                 'in environments like CircleCI. '\
                 '(Recommended value if used: 100000)'

    def analyze(*argv_args)
      require 'bundler/setup'
      require 'sonoko'

      require_rspec!
      Sonoko::Formatter.register
      setup_db!

      if argv_args.empty?
        argv_args = ['spec/']
      elsif argv_args.length == 1 && argv_args.first == '-'
        argv_args = []
        STDIN.each_line do |line|
          argv_args << line.chomp
        end
      end

      default_args = ['-f', 'Sonoko::Formatter']
      args = [*default_args, *argv_args]

      puts args.join(' ') if options[:verbose]
      RSpec::Core::Runner.run(args)
    end

    desc 'reset', 'Reset the database'
    def reset
      setup_db!
      Sonoko::Config.db.destroy!
    end

    desc 'dump_relevant',
         'Identifies the tests relevant to a list of methods on STDIN'
    def dump_relevant
      require_relevant!

      changed = []
      STDIN.each_line do |line|
        changed << parse_method(line)
      end

      Sonoko::Relevant.compute(changed).each do |location|
        puts location
      end
    end

    desc 'relevant [method]', 'Run tests relevant to [method]'
    method_option :"dry-run",
                  type: :boolean,
                  desc: 'Prints test names instead of running'
    def relevant(*methods)
      require_relevant!
      require_rspec!

      parsed_methods = methods.map { |m| parse_method(m) }

      invoke_rspec(
        tests: Sonoko::Relevant.compute(parsed_methods).to_a
      )
    end

    no_tasks do
      def parse_method(method)
        match = method.match(/^(\S+)(?:\s+|#|\.)(\S+)$/)
        raise ArgumentError, "Could not understand #{line}" unless match
        classname = match[1]
        method = match[2]
        [classname, method]
      end

      def require_relevant!
        require 'sonoko'
        require 'sonoko/relevant'
        setup_db!
      end

      def require_rspec!
        require 'bundler/setup'
        require 'rspec'
        require 'rspec/core/runner'
      end

      def setup_db!
        Sonoko::Config.setup(
          db_path: options[:db_path],
          repo_root: options[:repo],
          verbose: options[:verbose],
          keepalive: options[:keepalive]
        )
        Sonoko::Config.db.ensure_created!
      end

      def invoke_rspec(tests:)
        if options[:"dry-run"]
          puts tests
        else
          RSpec::Core::Runner.run(tests)
        end
      end
    end
  end
end
