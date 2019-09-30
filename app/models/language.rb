# == Schema Information
#
# Table name: languages
#
#  id            :bigint           not null, primary key
#  language      :string
#  language_code :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class Language < ApplicationRecord
  has_many :employee_listing_languages
  has_many :employee_listings, through: :employee_listing_languages
end
