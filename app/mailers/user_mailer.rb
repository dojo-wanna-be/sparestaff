class UserMailer < ApplicationMailer
  default :from => "noreply@sparestaff.com.au"

  def listing_create_confirmation(user, listing)
    @listing = listing
		mail(to: user.email, subject: "Congrats, your listing is published!")
  end

  def admin_listing_confirmation(user_admin)
   @admin = user_admin.pluck(:email)
 	 mail(to: @admin, subject: "Please approve listing")
  end

  def tfn_and_photo_verification(user, listing)
    @listing = listing
  	mail(to: user.email, subject: "Add employee TFN and Photo ID for your listing")
  end

  def user_confirmed(user)
    mail(to: user.email, subject: "Welcome to Spare Staff")
  end
end
