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

ActiveRecord::Schema.define(version: 2020_03_23_104633) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.integer "post_code"
    t.bigint "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transaction_id"], name: "index_addresses_on_transaction_id"
  end

  create_table "bookings", force: :cascade do |t|
    t.integer "day"
    t.time "start_time"
    t.time "end_time"
    t.bigint "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "booking_date"
    t.index ["transaction_id"], name: "index_bookings_on_transaction_id"
  end

  create_table "cancellation_policies", force: :cascade do |t|
    t.integer "pending_state_cancellation_hours", default: 0
    t.integer "accepted_state_cancellation_hours", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "classifications", force: :cascade do |t|
    t.integer "parent_classification_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.string "acn"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.integer "post_code"
    t.string "contact_no"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "conversations", force: :cascade do |t|
    t.integer "receiver_id"
    t.integer "sender_id"
    t.integer "employee_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "transaction_id"
  end

  create_table "employee_listing_languages", force: :cascade do |t|
    t.integer "employee_listing_id"
    t.integer "language_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employee_listing_slots", force: :cascade do |t|
    t.bigint "slot_id"
    t.bigint "employee_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_listing_id"], name: "index_employee_listing_slots_on_employee_listing_id"
    t.index ["slot_id"], name: "index_employee_listing_slots_on_slot_id"
  end

  create_table "employee_listings", force: :cascade do |t|
    t.integer "classification_id"
    t.string "title"
    t.string "first_name"
    t.string "last_name"
    t.string "tfn"
    t.integer "birth_year"
    t.string "address_1"
    t.string "address_2"
    t.string "city"
    t.string "state"
    t.string "country"
    t.integer "post_code"
    t.string "residency_status"
    t.string "other_residency_status"
    t.string "verification_type"
    t.string "gender"
    t.boolean "has_vehicle", default: false
    t.text "skill_description"
    t.text "optional_comments"
    t.boolean "published", default: false
    t.integer "lister_id"
    t.string "lister_type"
    t.integer "listing_step"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "available_in_holidays", default: false
    t.decimal "weekday_price", default: "0.0"
    t.decimal "holiday_price", default: "0.0"
    t.integer "minimum_working_hours"
    t.date "start_publish_date"
    t.date "end_publish_date"
    t.decimal "weekend_price", default: "0.0"
    t.string "profile_picture_file_name"
    t.string "profile_picture_content_type"
    t.bigint "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.string "verification_front_image_file_name"
    t.string "verification_front_image_content_type"
    t.bigint "verification_front_image_file_size"
    t.datetime "verification_front_image_updated_at"
    t.string "verification_back_image_file_name"
    t.string "verification_back_image_content_type"
    t.bigint "verification_back_image_file_size"
    t.datetime "verification_back_image_updated_at"
    t.boolean "deactivated", default: false
    t.integer "deactivation_reason", default: 7
    t.text "deactivation_feedback"
    t.float "latitude"
    t.float "longitude"
  end

  create_table "employee_skills", force: :cascade do |t|
    t.string "skill_name"
    t.bigint "employee_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_listing_id"], name: "index_employee_skills_on_employee_listing_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "language"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "listing_availabilities", force: :cascade do |t|
    t.time "start_time"
    t.time "end_time"
    t.integer "day"
    t.bigint "employee_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "not_available", default: false
    t.index ["employee_listing_id"], name: "index_listing_availabilities_on_employee_listing_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.integer "sender_id"
    t.bigint "conversation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "read", default: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "notification_settings", force: :cascade do |t|
    t.bigint "user_id"
    t.json "preferences", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_settings_on_user_id"
  end

  create_table "payment_receipts", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.float "tx_price"
    t.bigint "transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["transaction_id"], name: "index_payment_receipts_on_transaction_id"
  end

  create_table "relevant_documents", force: :cascade do |t|
    t.bigint "employee_listing_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "document_file_name"
    t.string "document_content_type"
    t.bigint "document_file_size"
    t.datetime "document_updated_at"
    t.index ["employee_listing_id"], name: "index_relevant_documents_on_employee_listing_id"
  end

  create_table "slots", force: :cascade do |t|
    t.string "time_slot"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stripe_infos", force: :cascade do |t|
    t.bigint "user_id"
    t.string "stripe_customer_id"
    t.string "stripe_account_id"
    t.string "last_four_digits"
    t.string "card_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["user_id"], name: "index_stripe_infos_on_user_id"
  end

  create_table "stripe_payments", force: :cascade do |t|
    t.bigint "transaction_id"
    t.string "stripe_charge_id"
    t.float "amount", default: 0.0
    t.float "poster_service_fee", default: 0.0
    t.boolean "capture", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["transaction_id"], name: "index_stripe_payments_on_transaction_id"
  end

  create_table "tax_details", force: :cascade do |t|
    t.integer "weekly_earning"
    t.float "a"
    t.float "b"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.float "amount"
    t.bigint "employee_listing_id"
    t.boolean "status", default: true
    t.integer "state"
    t.boolean "is_withholding_tax", default: true
    t.integer "frequency"
    t.integer "hirer_id"
    t.integer "poster_id"
    t.string "customer_id"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "tax_withholding_amount"
    t.float "remaining_amount"
    t.text "reason"
    t.integer "weekday_hours"
    t.integer "weekend_hours"
    t.integer "total_weekday_hours", default: 0
    t.integer "total_weekend_hours", default: 0
    t.integer "probationary_period"
    t.integer "cancelled_by"
    t.date "cancelled_at"
    t.text "decline_reason_by_poster"
    t.float "adjustment"
    t.string "request_by"
    t.integer "old_transaction"
    t.index ["employee_listing_id"], name: "index_transactions_on_employee_listing_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name"
    t.string "last_name"
    t.integer "company_id"
    t.integer "user_type"
    t.boolean "allow_marketing_promotions", default: false
    t.string "provider"
    t.string "uid"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_admin", default: false
    t.string "avatar_file_name"
    t.string "avatar_content_type"
    t.bigint "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "transactions"
  add_foreign_key "bookings", "transactions"
  add_foreign_key "employee_listing_slots", "employee_listings"
  add_foreign_key "employee_listing_slots", "slots"
  add_foreign_key "employee_skills", "employee_listings"
  add_foreign_key "listing_availabilities", "employee_listings"
  add_foreign_key "messages", "conversations"
  add_foreign_key "payment_receipts", "transactions"
  add_foreign_key "relevant_documents", "employee_listings"
  add_foreign_key "stripe_infos", "users"
  add_foreign_key "stripe_payments", "transactions"
  add_foreign_key "transactions", "employee_listings"
end
