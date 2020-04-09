require 'rails_helper'

RSpec.describe PayoutsController, type: :controller do
 
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
  end


  describe "GET #index" do

	  it "has a 200 status code" do
	    get :index
	    expect(response.success?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end

  describe "GET transaction_history" do

    it "show Completed Payouts details" do
    	get :transaction_history
    	expect(response.success?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end


  describe "POST security/:id" do
	  it "check password security" do
	  	post :security, params: {old_password: "12345678", new_password: "adware@123"}
	  	expect(response.success?).to eq(true)
    	expect(response.status).to eq(200)
	  end
  end

end
