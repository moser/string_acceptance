class CreateChildThings < ActiveRecord::Migration
  def self.up
    create_table :child_things do |t|
      t.string :thing_id
    end
  end

  def self.down
    drop_table :child_things
  end
end
