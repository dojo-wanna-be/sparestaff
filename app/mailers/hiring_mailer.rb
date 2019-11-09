class HiringMailer < ApplicationMailer
  default :from => "noreply@sparestaff.com.au"

  def hiring_changed_email_to_hirer(listing, hirer, transaction)
    @listing = listing
    @transaction = transaction
    @hirer = hirer
    mail(to: hirer.email, subject: "Hiring Change Request")
  end

  def hiring_changed_email_to_poster(listing, poster, transaction)
    @listing = listing
    @transaction = transaction
    @poster = poster
    mail(to: poster.email, subject: "Hiring Change Request")
  end
end
