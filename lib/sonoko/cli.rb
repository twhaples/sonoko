# frozen_string_literal: true
require 'thor'

module Sonoko
  class CLI < Thor
    desc 'analyze', 'Analyzes tests and builds a database'
    def analyze(*argv_args)
      require 'bundler/setup'
      require 'rspec'
      require 'rspec/core/runner'
      require 'sonoko'

      Sonoko::Formatter.register
      Sonoko::Config.tracer.new_db!

      args = ['-f', 'Sonoko::Formatter', *argv_args]

      RSpec::Core::Runner.run(args)
    end

    desc 'dump', 'Ugly dump of all the rows'
    def dump
      require 'sonoko'
      require 'json'

      Sonoko::Config.tracer.db.query("select * from tests") do |rows|
        rows.each do |row|
          puts JSON[row]
        end
      end
    end

    desc 'relevant', 'Identifies the tests relevant to a list of classes / methods'
    def relevant
      require 'sonoko'
      require 'sonoko/relevant'
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
  end
end