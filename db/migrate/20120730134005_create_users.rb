class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username, :null => false
      t.string :google_id, :null => false
      t.string :google_email, :null => false
      t.string :google_name, :null => false
      t.string :google_pic, :null => false
      t.timestamps
    end
  end
end
