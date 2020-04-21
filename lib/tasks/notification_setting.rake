namespace :notification_setting do
  desc "Creating notification_setting for users"
  task creating_notification_setting: :environment do
    User.all.each do |u|
      setting = u.build_notification_setting
      setting.save
    end
  end
end