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
      return if File.exist?(@path)
      create_handle = SQLite3::Database.new(@path)
      create_handle.execute <<-SQL
        create table tests (
          classname varchar,
          method varchar,
          location varchar
        );
      SQL

      create_handle.execute <<-SQL
          create index test_lookup on tests (classname, method);
      SQL
      create_handle.execute <<-SQL
          create unique index no_dupes on tests (classname, method, location);
      SQL
    end

    def insert(classname, method, location)
      handle.execute(<<-SQL, [classname.to_s, method.to_s, location])
        insert or replace into tests (classname, method, location)
         values (?, ?, ?);
      SQL
    rescue => e
      # this typically happens in rspec-land so it's obnoxiously silent
      STDERR.puts e.inspect
      raise e
    end
  end
end
