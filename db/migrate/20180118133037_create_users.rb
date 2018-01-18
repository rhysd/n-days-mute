class CreateUsers < ActiveRecord::Migration[5.1]
  def change
    create_table :users do |t|
      t.string :user_id, null: false
      t.string :user_name, null: false
      t.string :screen_name, null: false
      t.string :token, null: false
      t.string :secret, null: false
      t.timestamps
    end
  end
end
