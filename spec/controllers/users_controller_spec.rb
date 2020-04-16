require 'rails_helper'

RSpec.describe UsersController, type: :controller do

	before(:each) do
    @review = Array.new
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
    2.times do
      @review << FactoryGirl.create(:review, sender_id: @poster.id, receiver_id: @hirer.id, listing_id: @employee_listing.id, transaction_id:   @transaction.id)
    end
  end


  describe "POST #profile_photo" do

	  it "has a 200 status code" do
	    post :profile_photo, params: {user: {avatar: fixture_file_upload("/files/test.jpeg",
      "image/png")} }
	    expect(response.successful?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end

  describe "GET #destroy_profile_photo" do

    it "has a 200 status code" do
      get :destroy_profile_photo, xhr: true
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  describe "GET #show_all_listings" do

    it "has a 200 status code" do
      get :show_all_listings, xhr: true, params: {id: @hirer.id}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  describe "GET #show_all_poster_reviews" do

    it "has a 200 status code" do
      get :show_all_poster_reviews, xhr: true, params: {id: @hirer.id}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  describe "GET #show_all_hirer_reviews" do

    it "has a 200 status code" do
      get :show_all_hirer_reviews, xhr: true, params: {id: @poster.id}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  describe "GET edit/:id" do

	  it "has a 200 status code" do
	    user = controller.current_user
	    user.update_attributes(first_name: "jack", last_name: "paul")
	    expect(user.first_name).to eq("jack")
    	expect(user.last_name).to eq("paul")
    	expect(response.status).to eq(200)
    end
  end

  describe "GET show/:id" do
  	it "has 200 status code" do
  		get :show, params: {id: @hirer.id}
  		expect(response.successful?).to eq(true)
    	expect(response.status).to eq(200)
  	end
  end
end
