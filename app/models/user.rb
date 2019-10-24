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

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable, :trackable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :validatable, :omniauthable, omniauth_providers: [:facebook]

  belongs_to :company, optional: true
  has_many :employee_listings, as: :lister
  enum user_type: { owner: 0, hr: 1 }

  ROLES = [["HR Manager", 1], ["Director/Owner", 0]]

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0,20]
      user.first_name = auth.info.first_name
      user.last_name = auth.info.last_name
      user.skip_confirmation!
    end
  end

  def is_individual?
    user_type.eql?(nil) && !self.company.present? && self.employee_listings.present?
  end

  def is_owner?
    user_type.eql?("owner") && self.company.present?
  end

  def is_hr?
    user_type.eql?("hr") && self.company.present?
  end

  def name
    "#{self.first_name} #{self.last_name}"
  end
end
