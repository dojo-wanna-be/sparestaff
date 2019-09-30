# == Schema Information
#
# Table name: employee_listing_languages
#
#  id                  :bigint           not null, primary key
#  employee_listing_id :integer
#  language_id         :integer
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#

require 'test_helper'

class EmployeeListingLanguageTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
