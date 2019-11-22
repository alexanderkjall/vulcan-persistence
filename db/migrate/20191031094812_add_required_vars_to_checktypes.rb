class AddRequiredVarsToChecktypes < ActiveRecord::Migration[5.0]
  def change
    add_column :checktypes, :required_vars, :text, array:true, default: []
  end
end
