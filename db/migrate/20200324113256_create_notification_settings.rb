class CreateNotificationSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :push_notification_settings do |t|
      t.belongs_to :user, index: true
      t.json :preferences, default: {}
      t.timestamps
    end
  end
end
