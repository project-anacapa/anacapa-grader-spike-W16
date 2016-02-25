class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.integer :uid
      t.string :token
      t.boolean :site_admin

      t.timestamps null: false
    end
  end
end
