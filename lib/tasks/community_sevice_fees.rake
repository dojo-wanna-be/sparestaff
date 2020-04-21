namespace :community_service_fees do
  desc "Creating notification_setting for users"
  task update_service_fee: :environment do
    Transaction.all.update(commission_from_hirer: 3.0, commission_from_poster: 10.0)
  end
end