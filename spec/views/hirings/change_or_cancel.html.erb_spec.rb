require 'rails_helper'

RSpec.describe "hirings/change_or_cancel", type: :view do

  before(:each) do
    @poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
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

  describe 'hiring/change_or_cancel.html.erb' do
	  it 'display hiring details' do
	    render :template => "hirings/change_or_cancel.html.erb", locals: {:@transaction => @transaction, :@listing => @employee_listing }
	      expect(rendered).to match /Total employment contract/
	  end
	end
end