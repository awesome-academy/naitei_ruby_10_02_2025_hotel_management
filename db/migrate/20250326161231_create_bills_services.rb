class CreateBillsServices < ActiveRecord::Migration[7.0]
  def change
    create_table :bills_services do |t|
      t.references :bill, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.integer :quanity

      t.timestamps
    end
  end
end
