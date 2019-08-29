class AddAbortedToScans < ActiveRecord::Migration[5.0]
  def change
    add_column :scans, :aborted, :boolean, null: false, default: false
  end
end
