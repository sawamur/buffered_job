require 'rails/generators'
require 'rails/generators/migration'


class BufferedJobGenerator < Rails::Generators::Base
  desc "This generator creates migration file for buffered_job"
  include Rails::Generators::Migration

  self.source_paths << File.join(File.dirname(__FILE__), 'templates')

  def self.next_migration_number(path)
    Time.now.utc.strftime("%Y%m%d%H%M%S")
  end

  def create_migrateion
    migration_template 'migration.rb', 'db/migrate/create_buffered_job.rb'
  end
end
