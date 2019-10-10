class UserMailer < ApplicationMailer
  default :from => "sparestaff.com"

  def listing_create_confirmation(user)
	  @user = user
		mail(to: @user.email, subject: "Listing created successfully")
  end

  def admin_listing_confirmation(user_admin)
   @admin = user_admin.pluck(:email)
 	 mail(to: @admin, subject: "Please approve listing")
  end

  def tfn_verification(user)
  	@user = user
  	mail(to: @user.email, subject: "Please Add Tax File Number(TFN)")
  end

  def photo_verification(user)
  	@user = user 
  	mail(to: @user.email, subject: "Please Upload ID in Listing")
  end
end
