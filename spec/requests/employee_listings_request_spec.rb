require 'rails_helper'

RSpec.describe EmployeeListingsController, type: :controller do

  before(:each) do
    @lister = FactoryGirl.create(:company)
    @user = FactoryGirl.create(:user)
    @user.update_attributes(company_id: @lister.id, user_type: "owner")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
  end


  describe "POST #create" do 
    
    it "has return 200 status code" do 
   		employee_listing = EmployeeListing.where(id: @employee_listing.id)
   		expect(employee_listing.count).to be > 0
      expect(response.status).to eq(200)   		
    end
  end
  
  describe "PUT update/:id" do
  	let(:attr) do 
      { :title => 'new title', :classification_id => 101 }
    end
    it "has return 200 status code" do 
      @employee_listing.update_attributes(title: "new title", classification_id: 101)
      expect(@employee_listing.title).to eq(attr[:title])
      expect(@employee_listing.classification_id).to eq(attr[:classification_id])
      expect(response.status).to eq(200)
    end
  end

  describe "PATCH listing_deactivation/:id" do

  	it "listing_deactivation successfully return 200 status code" do
      @employee_listing.update_attributes(deactivated: true, deactivation_reason: 0, deactivation_feedback: "I want to deactivate this listing right now")
    	expect(@employee_listing.deactivated).to eq (true)
      expect(response.status).to eq(200)
  	end
  end
  

  describe "GET #show" do

    it 'has a 200 status code' do
      get :show, params: { id: @employee_listing.id }
      expect(response.success?).to eq (true)
      expect(response.status).to eq(200)
    end
  end

end