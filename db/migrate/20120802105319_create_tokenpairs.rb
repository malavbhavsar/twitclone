class CreateTokenpairs < ActiveRecord::Migration
  def change
    create_table :tokenpairs do |t|
      t.string :refresh_token
      t.string :access_token
      t.integer :expires_in
      t.integer :issued_at
      t.timestamps
    end
  end
end
