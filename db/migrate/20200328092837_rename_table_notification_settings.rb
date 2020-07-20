class RenameTableNotificationSettings < ActiveRecord::Migration[5.2]
  def change
	rename_table :push_notification_settings, :notification_settings
  end
end
