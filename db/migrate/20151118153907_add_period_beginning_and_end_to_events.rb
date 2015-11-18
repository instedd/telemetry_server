class AddPeriodBeginningAndEndToEvents < ActiveRecord::Migration
  def change
    add_column :events, :period_beginning, :datetime
    add_column :events, :period_end, :datetime
  end
end
