class AddDefaultValuesToChecks < ActiveRecord::Migration[5.0]
  def change
    change_column :checks, :score, :float, :default => 0
    change_column :checks, :progress, :float, :default => 0
  end
end
