# == Schema Information
#
# Table name: addresses
#
#  id             :bigint           not null, primary key
#  address_1      :string
#  address_2      :string
#  city           :string
#  country        :string
#  post_code      :integer
#  state          :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  transaction_id :bigint
#
# Indexes
#
#  index_addresses_on_transaction_id  (transaction_id)
#
# Foreign Keys
#
#  fk_rails_...  (transaction_id => transactions.id)
#

class Address < ApplicationRecord
  belongs_to :listing_transaction, class_name: "Transaction", foreign_key: "transaction_id"
end
