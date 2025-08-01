class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :username                           
      t.string :email,              null: false, default: ""
      t.string :phone
      t.string :encrypted_password, null: false, default: ""  

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at

      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email 

      t.integer  :failed_attempts, default: 0, null: false 
      t.string   :unlock_token
      t.datetime :locked_at


      t.boolean :admin, default: false
      t.boolean :activated, default: true 

      t.timestamps
    end

    # Các index Devise khuyến nghị
    add_index :users, :email,                unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :confirmation_token,   unique: true
    add_index :users, :unlock_token,         unique: true
  end
end
