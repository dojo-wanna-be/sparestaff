require 'rails_helper'

RSpec.describe "employee_listings/views", type: :view do

  before(:each) do
  	@published_listing = Array.new
  	@unpublished_listing = Array.new
    @poster = FactoryGirl.create(:user)
  	@hirer =  FactoryGirl.create(:user)
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    1.times do
      @published_listing << FactoryGirl.create(:employee_listing, city: "Sydney", state: "NSW", title: "published_listing", lister_id: @lister.id) 
    end
    1.times do
      @unpublished_listing << FactoryGirl.create(:employee_listing, city: "Canberra", state: "ACT", title: "unpublished_listing", published: false, lister_id: @lister.id) 
    end
  end

  describe 'employee_listings/index.html.erb' do
	  it 'displays employee_listings details correctly' do
	    assign(:employee_listing, @published_listing)

	    render :template => "employee_listings/index.html.erb", locals: {:@published_listings => @published_listing}
      # published listing
	      expect(rendered).to match /Sydney/
	      expect(rendered).to match /NSW/
	      expect(rendered).to match /published_listing/

	  end

	  it "displays all employee_listing where published false" do
	    assign(:employee_listing, @unpublished_listing)
    	
	    render :template => "employee_listings/index.html.erb", locals: {:@unpublished_listings => @unpublished_listing }
      
      # unpublished listing
	      expect(rendered).to match /Canberra/
	      expect(rendered).to match /ACT/
	      expect(rendered).to match /published_listing/
	  end

	end

end
