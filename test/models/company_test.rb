# == Schema Information
#
# Table name: companies
#
#  id         :bigint           not null, primary key
#  name       :string
#  acn        :string
#  address_1  :string
#  address_2  :string
#  city       :string
#  state      :string
#  country    :string
#  post_code  :integer
#  contact_no :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class CompanyTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
