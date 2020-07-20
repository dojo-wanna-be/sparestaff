class AddActiveToUserCoupons < ActiveRecord::Migration[5.2]
  def change
    add_column :user_coupons, :active, :boolean, default: false
  end
end
