class AddAbortedAtToScans < ActiveRecord::Migration[5.0]
  def change
    add_column :scans, :aborted_at, :datetime  end
end
