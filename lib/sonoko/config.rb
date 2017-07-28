# frozen_string_literal: true
require "sonoko/tracer"

module Sonoko
  module Config
    class << self
      attr_writer :repo_root, :tracer

      def repo_root
        @repo_root ||= Pathname.new(
          File.join(File.dirname($PROGRAM_NAME), '..')
        ).realpath
      end

      def tracer
        @tracer ||= Sonoko::Tracer::Sqlite.new
      end
    end
  end
end
