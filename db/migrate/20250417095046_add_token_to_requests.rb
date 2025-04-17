class AddTokenToRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :requests, :token, :string
  end
end
