class RenameColumnCancellationHoursInCancellationPolicy < ActiveRecord::Migration[5.2]
  def change
    rename_column :cancellation_policies, :after_cancellation_hours, :accepted_state_cancellation_hours
    rename_column :cancellation_policies, :before_cancellation_hours, :pending_state_cancellation_hours
  end
end
