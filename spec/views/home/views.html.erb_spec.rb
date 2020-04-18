require 'rails_helper'

RSpec.describe "home/views", type: :view do
  

  before(:each) do
    @poster = FactoryGirl.create(:user)
  	@hirer =  FactoryGirl.create(:user)
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @user = User.new
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    listings = EmployeeListing.active.published.where(id: @employee_listing.id ).order(updated_at: :desc)
    @employee_listings = listings.paginate(:page => params[:page], :per_page => 4)
    @classifications = Classification.includes(:sub_classifications).where(parent_classification_id: nil)
  end


  describe 'home/index.html.erb' do
    it 'display home/index action details' do
      render :template => "home/index.html.erb", locals: {:@employee_listings=> @employee_listings}
        expect(rendered).to match /You might be interested in/
    end
  end

  describe 'home/search.html.erb' do
    it 'display home/search action details' do
      render :template => "home/search.html.erb", locals: {:@employee_listings=> @employee_listings}
        expect(rendered).to match /test bugs/
        expect(rendered).to match /james clark/
        expect(rendered).to match /Melbourne/
    end
  end
end
