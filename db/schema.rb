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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151217010650) do

  create_table "authors", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_format_types", force: :cascade do |t|
    t.string   "name",       null: false
    t.boolean  "physical",   null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "book_formats", force: :cascade do |t|
    t.integer  "book_id"
    t.integer  "book_format_type_id"
    t.datetime "created_at",          null: false
    t.datetime "updated_at",          null: false
  end

  add_index "book_formats", ["book_format_type_id"], name: "index_book_formats_on_book_format_type_id"
  add_index "book_formats", ["book_id"], name: "index_book_formats_on_book_id"

  create_table "book_reviews", force: :cascade do |t|
    t.integer  "book_id"
    t.integer  "rating",     limit: 1
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "book_reviews", ["book_id"], name: "index_book_reviews_on_book_id"

  create_table "books", force: :cascade do |t|
    t.string   "title"
    t.integer  "publisher_id", null: false
    t.integer  "author_id",    null: false
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "books", ["author_id"], name: "index_books_on_author_id"
  add_index "books", ["publisher_id"], name: "index_books_on_publisher_id"

  create_table "publishers", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
