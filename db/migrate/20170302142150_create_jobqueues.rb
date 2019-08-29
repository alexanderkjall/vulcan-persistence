class CreateJobqueues < ActiveRecord::Migration[5.0]
  enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')
  def change
    create_table :jobqueues, id: :uuid, default: 'gen_random_uuid()' do |t|
      t.string :arn, null: false
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
