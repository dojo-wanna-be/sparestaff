# == Schema Information
#
# Table name: cancellation_policies
#
#  id                        :bigint           not null, primary key
#  after_cancellation_hours  :integer          default(0)
#  before_cancellation_hours :integer          default(0)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#

require 'test_helper'

class CancellationPolicyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
