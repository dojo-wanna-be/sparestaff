require 'rails_helper'

RSpec.describe "employee_listings/publish_listing", type: :view do

  before(:each) do
  	@published_listing = Array.new
  	@unpublished_listing = Array.new
    @poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    1.times do
      @published_listing << FactoryGirl.create(:employee_listing, city: "Sydney", state: "NSW", title: "published_listing", lister_id: @lister.id) 
    end
  end

  describe 'employee_listings/publish_listing.html.erb' do
	  it 'displays employee_listings details correctly' do
	    assign(:employee_listing, @published_listing)

	    render :template => "employee_listings/publish_listing.html.erb", locals: {:@published_listings => @published_listing}
	      expect(rendered).to match /You've completed your listing!/
	  end
	end
end
