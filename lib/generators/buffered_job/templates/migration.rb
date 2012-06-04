

class CreateBufferedJob < ActiveRecord::Migration
  def change
    create_table :buffered_jobs do |t|
      t.integer :user_id
      t.string :category
      t.string :receiver
      t.string :method
      t.string :merge_method
      t.string :target
      t.timestamps
    end
  end
end
