$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'rspec'
require 'buffered_job'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

ENV['RAILS_ENV'] = 'test'

RSpec.configure do |config|
end


config = YAML.load(File.read('spec/database.yml'))
ActiveRecord::Base.establish_connection config['sqlite']
ActiveRecord::Base.logger = Delayed::Worker.logger
ActiveRecord::Migration.verbose = false

ActiveRecord::Schema.define do
  create_table :buffered_jobs do |t|
    t.integer :user_id
    t.string :category
    t.string :receiver
    t.string :method
    t.string :merge_method
    t.string :target
    t.timestamps
  end

  create_table :delayed_jobs do |table|
    table.integer  :priority, :default => 0
    table.integer  :attempts, :default => 0
    table.text     :handler
    table.text     :last_error
    table.datetime :run_at
    table.datetime :locked_at
    table.datetime :failed_at
    table.string   :locked_by
    table.string   :queue
    table.timestamps
  end
  add_index :delayed_jobs, [:priority, :run_at], :name => 'delayed_jobs_priority'

end


