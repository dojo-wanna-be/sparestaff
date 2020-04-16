class CreateCoupons < ActiveRecord::Migration[5.2]
  def change
    create_table :coupons do |t|
      t.string :coupon_code
      t.float :discount

      t.timestamps
    end
  end
end
