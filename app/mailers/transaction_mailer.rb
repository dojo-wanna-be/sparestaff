class TransactionMailer < ApplicationMailer
  default :from => "noreply@sparestaff.com.au"

  def listing_hiring_request_received(poster)
    mail(to: poster.email, subject: "New Hiring Request")
  end

  def listing_hiring_request_sent(hirer)
    mail(to: hirer.email, subject: "Hiring Request sent")
  end

  def send_hiring_details(transaction, email)
    mail(to: email, subject: "Hiring Details")
  end

  def listing_cancelled_successfully(listing, hirer)
    @listing = listing
    mail(to: hirer.email, subject: "Hiring Cancelled")
  end
end
