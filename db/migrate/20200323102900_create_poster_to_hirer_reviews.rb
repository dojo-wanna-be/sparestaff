class CreatePosterToHirerReviews < ActiveRecord::Migration[5.2]
  def change
    create_table :poster_to_hirer_reviews do |t|
      t.integer :sender_id
      t.integer :receiver_id
      t.integer :listing_id

      t.timestamps
    end
  end
end
