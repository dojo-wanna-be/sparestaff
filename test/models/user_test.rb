# == Schema Information
#
# Table name: users
#
#  id                         :bigint           not null, primary key
#  email                      :string           default(""), not null
#  encrypted_password         :string           default(""), not null
#  reset_password_token       :string
#  reset_password_sent_at     :datetime
#  remember_created_at        :datetime
#  confirmation_token         :string
#  confirmed_at               :datetime
#  confirmation_sent_at       :datetime
#  unconfirmed_email          :string
#  first_name                 :string
#  last_name                  :string
#  company_id                 :integer
#  user_type                  :integer
#  allow_marketing_promotions :boolean          default(FALSE)
#  provider                   :string
#  uid                        :string
#  phone_number               :string
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  is_admin                   :boolean
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
