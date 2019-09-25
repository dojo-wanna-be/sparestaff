class AddAllowMarketingPromotionsToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :allow_marketing_promotions, :boolean, default: false
  end
end
