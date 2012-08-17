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

ActiveRecord::Schema.define(:version => 20120817002247) do

  create_table "follow_tables", :force => true do |t|
    t.integer  "followed_id", :null => false
    t.integer  "follower_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  create_table "tokenpairs", :force => true do |t|
    t.string   "refresh_token"
    t.string   "access_token"
    t.integer  "expires_in"
    t.integer  "issued_at"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  create_table "twits", :force => true do |t|
    t.string   "status",     :limit => 140, :null => false
    t.integer  "user_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "users", :force => true do |t|
    t.string   "google_id",    :null => false
    t.string   "google_email", :null => false
    t.string   "google_name",  :null => false
    t.string   "google_pic",   :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

end
