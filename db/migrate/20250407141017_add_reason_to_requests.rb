class AddReasonToRequests < ActiveRecord::Migration[7.0]
  def change
    add_column :requests, :reason, :text, null: true
  end
end
