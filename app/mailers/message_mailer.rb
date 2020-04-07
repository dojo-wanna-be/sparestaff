class MessageMailer < ApplicationMailer
	default :from => "noreply@sparestaff.com.au"

	def message_email_to_hirer(message, sender, receiver,conversation)
		@message = message
		@receiver = receiver
		@sender = sender
		@conversation = conversation
		mail(to: @receiver.email, subject: "You received a new message")
	end

	def message_email_to_poster(message, sender, receiver,conversation)
		@message = message
		@sender = sender
		@receiver = receiver
		@conversation = conversation
		mail(to: @receiver.email, subject: "You received a new message")
	end
end	