class AddQueueNameToChecktypes < ActiveRecord::Migration[5.0]
  def change
    add_column :checktypes, :queue_name, :string, null: true
  end
end
