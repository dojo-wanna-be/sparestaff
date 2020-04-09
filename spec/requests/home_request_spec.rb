require 'rails_helper'

RSpec.describe HomeController, type: :controller do

	before(:each) do
		@poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
  end

   describe "GET index" do

	  it "has a 200 status code" do
	    get :index
	    expect(response.success?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end
  

  describe "GET email_availability" do

	  it "has a 200 status code" do
	    get :email_availability, params: {user: {email: "poster123@gmail.com"}, form: "login", :format => :json}
	    expect(response.success?).to eq(true)
    	expect(response.status).to eq(200)
    end
  end
end
