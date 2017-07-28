# frozen_string_literal: true

module Sonoko
  class DB
    def initialize(path)
      @path = path
    end

    def handle
      ensure_created!
      @handle ||= SQLite3::Database.new(@path)
    end

    def destroy!
      File.unlink @path if File.exist?(@path)
    end

    def ensure_created!
      handle.execute <<-SQL
          create table tests (
            classname varchar,
            method varchar,
            location varchar
          );
        SQL
      handle.execute <<-SQL
          create index test_lookup on tests (classname, method);
          create unique_index no_dupes on tests (classname, method, location);
        SQL
    end

    def insert(classname, method, location)
      handle.execute(
        'insert into tests (classname, method, location) values (?, ?, ?);',
        [classname.to_s, method.to_s, location]
      )
    rescue => e
      # this typically happens in rspec-land so it's obnoxiously silent
      STDERR.puts e.inspect
      raise e
    end
  end
end
