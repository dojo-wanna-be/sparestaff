class CreateUserCoupons < ActiveRecord::Migration[5.2]
  def change
    create_table :user_coupons do |t|
      t.integer :user_id
      t.integer :coupon_id

      t.timestamps
    end
  end
end
