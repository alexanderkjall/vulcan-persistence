# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20191104094812) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pgcrypto"

  create_table "agents", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "jobqueue_id"
    t.string   "status",       default: "NEW", null: false
    t.string   "version",      default: "0.1", null: false
    t.boolean  "enabled",      default: true,  null: false
    t.datetime "heartbeat_at"
    t.datetime "deleted_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["jobqueue_id"], name: "index_agents_on_jobqueue_id", using: :btree
  end

  create_table "checks", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid     "agent_id"
    t.uuid     "checktype_id"
    t.string   "status",        default: "CREATED", null: false
    t.string   "target",                            null: false
    t.text     "options"
    t.string   "webhook"
    t.float    "score",         default: 0.0
    t.float    "progress",      default: 0.0
    t.text     "raw"
    t.text     "report"
    t.datetime "deleted_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.uuid     "scan_id"
    t.string   "queue_name"
    t.string   "tag"
    t.text     "required_vars", default: [],                     array: true
    t.index ["agent_id"], name: "index_checks_on_agent_id", using: :btree
    t.index ["checktype_id"], name: "index_checks_on_checktype_id", using: :btree
    t.index ["scan_id"], name: "index_checks_on_scan_id", using: :btree
    t.index ["status"], name: "index_checks_on_status", using: :btree
  end

  create_table "checktypes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string   "name",                         null: false
    t.text     "description"
    t.integer  "timeout",       default: 600,  null: false
    t.boolean  "enabled",       default: true, null: false
    t.text     "options"
    t.text     "image",                        null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.text     "assets",        default: [],                array: true
    t.string   "queue_name"
    t.text     "required_vars", default: [],                array: true
  end

  create_table "jobqueues", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string   "arn",                         null: false
    t.text     "description"
    t.datetime "deleted_at"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.boolean  "default",     default: false, null: false
    t.string   "name",                        null: false
    t.index ["name"], name: "index_jobqueues_on_name", using: :btree
  end

  create_table "scans", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer  "size",       default: 0,     null: false
    t.datetime "deleted_at"
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.boolean  "aborted",    default: false, null: false
    t.datetime "aborted_at"
  end

  add_foreign_key "agents", "jobqueues"
  add_foreign_key "checks", "agents"
  add_foreign_key "checks", "checktypes"
  add_foreign_key "checks", "scans"

  create_view "assettypes",  sql_definition: <<-SQL
      SELECT tmp.asset AS assettype,
      array_agg(tmp.name) AS name
     FROM ( SELECT unnest((t.assets || (ARRAY[NULL::text])[1:((array_upper(t.assets, 1) IS NULL))::integer])) AS asset,
              t.name
             FROM checktypes t
            WHERE (NOT (EXISTS ( SELECT c.id,
                      c.name,
                      c.description,
                      c.timeout,
                      c.enabled,
                      c.options,
                      c.image,
                      c.deleted_at,
                      c.created_at,
                      c.updated_at,
                      c.assets
                     FROM checktypes c
                    WHERE ((c.created_at > t.created_at) AND ((t.name)::text = (c.name)::text)))))) tmp
    GROUP BY tmp.asset;
  SQL

end
