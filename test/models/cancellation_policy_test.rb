# == Schema Information
#
# Table name: cancellation_policies
#
#  id                                :bigint           not null, primary key
#  accepted_state_cancellation_hours :integer          default(0)
#  pending_state_cancellation_hours  :integer          default(0)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

require 'test_helper'

class CancellationPolicyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
