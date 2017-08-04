# frozen_string_literal: true

require 'sonoko/tracer'

module Sonoko
  module Config
    class << self
      attr_reader :repo_root, :tracer, :db, :verbose

      def setup(repo_root:,
                db_path:,
                verbose: true,
                keepalive: nil)
        require 'sonoko/db'
        @db = Sonoko::DB.new(db_path)
        @tracer = Sonoko::Tracer::Sqlite.build(keepalive: keepalive)
        @verbose = verbose
        @repo_root = Pathname.new(repo_root).realpath.to_s
      end
    end
  end
end
