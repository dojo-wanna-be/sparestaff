# == Schema Information
#
# Table name: users
#
#  id                         :bigint           not null, primary key
#  allow_marketing_promotions :boolean          default(FALSE)
#  confirmation_sent_at       :datetime
#  confirmation_token         :string
#  confirmed_at               :datetime
#  email                      :string           default(""), not null
#  encrypted_password         :string           default(""), not null
#  first_name                 :string
#  is_admin                   :boolean          default(FALSE)
#  last_name                  :string
#  phone_number               :string
#  provider                   :string
#  remember_created_at        :datetime
#  reset_password_sent_at     :datetime
#  reset_password_token       :string
#  uid                        :string
#  unconfirmed_email          :string
#  user_type                  :integer
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#  company_id                 :integer
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
