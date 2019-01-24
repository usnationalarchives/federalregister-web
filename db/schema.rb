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

ActiveRecord::Schema.define(version: 20190307191045) do

  create_table "clippings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "document_number"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "folder_id"
  end

  create_table "comment_attachments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "token"
    t.string   "attachment"
    t.string   "attachment_md5"
    t.string   "salt"
    t.string   "iv"
    t.integer  "file_size"
    t.string   "content_type"
    t.string   "original_file_name"
    t.datetime "created_at",         null: false
    t.datetime "updated_at",         null: false
    t.index ["created_at"], name: "index_comment_attachments_on_created_at", using: :btree
  end

  create_table "comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.string   "document_number"
    t.string   "comment_tracking_number"
    t.datetime "created_at"
    t.boolean  "comment_publication_notification"
    t.datetime "checked_comment_publication_at"
    t.string   "salt"
    t.string   "iv"
    t.binary   "encrypted_comment_data",           limit: 65535
    t.string   "agency_name"
    t.boolean  "agency_participating"
    t.string   "comment_document_number"
    t.string   "submission_key"
    t.index ["agency_participating"], name: "index_comments_on_agency_participating", using: :btree
    t.index ["comment_publication_notification"], name: "index_comments_on_comment_publication_notification", using: :btree
    t.index ["comment_tracking_number"], name: "index_comments_on_comment_tracking_number", using: :btree
    t.index ["created_at"], name: "index_comments_on_created_at", using: :btree
    t.index ["document_number"], name: "index_comments_on_document_number", using: :btree
    t.index ["user_id"], name: "index_comments_on_user_id", using: :btree
  end

  create_table "entry_emails", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "remote_ip"
    t.integer  "num_recipients"
    t.integer  "entry_id"
    t.string   "sender_hash"
    t.string   "document_number"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
  end

  create_table "folders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "slug"
    t.integer  "creator_id"
    t.integer  "updater_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "mailing_lists", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.text     "parameters", limit: 65535
    t.string   "title"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "type"
    t.datetime "deleted_at"
    t.index ["deleted_at"], name: "index_mailing_lists_on_deleted_at", using: :btree
  end

  create_table "subscriptions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "mailing_list_id"
    t.string   "requesting_ip"
    t.string   "token"
    t.datetime "unsubscribed_at"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.datetime "last_delivered_at"
    t.integer  "delivery_count"
    t.date     "last_issue_delivered"
    t.string   "environment"
    t.integer  "user_id"
    t.integer  "comment_id"
    t.datetime "deleted_at"
    t.string   "last_documents_delivered_hash"
    t.index ["comment_id"], name: "index_subscriptions_on_comment_id", using: :btree
    t.index ["deleted_at"], name: "index_subscriptions_on_deleted_at", using: :btree
    t.index ["mailing_list_id", "deleted_at"], name: "index_subscriptions_on_mailing_list_id_and_deleted_at", using: :btree
    t.index ["mailing_list_id", "last_documents_delivered_hash"], name: "mailing_list_documents", using: :btree
  end

end
