require 'rails_helper'
require 'stripe_mock'

RSpec.describe PayoutsController, type: :controller do
 
  before(:each) do
    @poster = FactoryGirl.create(:user)
  	@hirer =  FactoryGirl.create(:user, password: "12345678", password_confirmation: "12345678")
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
    @notification_setting = FactoryGirl.create(:notification_setting, user_id: @hirer.id, preferences: {})
  end


  describe "GET #index" do

	  it "has a 200 status code" do
	    get :index
	    expect(response.successful?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end

  describe "GET transaction_history, when current_user is hr" do

    it "show Completed Payouts details" do
    	get :transaction_history
    	expect(response.successful?).to eq(true)
    	expect(response.status).to eq(200)
    end

    it "show Completed Payouts details, when current_user is owner" do
      @poster.confirmed_at = Time.zone.now
      @poster.save
      sign_in @poster
      get :transaction_history
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end


  describe "POST security/:id" do
	  it "check password security" do
	  	post :security, params: {old_password: "12345678", new_password: "adware@123"}
      expect(flash[:success]).to eq("Password updated successfully!")
      response.should redirect_to(root_path)
	  end

    it "check password security" do
      post :security, params: {old_password: "", new_password: "adware@123"}
      expect(flash[:error]).to eq("Current password is blank or Invalid!")
    end
  end


  # describe "POST create/:id", live: true do
  #   it "account create, when user select the user_type individual" do
  #     @stripe_test_helper = StripeMock.create_test_helper
  #     StripeMock.stop
  #     post :create, params: {"user_type"=>"individual", "first_name"=>"jack", "last_name"=>"paul", "business_name"=>"", "business_first_name"=>"", "business_surname"=>"", "abn"=>"", "dob"=>{"(3i)"=>"14", "(2i)"=>"10", "(1i)"=>"1947"}, "address_line1"=>"54 Albacore Crescent", "city"=>"BEVENDALE", "state"=>"NSW", "country"=>"AU", "postal_code"=>"2581", "bank_holder_name"=>"jack paul", "bank_account_number"=>"000123456", "bank_routing_number"=>"110000", "stripe_verification_file"=> fixture_file_upload("/files/test1.png","image/png")}
  #     expect(flash[:notice]).to eq("Account Created Successfully") if (response.success? == true)
  #   end
  # end
  

  describe "PATCH #change_preference" do
    it "#change_preference" do
      patch :change_preference, params: {notification_about_receive_message: "on", notification_about_promotions_on_email: "on", notification_about_promotions_on_phone: "on"}
    end
  end
end