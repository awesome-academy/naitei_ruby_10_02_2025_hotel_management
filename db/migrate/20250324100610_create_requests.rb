class CreateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :requests do |t|
      t.date :checkin_date
      t.date :checkout_date
      t.references :user, null: false, foreign_key: true
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
