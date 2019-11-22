class AddRequiredVarsToChecks < ActiveRecord::Migration[5.0]
  def change
    add_column :checks, :required_vars, :text, array:true, default: []
  end
end
