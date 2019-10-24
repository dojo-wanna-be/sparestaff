# == Schema Information
#
# Table name: tax_details
#
#  id             :bigint           not null, primary key
#  a              :float
#  b              :float
#  weekly_earning :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class TaxDetail < ApplicationRecord
end
