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
    option :examples, type: :string, default: 'spec/'
    def analyze(*argv_args)
      require 'bundler/setup'
      require 'rspec'
      require 'rspec/core/runner'
      require 'sonoko'

      setup_db!
      Sonoko::Formatter.register

      argv_args = ['spec/'] if argv_args.empty?
      default_args = ['-f', 'Sonoko::Formatter']
      args = [*default_args, *argv_args]

      RSpec::Core::Runner.run(args)
    end

    desc 'reset', 'Reset the database'
    def reset
      setup_db!
      Sonoko::Config.db.destroy!
    end

    desc 'dump', 'Ugly dump of all the rows'
    def dump
      require 'sonoko'
      require 'json'

      setup_db!

      Sonoko::Config.db.handle.query('select * from tests') do |rows|
        rows.each do |row|
          puts JSON[row]
        end
      end
    end

    desc 'relevant',
         'Identifies the tests relevant to a list of classes / methods'
    def relevant
      require 'sonoko'
      require 'sonoko/relevant'

      setup_db!
      changed = []
      STDIN.each_line do |line|
        match = line.match(/^(\S+)(?:\s+|#|\.)(\S+)$/)
        raise ArgumentError, "Could not understand #{line}" unless match
        classname = match[1]
        method = match[2]
        changed << [classname, method]
      end

      Sonoko::Relevant.compute(changed).each do |location|
        puts location
      end
    end

    no_tasks do
      def setup_db!
        Sonoko::Config.setup(
          db_path: options[:db_path],
          repo_root: options[:repo],
          verbose: options[:verbose]
        )
        Sonoko::Config.db.ensure_created!
      end
    end
  end
end
