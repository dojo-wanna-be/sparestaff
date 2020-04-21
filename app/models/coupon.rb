class Coupon < ApplicationRecord
  has_many :user_coupons
  has_many :users, through: :user_coupons
end
