class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :usename
      t.string :email
      t.string :phone
      t.string :password_digest
      t.boolean :admin
      t.boolean :activated

      t.timestamps
    end
  end
end
