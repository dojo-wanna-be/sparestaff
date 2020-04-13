require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the HomeHelper. For example:
#
# describe HomeHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe HomeHelper, type: :helper do
  
  before(:each) do
    @hirer =  FactoryGirl.create(:user, email: "hirer@gmail.com")
	  @poster = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
	  @lister = FactoryGirl.create(:company)
	  @poster.update_attributes(company_id: @lister.id, user_type: "owner")
	  @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
  end

  describe "#distance_form_search(@employee_listing)" do
    it "returns distance" do
      helper.stub(params: {latitude: 28.7040592, longitude: 77.1024902})
      helper.distance_form_search(@employee_listing.id).should eq(0.0)
    end
  end
end
