# frozen_string_literal: true

require 'sonoko/tracer'
require 'sonoko/db'

module Sonoko
  module Config
    class << self
      attr_reader :repo_root, :tracer, :db

      def setup(repo_root: default_repo_root)
        @db = Sonoko::DB.new(repo_root)
        @tracer = Sonoko::Tracer::Sqlite.new
      end

      def default_repo_root
        @repo_root ||= Pathname.new(
          File.join(File.dirname($PROGRAM_NAME), '..')
        ).realpath
      end
    end
  end
end
