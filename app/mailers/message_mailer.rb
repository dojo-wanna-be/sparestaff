class MessageMailer < ApplicationMailer
	default :from => "noreply@sparestaff.com.au"

	def message_email_to_hirer(message, sender, receiver)
		@message = message
		@receiver = receiver
		@sender = sender
		mail(to: @receiver.email, subject: "Poster send you a message")
	end

	def message_email_to_poster(message, sender, receiver)
		@message = message
		@sender = sender
		@receiver = receiver
		mail(to: @receiver.email, subject: "Hirer send you a message")
	end
end	