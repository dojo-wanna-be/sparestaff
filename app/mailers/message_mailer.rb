class MessageMailer < ApplicationMailer
	default :from => "noreply@sparestaff.com.au"

	def message_email_to_hirer(message, sender, receiver)
		@message = message
		@receiver = receiver
		@sender = sender
		if @receiver.user_type == "hr"
			mail(to: receiver.email, subject: "Poster send you a message")
	    else
	    	mail(to: sender.email, subject: "Poster send you a message")
	    end	
	end

	def message_email_to_poster(message, poster)
		@message = message
		@poster = poster
		mail(to: poster.email, subject: "Hirer send you a message")
	end
end	