class AddDeletedAtToRoomTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :room_types, :deleted_at, :datetime
    add_index :room_types, :deleted_at
  end
end
