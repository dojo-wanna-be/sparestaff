require 'rails_helper'

RSpec.describe "employee_listings/edit", type: :view do
  
  before(:each) do
    @lister = FactoryGirl.create(:company)
    @user = FactoryGirl.create(:user)
    @user.confirmed_at = Time.zone.now
    @user.save
    sign_in @user
    @user.update_attributes(company_id: @lister.id, user_type: "owner")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    classification = @employee_listing.classification
    @classification = classification.classification.id
    @sub_classification = classification.id
  end


  describe 'employee_listings/edit.html.erb' do

	  it 'edit employee_listings details correctly' do
	    assign(:employee_listing, @employee_listing)

      #Listing Details
	    render :template => "employee_listings/edit.html.erb", locals: {:@employee_listing => @employee_listing}
	      expect(rendered).to match /test bugs/

      #Employee Skills
       render partial: "employee_listings/edit_employee_skills_form", locals: {:@employee_listing => @employee_listing, :@classification_id => @classification, :@sub_classification_id => @sub_classification }
       expect(rendered).to match /Planning &amp; Scheduling/
       expect(rendered).to match /Contracts Management/
       
      #listing_pricing
       render partial: "employee_listings/edit_pricing_form", locals: {:@employee_listing => @employee_listing}
       expect(rendered).to match /Select price per hour that Hirers are expected to pay to hire the employee/
       expect(rendered).to match /678.988/

      #listing_availability
        render partial: "employee_listings/edit_availability_form", locals: {:@employee_listing => @employee_listing}
        expect(rendered).to match /Availability of the employee/

      #listing_status 
       render partial: "employee_listings/edit_listing_status_form", locals: {:@employee_listing => @employee_listing}
       expect(rendered).to match /Listing Status/
       expect(rendered).to match /true/

      #deactivation_reason
       render partial: "employee_listings/deactivation_reason_form", locals: {:@employee_listing => @employee_listing}
       expect(rendered).to match /Permanently deactivate your employee listing/
       expect(rendered).to match /Our company no longer have this employee/

      #deactivation_feedback
        render partial: "employee_listings/deactivation_feedback_form", locals: {:@employee_listing => @employee_listing}
        expect(rendered).to match /This will help us improve for the future/
        expect(rendered).to match //
	  end
	end

end