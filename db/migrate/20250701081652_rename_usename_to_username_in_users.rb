class RenameUsenameToUsernameInUsers < ActiveRecord::Migration[7.0]
  def change
    rename_column :users, :usename, :username
  end
end
