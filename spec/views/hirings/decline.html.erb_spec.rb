require 'rails_helper'

RSpec.describe "hirings/decline", type: :view do

  before(:each) do
    @poster = FactoryGirl.create(:user)
  	@hirer =  FactoryGirl.create(:user)
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
    @conversation = FactoryGirl.create(:conversation, receiver_id: @poster.id, sender_id: @hirer.id, employee_listing_id: @employee_listing.id, transaction_id: @transaction.id)
  end

  describe 'inboxes/hirer_decline-reservation-step-1-popup' do
	  it 'hirer decline request hiring step 2' do
	    render :partial => "inboxes/hirer_decline-reservation-step-1-popup", locals: {:@transaction => @transaction }
	      expect(rendered).to match /hirer_decline-reservation-step-1-popup/
	  end
	end

end
