class CreateRequestsRoomTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :requests_room_types do |t|
      t.references :request, null: false, foreign_key: true
      t.references :room_type, null: false, foreign_key: true
      t.integer :quantity

      t.timestamps
    end
  end
end
