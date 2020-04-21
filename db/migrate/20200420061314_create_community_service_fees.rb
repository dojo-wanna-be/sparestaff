class CreateCommunityServiceFees < ActiveRecord::Migration[5.2]
  def change
    create_table :community_service_fees do |t|
      t.float :commission_from_hirer
      t.float :commission_from_poster

      t.timestamps
    end
  end
end
