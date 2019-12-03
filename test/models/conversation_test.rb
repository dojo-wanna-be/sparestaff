# == Schema Information
#
# Table name: conversations
#
#  id                  :bigint           not null, primary key
#  read                :boolean          default(FALSE)
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  employee_listing_id :integer
#  receiver_id         :integer
#  sender_id           :integer
#
# Indexes
#
#  index_conversations_on_receiver_sender_employee_listing  (receiver_id,sender_id,employee_listing_id) UNIQUE
#

require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
