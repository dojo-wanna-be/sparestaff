require 'rails_helper'


RSpec.describe EmployeeListingsController, type: :controller do

  before(:each) do
    @lister = FactoryGirl.create(:company)
    @user = FactoryGirl.create(:user)
    @user.confirmed_at = Time.zone.now
    @user.save
    sign_in @user
    @user.update_attributes(company_id: @lister.id, user_type: "owner")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
  end
  
  describe "GET #index" do
    it "published_employee_listings" do
      get :index
      expect(response.successful?).to eq (true)
      expect(response.status).to eq(200)
    end

    it "unpublished_company_listings" do
      @employee_listing.update_attribute(:published, false)
      get :index
      expect(response.successful?).to eq (true)
      expect(response.status).to eq(200)
    end
  end

  describe "POST #create" do 
    
    it "when user select poster_type individual " do 
   		#step_1
       get :new_listing_step_1, params: {back: "true", id:  @employee_listing.id}
      
      # after create first step_1
       patch :create_listing_step_1, params: {poster_type: "individual"}
       
       get :new_listing_step_2, params: {back: "true", id: EmployeeListing.last.id}
      
      #after create first step it redirect_to step_3_employee_path(id: EmployeeListing.last.id)
       patch :create_listing_step_3, params: {id: EmployeeListing.last.id, "employee_listing"=>{"title"=>"test games john", "first_name"=>"tester", "last_name"=>"anas", "tfn"=>"5656", "birth_year"=>"1991", "address_1"=>"", "address_2"=>"Mig c- 9, Aashiyana", "city"=>"Moradabad", "state"=>"ACT", "post_code"=>"2342", "country"=>"Australia", "residency_status"=>"Permanent Resident/Citizen", "other_residency_status"=>"", "verification_type"=>"Australian Driver Licence", "gender"=>"male", "has_vehicle"=>"false"}, "verification_front_image"=>"", "verification_back_image"=>"", "commit"=>"Continue"}
       
       get :new_listing_step_3, params: {back: "true", id: EmployeeListing.last.id}

      #ater this redirect_to step_4_employee_path(id: EmployeeListing.last.id)
      patch :create_listing_step_4, params: {id: EmployeeListing.last.id, "parent_classification"=>"68", "classification_id"=>"72", "employee_listing"=>{"skill_description"=>"I am a beginner", "optional_comments"=>""}, "employee_skills"=>"ruby and rails", "relevant_documents"=>"", "employee_listing_language_ids"=>["1"], "commit"=>"Continue"}
      
      get :new_listing_step_4, params: {back: "true", id: EmployeeListing.last.id}
      
      #ater this redirect_to step_5_employee_path(id: EmployeeListing.last.id)
      patch :create_listing_step_5, params: {id: EmployeeListing.last.id, "slot_ids"=>["1"], "start_time"=>[{"sunday"=>"02:00", "monday"=>"01:00", "tuesday"=>"03:00", "wednesday"=>"03:00", "thursday"=>"01:00", "friday"=>"05:00"}], "end_time"=>[{"sunday"=>"04:00", "monday"=>"11:00", "tuesday"=>"09:00", "wednesday"=>"18:00", "thursday"=>"17:00", "friday"=>"18:00"}], "unavailable_days"=>["saturday"], "employee_listing"=>{"available_in_holidays"=>"false", "weekday_price"=>"20.0", "other_weekday_price"=>"20", "weekend_price"=>"20.0", "other_weekend_price"=>"10", "holiday_price"=>"20.0", "other_holiday_price"=>"15", "minimum_working_hours"=>"0", "start_publish_date"=> Date.today + 1.day, "end_publish_date"=> 3.month.from_now}, "current_date"=>Date.today, "confirm_details"=>"", "commit"=>"Preview"}
      
      get :new_listing_step_5, params: {back: "true", id: EmployeeListing.last.id}

      #ater this redirect_to preview_employee_path(id: EmployeeListing.last.id)
      patch :publish_listing, params: {id: EmployeeListing.last.id, "published"=>"true", "commit"=>"Publish"}
      
      get :preview_listing, params: {back: "true", id: EmployeeListing.last.id}     
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
  

  describe "Coverage listing creation step if listing is not save" do
    
    it "#create_listing_step_1, when poster_type company" do
      @user.update_attributes(company_id: nil, user_type: "")
      patch :create_listing_step_1, params: {poster_type: "company"}
    end

    it "#new_listing_step_2" do
      get :new_listing_step_2, params: {back: "false", id: @employee_listing.id}
    end

    it "#new_listing_step_3" do
      @employee_listing.update_attribute(:listing_step, 0)
      get :new_listing_step_3, params: {back: "false", id: @employee_listing.id}
      expect(flash[:error]).to eq("You can't go to this step")
    end

    it "#new_listing_step_4" do
      @employee_listing.update_attribute(:listing_step, 0)
      get :new_listing_step_4, params: {back: "false", id: @employee_listing.id}
      expect(flash[:error]).to eq("You can't go to this step")
    end

    it "#new_listing_step_5" do
      @employee_listing.update_attribute(:listing_step, 0)
      get :new_listing_step_5, params: {back: "false", id: @employee_listing.id}
      expect(flash[:error]).to eq("You can't go to this step")
    end

    it "#preview_listing" do
      @employee_listing.update_attribute(:listing_step, 0)
      get :preview_listing, params: {back: "false", id: @employee_listing.id}
      expect(flash[:error]).to eq("You can't go to this step")
    end

    it "#publish_listing" do
      #if request.get?
       @employee_listing.update_attribute(:published, false)
       get :publish_listing, params: {id: @employee_listing.id} 
    end

    it "publish_listing" do
      #if request.patch?
       patch :publish_listing, params: {id: @employee_listing.id, save_later: true}
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

    it 'has a 200 status code, when @employee_listing.published? is equal to true' do
      get :show, params: { id: @employee_listing.id }
      expect(response.successful?).to eq (true)
      expect(response.status).to eq(200)
    end

    it 'has a 200 status code, when @employee_listing.published? is equal to false' do
      @employee_listing.update_attribute(:published, false)
      get :show, params: { id: @employee_listing.id }
      expect(flash[:error]).to eq("Please publish this listing first")
    end
  end

  describe "GET #edit" do
   it "#edit" do
    get :edit, params: {id: @employee_listing.id}
    expect(response.successful?).to eq (true)
    expect(response.status).to eq(200)
   end
  end

  describe "PUT update/:id" do
    it "has return update notice, when params[:edit] equal to listing_details" do 
      patch :update, params: {"id"=> @employee_listing.id, "edit"=>"listing_details", "relevant_documents"=>"", "employee_listing"=>{"title"=>"test games john", "first_name"=>"Nisha", "last_name"=>"Singh", "tfn"=>"5656", "birth_year"=>"1991", "address_1"=>"", "address_2"=>"Mig c- 9, Aashiyana", "city"=>"Moradabad", "state"=>"ACT", "post_code"=>"2342", "country"=>"Australia", "residency_status"=>"Permanent Resident/Citizen", "other_residency_status"=>"", "verification_type"=>"Australian Driver Licence", "gender"=>"male", "has_vehicle"=>"false"}, "verification_front_image"=>"", "verification_back_image"=>""}
      expect(flash[:notice]).to eq("Updated Successfully")
    end

    it "has return update notice, when params[:edit] equal to employee_skills" do
      patch :update, params: {"id"=> @employee_listing.id, "edit"=>"employee_skills", "parent_classification"=>"77", "classification_id"=>"78", "employee_listing"=>{"skill_description"=>"test", "optional_comments"=>""}, "employee_skills"=>"team,zone", "employee_listing_language_ids"=>["1", "11"]}
      expect(flash[:notice]).to eq("Updated Successfully")
    end

    it "has return update notice, when params[:edit] equal to listing_availability" do
      patch :update, params: {"id"=> @employee_listing.id, "edit"=>"listing_availability", "slot_ids"=>["3"], "start_time"=>[{"sunday"=>"02:00", "tuesday"=>"02:00", "wednesday"=>"20:00"}], "end_time"=>[{"sunday"=>"10:00", "tuesday"=>"20:00", "wednesday"=>"23:00"}], "unavailable_days"=>["monday", "thursday", "friday", "saturday"], "employee_listing"=>{"available_in_holidays"=>"true", "minimum_working_hours"=>"0"}}
      expect(flash[:notice]).to eq("Updated Successfully")
    end

  end


  describe "PATCH #add_profile_picture" do
    it "add listing profile photo" do
      patch :add_profile_picture, xhr:true, params: {id: @employee_listing.id, image: fixture_file_upload("/files/test.jpeg","image/png")}
     expect(response.successful?).to eq (true)
     expect(response.status).to eq(200)
    end

    it "delete listing profile photo, when params[:type] is delete" do
      patch :add_profile_picture, xhr:true, params: {id: @employee_listing.id, type: "delete"}
     expect(response.successful?).to eq (true)
     expect(response.status).to eq(200)
    end

  end

  describe "PATCH #add_relevant_document" do
    it "add relevant_document " do
      patch :add_relevant_document, xhr:true, params: {id: @employee_listing.id, image: fixture_file_upload("/files/test.jpeg","image/png")}
     expect(response.successful?).to eq (true)
     expect(response.status).to eq(200)
     relevant_document = @employee_listing.relevant_documents.last
      if relevant_document.present?
        patch :add_relevant_document, xhr:true, params: {id: @employee_listing.id, relevant_document_id: relevant_document.id}
        expect(response.successful?).to eq (true)
        expect(response.status).to eq(200)
      end
    end

  end

  describe "PATCH #add_verification_front" do
    it "#add_verification_front" do
      patch :add_verification_front, xhr:true, params: {id: @employee_listing.id, image: fixture_file_upload("/files/test.jpeg","image/png")}
     expect(response.successful?).to eq (true)
     expect(response.status).to eq(200)
    end

    it "delete add_verification_front image, when params[:type] is delete" do
      patch :add_verification_front, xhr:true, params: {id: @employee_listing.id, type: "delete"}
     expect(response.successful?).to eq (true)
     expect(response.status).to eq(200)
    end

  end

  describe "PATCH #add_verification_back" do
    it "#add_verification_back" do
      patch :add_verification_back, xhr:true, params: {id: @employee_listing.id, image: fixture_file_upload("/files/test.jpeg","image/png")}
     expect(response.successful?).to eq (true)
     expect(response.status).to eq(200)
    end

    it "delete add_verification_back image, when params[:type] is delete" do
      patch :add_verification_back, xhr:true, params: {id: @employee_listing.id, type: "delete"}
     expect(response.successful?).to eq (true)
     expect(response.status).to eq(200)
    end

  end

end