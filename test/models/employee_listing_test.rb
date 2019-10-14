# == Schema Information
#
# Table name: employee_listings
#
#  id                                    :bigint           not null, primary key
#  classification_id                     :integer
#  title                                 :string
#  first_name                            :string
#  last_name                             :string
#  tfn                                   :string
#  birth_year                            :integer
#  address_1                             :string
#  address_2                             :string
#  city                                  :string
#  state                                 :string
#  country                               :string
#  post_code                             :integer
#  residency_status                      :string
#  other_residency_status                :string
#  verification_type                     :string
#  gender                                :string
#  has_vehicle                           :boolean          default(FALSE)
#  skill_description                     :text
#  optional_comments                     :text
#  published                             :boolean          default(FALSE)
#  lister_id                             :integer
#  lister_type                           :string
#  listing_step                          :integer
#  created_at                            :datetime         not null
#  updated_at                            :datetime         not null
#  available_in_holidays                 :boolean          default(FALSE)
#  weekday_price                         :decimal(, )
#  holiday_price                         :decimal(, )
#  minimum_working_hours                 :integer
#  start_publish_date                    :date
#  end_publish_date                      :date
#  weekend_price                         :decimal(, )
#  profile_picture_file_name             :string
#  profile_picture_content_type          :string
#  profile_picture_file_size             :bigint
#  profile_picture_updated_at            :datetime
#  verification_front_image_file_name    :string
#  verification_front_image_content_type :string
#  verification_front_image_file_size    :bigint
#  verification_front_image_updated_at   :datetime
#  verification_back_image_file_name     :string
#  verification_back_image_content_type  :string
#  verification_back_image_file_size     :bigint
#  verification_back_image_updated_at    :datetime
#

require 'test_helper'

class EmployeeListingTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
