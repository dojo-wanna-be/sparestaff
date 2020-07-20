class AddDeclineReasonByPosterToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :decline_reason_by_poster, :text
  end
end
