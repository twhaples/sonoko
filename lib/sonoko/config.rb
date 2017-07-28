# frozen_string_literal: true
require "sonoko/tracer"

module Sonoko
  module Config
    class << self
      attr_accessor :repo_root

      def tracer
        @tracer ||= Sonoko::Tracer::Json.new
      end
    end
  end
end
