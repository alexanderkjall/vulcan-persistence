class CreateChecks < ActiveRecord::Migration[5.0]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  def change
    create_table :checks, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.belongs_to :agent, index: true, foreign_key: true
      t.belongs_to :checktype, index: true, foreign_key: true
      t.string :status, null: false, default: 'CREATED'
      t.string :target, null: false
      t.text :options
      t.string :webhook
      t.float :score
      t.float :progress
      t.text :raw
      t.text :report
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
