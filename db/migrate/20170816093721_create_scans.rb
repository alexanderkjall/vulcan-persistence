class CreateScans < ActiveRecord::Migration[5.0]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  def change
    create_table :scans, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.integer :size, null: false, default: 0
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
