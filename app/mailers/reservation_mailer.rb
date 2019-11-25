class ReservationMailer < ApplicationMailer
  default :from => "noreply@sparestaff.com.au"

  def reservation_changed_email_to_hirer(listing, hirer, transaction)
    @listing = listing
    @transaction = transaction
    @hirer = hirer
    mail(to: hirer.email, subject: "Reservation Change Request")
  end

  def reservation_changed_email_to_poster(listing, poster, transaction)
    @listing = listing
    @transaction = transaction
    @poster = poster
    mail(to: poster.email, subject: "Reservation Change Request")
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
    mail(to: poster.email, subject: "You declined a hire request")
  end
end
