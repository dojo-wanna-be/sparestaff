require 'rails_helper'

RSpec.describe "hirings/cancel", type: :view do

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

  describe 'hiring/cancel_hiring.html.erb' do
	  it 'display hiring details' do
	    render :template => "hirings/cancel_hiring.html.erb", locals: {:@transaction => @transaction, :@listing => @employee_listing,  :@total_amount => 0.0}
	      expect(rendered).to match /I no longer need to hire an employee/
	      expect(rendered).to match /I made the hiring my mistake/
	  end
	end

  describe 'hiring/tell_poster.html.erb' do
    it 'after cancel request it goes to tell poster action' do
      @transaction.update_attributes(reason: "I made the hiring my mistak", cancelled_by: "hirer", state: "cancelled", cancelled_at: Date.today)
      render :template => "hirings/tell_poster.html.erb", locals: {:@transaction => @transaction, :@listing => @employee_listing,  :@total_amount => 0.0}
        expect(rendered).to match /Tell test john why you need to cancel/
    end
  end

end
