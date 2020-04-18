require 'rails_helper'

RSpec.describe HomeController, type: :controller do

	before(:each) do
		@poster = FactoryGirl.create(:user)
  	@hirer =  FactoryGirl.create(:user)
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @lister = FactoryGirl.create(:company)
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @listing_availability = FactoryGirl.create(:listing_availability, employee_listing_id: @employee_listing.id)
  end

   describe "GET index" do

	  it "has a 200 status code" do
	    get :index
	    expect(response.successful?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end
  

  describe "GET email_availability" do

	  it "has a 200 status code" do
	    get :email_availability, params: {user: {email: "poster123@gmail.com"}, form: "login", :format => :json}
	    expect(response.successful?).to eq(true)
    	expect(response.status).to eq(200)
    end

    it "has a 200 status code" do
      get :email_availability, params: {user: {email: "poster7787@gmail.com"}, form: "signup", :format => :json}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end


  describe "GET #keyword_search" do
    it "show listing when it search from keyword" do
      get :keyword_search, params: {term: @employee_listing.first_name}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end
  
  describe "GET #search" do
    it "search listing results" do
     get :search, params: { "keyword_search"=> @employee_listing.title, "parent"=>[@employee_listing.classification_id], "child"=>[], "location"=>"Melbourne VIC, Australia", "latitude"=>"-37.8136276", "longitude"=>"144.9630576", "city"=>"Melbourne", "daterange"=> @employee_listing.start_publish_date - @employee_listing.end_publish_date, "start_date"=> @employee_listing.start_publish_date, "end_date"=> @employee_listing.end_publish_date, "slot"=>["2"], "minimum_rate"=>"30", "maximum_rate"=>"50", "residency_status"=>[@employee_listing.residency_status], "gender"=>[@employee_listing.gender], "has_vehicle"=>[@employee_listing.has_vehicle], "minimun_age"=>"20", "maximum_age"=>"30", "profile_picture"=>{"photo_required"=>"true"}, "availability"=>[@employee_listing.listing_availabilities], "language"=>["English"]}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

end
