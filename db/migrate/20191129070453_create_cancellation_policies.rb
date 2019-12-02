class CreateCancellationPolicies < ActiveRecord::Migration[5.2]
  def change
    create_table :cancellation_policies do |t|
      t.integer :before_cancellation_hours, default: 0
      t.integer :after_cancellation_hours, default: 0

      t.timestamps
    end
  end
end
