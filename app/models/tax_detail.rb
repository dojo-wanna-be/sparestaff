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

  def self.tax_calculation(weekly_earning)
    weekly_earnings = self.order(:weekly_earning).pluck(:weekly_earning)
    weekly_earnings.each do |earning|
      if weekly_earning < earning
        tax_detail = self.find_by(weekly_earning: earning)
        tax_details_hash = {a: tax_detail.a, b: tax_detail.b}
        return tax_details_hash
      end
    end
    # tax_details_hash = {a: 0.4700, b: 576.7885}
    tax_details_hash = {a: 0.4700, b: 516.788}
  end

end
