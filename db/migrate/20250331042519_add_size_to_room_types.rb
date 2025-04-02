class AddSizeToRoomTypes < ActiveRecord::Migration[7.0]
  def change
    add_column :room_types, :size, :integer
  end
end
