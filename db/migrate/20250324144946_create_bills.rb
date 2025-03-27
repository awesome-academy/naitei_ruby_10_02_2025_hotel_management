class CreateBills < ActiveRecord::Migration[7.0]
  def change
    create_table :bills do |t|
      t.date :pay_at
      t.float :total
      t.references :request, null: false, foreign_key: true, unique: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
