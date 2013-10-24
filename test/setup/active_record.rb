require 'active_record'

ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"

module TestSetup
  module ActiveRecord
    def self.migrate
      ::ActiveRecord::Migration.suppress_messages do
        yield ::ActiveRecord::Migration
      end
    end
  end
end
