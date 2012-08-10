class CreateTwits < ActiveRecord::Migration
  def change
    create_table :twits do |t|
      t.string :status, :null => false, :limit => 140
      t.references :user
      t.timestamps
    end
  end
end
