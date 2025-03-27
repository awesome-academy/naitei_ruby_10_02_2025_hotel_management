class CreateStayAts < ActiveRecord::Migration[7.0]
  def change
    create_table :stay_ats do |t|
      t.references :request, null: false, foreign_key: true
      t.references :room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
