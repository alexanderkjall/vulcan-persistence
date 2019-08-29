class AddAssetsToChecktypes < ActiveRecord::Migration[5.0]
  def change
    add_column :checktypes, :assets, :text, array:true, default: []
  end
end
