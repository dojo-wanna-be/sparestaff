class TransactionMailer < ApplicationMailer
  helper EmployeeListingsHelper

  default :from => "noreply@sparestaff.com.au"

  def request_to_hire_email_to_poster(transaction, listing, poster, hirer, message)
    @listing = listing
    @hirer = hirer
    @poster = poster
    @transaction = transaction
    @message = message
    mail(to: poster.email, subject: "Pending Employee hiring request for #{listing.name}")
  end

  def request_to_hire_email_to_hirer(transaction, listing, hirer)
    @listing = listing
    @hirer = hirer
    @poster = @listing.poster
    @transaction = transaction
    mail(to: hirer.email, subject: "Employee hiring Request Sent for #{listing.name}")
  end

  def hiring_cancelled_email_to_hirer(listing, hirer, transaction)
    @transaction = transaction
    @listing = listing
    @hirer = hirer
    mail(to: hirer.email, subject: "Hiring Cancelled")
  end

  def hiring_cancelled_email_to_poster(listing, poster, transaction, hirer)
    @transaction = transaction
    @listing = listing
    @poster = poster
    @hirer = hirer
    mail(to: poster.email, subject: "Hiring Cancelled")
  end

  def send_hiring_details(transaction, email)
    @transaction = transaction
    mail(to: email, subject: "Hiring Details")
  end
end
