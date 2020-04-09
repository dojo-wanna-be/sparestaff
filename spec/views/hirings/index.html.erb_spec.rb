require 'rails_helper'

RSpec.describe "hirings/index", type: :view do

  before(:each) do
  	@transaction = Array.new
  	@past_transaction = Array.new
  	@decline_listing = Array.new
    @poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    1.times do
      @transaction << FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
      @past_transaction << FactoryGirl.create(:transaction, state: "completed", employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
      @decline_listing << FactoryGirl.create(:transaction, state: "rejected", employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    end
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.first.id)
  end

  describe 'hiring/index.html.erb' do
	  it 'displays all transaction' do
	    render :template => "hirings/index.html.erb", locals: {:@hired_listing_transactions => @transaction, :@past_listing_transactions => @past_transaction, :@declined_listing_transactions => @decline_listing  }

	    #hired listings
	      expect(rendered).to match /james clark/
	      expect(rendered).to match /test bugs/
	      expect(rendered).to match /This hiring isn't confirmed yet. The Poster has 48 hours to respond/

	    #past listings
	      expect(rendered).to match /Past Hiring/

	    #decline listings
	      expect(rendered).to match /Declined Hirings/
	  end
	end

end
