class AddLastErroredAtToInstallations < ActiveRecord::Migration
  def change
    add_column :installations, :last_errored_at, :datetime
  end
end
