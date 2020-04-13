require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the TransactionsHelper. For example:
#
# describe TransactionsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe TransactionsHelper, type: :helper do

  before(:each) do
  	@hirer =  FactoryGirl.create(:user, email: "hirer@gmail.com")
    @poster = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @company = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @company.id, user_type: "owner")
    @hirer.update_attributes(company_id: @company.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @company.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
  end
  

  describe "#price(@transaction)" do
    it "returns total_amount , if current user hirer" do
      helper.price(@transaction).should eq(504.7)
    end

    it "returns poster_total_amount , if current user poster" do
    	@poster.confirmed_at = Time.zone.now
      @poster.save
      sign_in @poster
      helper.price(@transaction).should eq(441.0)
    end
  end
  

  describe "#address_1" do
    it "return address_1" do 
    	helper.address_1.should eq("Treasury Casino and Hotel Brisban, William Street")
    end
  end

  describe "#address_2" do
    it "return address_2" do 
    	helper.address_2.should eq("28 Nerrigundah Drive")
    end
  end

  describe "#city" do
    it "return city" do 
    	helper.city.should eq("Brisbane City QLD")
    end
  end

end
