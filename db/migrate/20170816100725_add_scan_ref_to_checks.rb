class AddScanRefToChecks < ActiveRecord::Migration[5.0]
  def change
    add_reference :checks, :scan, foreign_key: true, index: true
    add_index :checks, :status
  end
end
