class AddOptedOutToInstallations < ActiveRecord::Migration
  def change
    add_column :installations, :opt_out, :boolean, default: false
  end
end
