class AddQueueNameToChecks < ActiveRecord::Migration[5.0]
  def change
    add_column :checks, :queue_name, :string, null: true
  end
end
