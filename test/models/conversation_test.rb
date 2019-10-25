# == Schema Information
#
# Table name: conversations
#
#  id                  :bigint           not null, primary key
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  employee_listing_id :integer
#  receiver_id         :integer
#  sender_id           :integer
#
# Indexes
#
#  index_conversations_on_receiver_id_and_sender_id  (receiver_id,sender_id) UNIQUE
#

require 'test_helper'

class ConversationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
