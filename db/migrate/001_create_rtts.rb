class CreateRtts < ActiveRecord::Migration[5.2]
  def change
    create_table :rtts do |t|
      t.integer :user_id, null: false
      t.integer :year, null: false
      t.integer :month, null: false
      t.float :extra_hours_acquired, default: 0, null: false
      t.float :extra_hours_used, default: 0, null: false
      t.float :extra_hours_left, default: 0, null: false
    end
    add_foreign_key :rtts, :users
  end
end
