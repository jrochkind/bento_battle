# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120912211133) do

  create_table "errors", :force => true do |t|
    t.string   "engine"
    t.text     "backtrace"
    t.text     "error_info"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "query"
  end

  create_table "selections", :force => true do |t|
    t.string   "option_a"
    t.string   "option_b"
    t.string   "choice"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "query"
    t.string   "demographic_school"
    t.string   "demographic_status"
  end

  create_table "timings", :force => true do |t|
    t.string   "engine"
    t.integer  "miliseconds"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

end
