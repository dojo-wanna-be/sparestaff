# == Schema Information
#
# Table name: employee_listings
#
#  id                                    :bigint           not null, primary key
#  address_1                             :string
#  address_2                             :string
#  available_in_holidays                 :boolean          default(FALSE)
#  birth_year                            :integer
#  city                                  :string
#  country                               :string
#  deactivated                           :boolean          default(FALSE)
#  deactivation_feedback                 :text
#  deactivation_reason                   :integer          default(7)
#  end_publish_date                      :date
#  first_name                            :string
#  gender                                :string
#  has_vehicle                           :boolean          default(FALSE)
#  holiday_price                         :decimal(, )      default(0.0)
#  last_name                             :string
#  lister_type                           :string
#  listing_step                          :integer
#  minimum_working_hours                 :integer
#  optional_comments                     :text
#  other_residency_status                :string
#  post_code                             :integer
#  profile_picture_content_type          :string
#  profile_picture_file_name             :string
#  profile_picture_file_size             :bigint
#  profile_picture_updated_at            :datetime
#  published                             :boolean          default(FALSE)
#  residency_status                      :string
#  skill_description                     :text
#  start_publish_date                    :date
#  state                                 :string
#  tfn                                   :string
#  title                                 :string
#  verification_back_image_content_type  :string
#  verification_back_image_file_name     :string
#  verification_back_image_file_size     :bigint
#  verification_back_image_updated_at    :datetime
#  verification_front_image_content_type :string
#  verification_front_image_file_name    :string
#  verification_front_image_file_size    :bigint
#  verification_front_image_updated_at   :datetime
#  verification_type                     :string
#  weekday_price                         :decimal(, )      default(0.0)
#  weekend_price                         :decimal(, )      default(0.0)
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  classification_id                     :integer
#  lister_id                             :integer
#

require 'test_helper'

class EmployeeListingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
