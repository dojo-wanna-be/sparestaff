class AddProbationaryPeriodToCompany < ActiveRecord::Migration[5.2]
  def change
    add_column :companies, :probationary_period, :integer
  end
end
