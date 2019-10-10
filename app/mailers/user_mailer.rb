class UserMailer < ApplicationMailer
 
 default :from => "sparestaff.com"
  def listing_create_confirmation (user)
	  @user = user
		mail(to: @user.email, subject: "Please approved listing")
  end

  def admin_listing_confirmation (user_admin)
   admin = user_admin.pluck(:email)
 	 @admin = admin
 	 mail(to: @admin, subject: "Please approved listing")
  end

  def tfn_verification(user)
  	@user = user
  	mail(to: @user.email, subject: "Please Add Tax File Number(TFN)")
  end

  def photo_verification (user)
  	@user = user 
  	mail(to: @user.email, subject: "Please approve listing")
  end
end
