class CreateChecktypes < ActiveRecord::Migration[5.0]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  def change
    create_table :checktypes, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :name, null: false
      t.text :description
      t.integer :timeout, null: false, default: 600
      t.boolean :enabled, null: false, default: true
      t.text :options
      t.text :image, null: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
