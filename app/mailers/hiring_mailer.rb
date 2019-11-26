class HiringMailer < ApplicationMailer
  default :from => "noreply@sparestaff.com.au"

  def hiring_changed_email_to_hirer(listing, hirer, transaction)
    @listing = listing
    @transaction = transaction
    @hirer = hirer
    mail(to: hirer.email, subject: "Hiring Change Request")
  end

  def hiring_changed_email_to_poster(listing, poster, transaction, message)
    @listing = listing
    @transaction = transaction
    @poster = poster
    @message = message
    mail(to: poster.email, subject: "Hiring Change Request")
  end

  def employee_hire_confirmation_email_to_hirer(listing, hirer, transaction)
    @listing = listing
    @transaction = transaction
    @poster = @listing.poster
    @hirer = hirer
    mail(to: hirer.email, subject: "Employee hire confirmed for #{listing.name}")
  end

  def employee_hire_confirmation_email_to_poster(listing, poster, transaction)
    @listing = listing
    @transaction = transaction
    @poster = poster
    @hirer = transaction.hirer
    mail(to: poster.email, subject: "Employee hire confirmed for #{listing.name}")
  end

  def employee_hire_declined_email_to_Hirer(listing, hirer, transaction)
    @listing = listing
    @transaction = transaction
    @hirer = hirer
    mail(to: hirer.email, subject: "Employee hire request delined for #{listing.name}")
  end

  def employee_hire_declined_email_to_Poster(listing, poster, transaction)
    @listing = listing
    @transaction = transaction
    @poster = poster
    mail(to: poster.email, subject: "You declined a request")
  end
end
