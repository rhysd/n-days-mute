class CreateMutes < ActiveRecord::Migration[5.1]
  def change
    create_table :mutes do |t|
      t.string :user_id, null: false
      t.string :screen_name, null: false
      t.string :muted_by_user_id, null: false
      t.integer :days, null: false
      t.timestamps
    end
  end
end
