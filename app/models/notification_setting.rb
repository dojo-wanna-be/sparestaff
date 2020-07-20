class NotificationSetting < ApplicationRecord
	belongs_to :user
	after_create :set_default_preferences

  def set_default_preferences
    new_preferences = {
      notification_about_receive_message:      true,
      notification_about_promotions_on_email:  true,
      notification_about_promotions_on_phone:  true
    }
    self.update(preferences: new_preferences)
  rescue
    self.update(preferences: default_preferences)
    setting = u.build_notification_setting
		setting.save
  end

  private
    def default_preferences
      {
        notification_about_receive_message:      true,
        notification_about_promotions_on_email:  true,
        notification_about_promotions_on_phone:  true
      }
    end
end
