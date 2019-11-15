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
end
