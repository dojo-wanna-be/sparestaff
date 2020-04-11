require 'rails_helper'

RSpec.describe EmployeeListingsController, type: :controller do

  before(:each) do
    @lister = FactoryGirl.create(:company)
    @user = FactoryGirl.create(:user, email: "testuser@gmail.com")
    @user.confirmed_at = Time.zone.now
    @user.save
    sign_in @user
    @user.update_attributes(company_id: @lister.id, user_type: "owner")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
  end


  describe "POST #create" do 
    
    it "when user select poster_type individual " do 
   		#step_1
       patch :create_listing_step_1, params: {poster_type: "individual"}
      #after create first step it redirect_to step_3_employee_path(id: EmployeeListing.last.id)
       patch :create_listing_step_3, params: {id: EmployeeListing.last.id, "employee_listing"=>{"title"=>"test games john", "first_name"=>"tester", "last_name"=>"anas", "tfn"=>"5656", "birth_year"=>"1991", "address_1"=>"", "address_2"=>"Mig c- 9, Aashiyana", "city"=>"Moradabad", "state"=>"ACT", "post_code"=>"2342", "country"=>"Australia", "residency_status"=>"Permanent Resident/Citizen", "other_residency_status"=>"", "verification_type"=>"Australian Driver Licence", "gender"=>"male", "has_vehicle"=>"false"}, "verification_front_image"=>"", "verification_back_image"=>"", "commit"=>"Continue"}

      #ater this redirect_to step_4_employee_path(id: EmployeeListing.last.id)
      patch :create_listing_step_4, params: {id: EmployeeListing.last.id, "parent_classification"=>"68", "classification_id"=>"72", "employee_listing"=>{"skill_description"=>"I am a beginner", "optional_comments"=>""}, "employee_skills"=>"ruby and rails", "relevant_documents"=>"", "employee_listing_language_ids"=>["1"], "commit"=>"Continue"}

      #ater this redirect_to step_5_employee_path(id: EmployeeListing.last.id)
      patch :create_listing_step_5, params: {id: EmployeeListing.last.id, "slot_ids"=>["1"], "start_time"=>[{"sunday"=>"02:00", "monday"=>"01:00", "tuesday"=>"03:00", "wednesday"=>"03:00", "thursday"=>"01:00", "friday"=>"05:00"}], "end_time"=>[{"sunday"=>"04:00", "monday"=>"11:00", "tuesday"=>"09:00", "wednesday"=>"18:00", "thursday"=>"17:00", "friday"=>"18:00"}], "unavailable_days"=>["saturday"], "employee_listing"=>{"available_in_holidays"=>"false", "weekday_price"=>"20.0", "other_weekday_price"=>"20", "weekend_price"=>"20.0", "other_weekend_price"=>"10", "holiday_price"=>"20.0", "other_holiday_price"=>"15", "minimum_working_hours"=>"0", "start_publish_date"=> Date.today + 1.day, "end_publish_date"=> 3.month.from_now}, "current_date"=>Date.today, "confirm_details"=>"", "commit"=>"Preview"}
      
      #ater this redirect_to preview_employee_path(id: EmployeeListing.last.id)
      patch :publish_listing, params: {id: EmployeeListing.last.id, "published"=>"true", "commit"=>"Publish"}
    end

    it "when user select poster_type company" do
      #step_1
      patch :create_listing_step_1, params: {poster_type: "company"}

      # after this it redirect_to step_2_employee_path(id: EmployeeListing.last.id)
      patch :create_listing_step_2, params: {id: EmployeeListing.last.id, "company_id"=> @lister.id, "company"=>{"name"=>"test game", "acn"=>"8978", "address_1"=>"Treasury Casino and Hotel Brisban, William Street", "address_2"=>"Treasury Casino and Hotel Brisban, William Street", "city"=>"Brisbane City QLD", "state"=>"ACT", "post_code"=>"5676", "country"=>"Australia", "contact_no"=>"0412456675"}, "user_role"=>"0", "commit"=>"Continue"}

      #after this it redirect_to step_3_employee_path(id: EmployeeListing.last.id)
       patch :create_listing_step_3, params: {id: EmployeeListing.last.id, "employee_listing"=>{"title"=>"test games john", "first_name"=>"tester", "last_name"=>"anas", "tfn"=>"5656", "birth_year"=>"1991", "address_1"=>"", "address_2"=>"Mig c- 9, Aashiyana", "city"=>"Moradabad", "state"=>"ACT", "post_code"=>"2342", "country"=>"Australia", "residency_status"=>"Permanent Resident/Citizen", "other_residency_status"=>"", "verification_type"=>"Australian Driver Licence", "gender"=>"male", "has_vehicle"=>"false"}, "verification_front_image"=>"", "verification_back_image"=>"", "commit"=>"Continue"}

      #ater this redirect_to step_4_employee_path(id: EmployeeListing.last.id)
      patch :create_listing_step_4, params: {id: EmployeeListing.last.id, "parent_classification"=>"68", "classification_id"=>"72", "employee_listing"=>{"skill_description"=>"I am a beginner", "optional_comments"=>""}, "employee_skills"=>"ruby and rails", "relevant_documents"=>"", "employee_listing_language_ids"=>["1"], "commit"=>"Continue"}

      #ater this redirect_to step_5_employee_path(id: EmployeeListing.last.id)
      patch :create_listing_step_5, params: {id: EmployeeListing.last.id, "slot_ids"=>["1"], "start_time"=>[{"sunday"=>"02:00", "monday"=>"01:00", "tuesday"=>"03:00", "wednesday"=>"03:00", "thursday"=>"01:00", "friday"=>"05:00"}], "end_time"=>[{"sunday"=>"04:00", "monday"=>"11:00", "tuesday"=>"09:00", "wednesday"=>"18:00", "thursday"=>"17:00", "friday"=>"18:00"}], "unavailable_days"=>["saturday"], "employee_listing"=>{"available_in_holidays"=>"false", "weekday_price"=>"20.0", "other_weekday_price"=>"20", "weekend_price"=>"20.0", "other_weekend_price"=>"10", "holiday_price"=>"20.0", "other_holiday_price"=>"15", "minimum_working_hours"=>"0", "start_publish_date"=> Date.today + 1.day, "end_publish_date"=> 3.month.from_now}, "current_date"=>Date.today, "confirm_details"=>"", "commit"=>"Preview"}
      
      #ater this redirect_to preview_employee_path(id: EmployeeListing.last.id)
      patch :publish_listing, params: {id: EmployeeListing.last.id, "published"=>"true", "commit"=>"Publish"}
    end
  end
  
  describe "PUT update/:id" do
    it "has return update notice" do 
      patch :update, params: {"id"=> @employee_listing.id, "edit"=>"listing_details", "relevant_documents"=>"", "employee_listing"=>{"title"=>"test games john", "first_name"=>"Nisha", "last_name"=>"Singh", "tfn"=>"5656", "birth_year"=>"1991", "address_1"=>"", "address_2"=>"Mig c- 9, Aashiyana", "city"=>"Moradabad", "state"=>"ACT", "post_code"=>"2342", "country"=>"Australia", "residency_status"=>"Permanent Resident/Citizen", "other_residency_status"=>"", "verification_type"=>"Australian Driver Licence", "gender"=>"male", "has_vehicle"=>"false"}, "verification_front_image"=>"", "verification_back_image"=>""}
      expect(flash[:notice]).to eq("Updated Successfully")
    end
  end

  describe "PATCH listing_deactivation/:id" do

  	it "listing_deactivation successfully return 200 status code" do
     patch :listing_deactivation, params: {"id" => @employee_listing.id, "edit"=>"deactivation_feedback", "employee_listing"=>{"deactivation_reason"=>"0"}, "commit"=>"Next"}
      if expect(flash[:notice]).to eq("Reason Submitted Successfully")
        patch :listing_deactivation, params: {"id" => @employee_listing.id, "edit"=>"deactivation_done", "employee_listing"=>{"deactivation_feedback"=>"yes I want permanently deactivate this"}, "commit"=>"Permanently deactivate"}
        expect(flash[:notice]).to eq("Listing Deactivated Successfully")
      end
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