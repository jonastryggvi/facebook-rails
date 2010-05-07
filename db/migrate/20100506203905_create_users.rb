class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :facebook_uid, :null => false
      t.string :access_token
      t.string :name
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.string :link

      t.timestamps
    end
    
    add_index :users, :facebook_uid, :unique => true      
  end

  def self.down
    drop_table :users
  end
end
