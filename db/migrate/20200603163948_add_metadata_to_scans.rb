class AddMetadataToScans < ActiveRecord::Migration[5.0]
  def change
    add_column :scans, :tag,     :string, null: true
    add_column :scans, :program, :string, null: true
  end
end
