require 'rails_helper'

RSpec.describe "employee_listings/show", type: :view do

  before(:each) do
    @poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
  	@poster.confirmed_at = Time.zone.now
    @poster.save
    sign_in @poster
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, city: "Sydney", state: "NSW", title: "published_listing", lister_id: @lister.id)
	  availability = FactoryGirl.create(:listing_availability, day: "sunday", employee_listing_id: @employee_listing.id)
	  @listing_availability = @employee_listing.listing_availabilities
	  @reviews = Array.new
	  @reviews_all = 0
	  @friendliness = 0
	  @knowledge_n_skills = 0 
	  @punctuality = 0 
	  @management_skill = 0 
	  @professionalism = 0 
	  @communication = 0
	  @poster_reviews = Array.new
  end


  describe 'employee_listings/index.html.erb' do
	  it 'displays employee_listings details correctly' do
	    assign(:employee_listing, @employee_listing)

	    render :template => "employee_listings/show.html.erb", locals: {:@employee_listing => @employee_listing, :@avalibilities => @listing_availability, :@reviews_all => @reviews, :@reviews_all_star => @reviews_all, :@friendliness_grade=> @friendliness, :@knowledge_n_skills_grade => @knowledge_n_skills, :@punctuality_grade => @punctuality, :@management_skill_grade => @management_skill, :@professionalism_grade => @professionalism, :@communication_grade => @communication, :@poster_reviews => @poster_reviews }

	      expect(rendered).to match /Sydney/
	      expect(rendered).to match /NSW/
	      expect(rendered).to match /published_listing/
	      expect(rendered).to match /Male/
	  end
	end
end
