class AddNameToJobqueues < ActiveRecord::Migration[5.0]
  def change
    add_column :jobqueues, :name, :string, null: true
    add_index :jobqueues, :name

    # Populate queue name with queue arn logical name
    Jobqueue.find_each do |jq|
      jobqueue_name = jq.arn.split(':').last
      jq.name = jobqueue_name
      jq.save
    end
  end
end
