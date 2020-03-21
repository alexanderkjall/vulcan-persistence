class CreateAgents < ActiveRecord::Migration[5.0]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  def change
    create_table :agents, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.belongs_to :jobqueue, type: :uuid, index: true, foreign_key: true
      t.string :status, null: false, default: 'NEW'
      t.string :version, null: false, default: '0.1'
      t.boolean :enabled, null: false, default: true
      t.datetime :heartbeat_at
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
