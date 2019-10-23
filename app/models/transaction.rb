class Transaction < ApplicationRecord
  belongs_to :employee_listing
  belongs_to :hirer, class_name: "User", foreign_key: "hirer_id"
  belongs_to :poster, class_name: "User", foreign_key: "poster_id"
  has_many :bookings

  enum frequency: { weekly: 0, fortnight: 1 }
  enum state: { initialized: 0, pending: 1, accepted: 3, rejected: 4, cancelled: 5, expired: 6 }
end
