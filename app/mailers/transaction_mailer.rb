class TransactionMailer < ApplicationMailer
  default :from => "noreply@sparestaff.com.au"

  def listing_hiring_request_received(poster)
    mail(to: poster.email, subject: "New Hiring Request")
  end

  def listing_hiring_request_sent(hirer)
    mail(to: hirer.email, subject: "Hiring Request sent successfully")
  end
end
