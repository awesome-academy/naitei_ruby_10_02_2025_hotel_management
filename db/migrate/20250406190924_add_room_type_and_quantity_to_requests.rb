class AddRoomTypeAndQuantityToRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :requests, :room_type_id, :bigint
    add_column :requests, :quantity, :integer
  end
end
