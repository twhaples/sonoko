# frozen_string_literal: true

require 'sonoko/tracer'

module Sonoko
  module Config
    class << self
      attr_reader :repo_root, :tracer, :db, :verbose

      def setup(repo_root:, db_path:, verbose: true)
        require 'sonoko/db'
        @db = Sonoko::DB.new(db_path)
        @tracer = Sonoko::Tracer::Sqlite.new
        @verbose = verbose
        @repo_root = repo_root
      end

      def default_repo_root
        Pathname.new(
          File.join(File.dirname($PROGRAM_NAME), '..')
        ).realpath.to_s
      end
    end
  end
end
