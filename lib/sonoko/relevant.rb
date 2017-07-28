# frozen_string_literal: true

module Sonoko
  class Relevant
    def self.compute(changed_methods)
      invocations = Set.new
      dbh = Sonoko::Config.db.handle
      changed_methods.each do |change|
        dbh.query(
          'select location from tests where classname = ? and method = ?',
          change
        ) do |results|
          results.each do |location|
            invocations.add(location)
          end
        end
      end
      invocations
    end
  end
end
