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

require 'test_helper'

class AddressTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
