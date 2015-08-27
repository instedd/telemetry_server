class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.references :installation, index: true, foreign_key: true
      t.text :data

      t.timestamps null: false
    end
  end
end
