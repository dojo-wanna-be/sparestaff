# == Schema Information
#
# Table name: employee_skills
#
#  id                  :bigint           not null, primary key
#  skill_name          :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  employee_listing_id :bigint
#
# Indexes
#
#  index_employee_skills_on_employee_listing_id  (employee_listing_id)
#
# Foreign Keys
#
#  fk_rails_...  (employee_listing_id => employee_listings.id)
#

require 'test_helper'

class EmployeeSkillTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
