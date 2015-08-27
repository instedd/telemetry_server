class CreateInstallations < ActiveRecord::Migration
  def change
    create_table :installations do |t|
      t.string :uuid
      t.datetime :last_reported_at
      t.string :ip
      t.decimal :latitude, precision: 9, scale: 6
      t.decimal :longitude, precision: 9, scale: 6
      t.string :admin_email
      t.string :application

      t.timestamps null: false
    end
  end
end
