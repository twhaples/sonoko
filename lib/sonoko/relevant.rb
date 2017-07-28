module Sonoko
  class Relevant
    def self.compute(changed_methods)
      invocations = Set.new
      changed_methods.each do |change|
        Sonoko::Config.tracer.db.query(
          "select location from tests where classname = ? and method = ?",
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
