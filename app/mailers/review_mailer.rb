class ReviewMailer < ApplicationMailer
	default :from => "noreply@sparestaff.com.au"

	def review_email_to_user(sender, receiver)
		@receiver = receiver
		@sender = sender
		mail(to: @receiver.email, subject: "You received a new review")
	end
end