# == Schema Information
#
# Table name: stripe_infos
#
#  id                 :bigint           not null, primary key
#  card_type          :string
#  last_four_digits   :string
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  stripe_account_id  :string
#  stripe_customer_id :string
#  user_id            :bigint
#
# Indexes
#
#  index_stripe_infos_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

require 'test_helper'

class StripeInfoTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
