class CreateThings < ActiveRecord::Migration
  def self.up
   create_table :things do |t|
      t.string :name, :lala
    end
  end

  def self.down
    drop_table :things
  end
end
