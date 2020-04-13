require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the ApplicationHelperHelper. For example:
#
# describe ApplicationHelperHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe ApplicationHelper, type: :helper do
  
  before(:each) do
  	@poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
    @review = FactoryGirl.create(:review, sender_id: @poster.id, receiver_id: @hirer.id, listing_id: @employee_listing.id, transaction_id:   @transaction.id, work_environment_grade: 4, suitability_grade: 3, communication_grade: 4, employee_satisfaction_grade: 5, friendliness_grade: 5, punctuality_grade: 4, professionalism_grade: 3, knowledge_n_skills_grade: 5, management_skill_grade: 5)
  end

  describe "#listing_start_date(@employee_listing)" do
    it "returns @employee_listing.start_publish_date" do
      helper.listing_start_date(@employee_listing).should eq(Date.today + 2.days)
    end
  end

  describe "#listing_end_date(@employee_listing)" do
    it "returns @employee_listing.end_publish_date" do
      helper.listing_end_date(@employee_listing).should eq(@employee_listing.end_publish_date)
    end
  end
  

  describe "#listing_star_rating(@employee_listing.id)" do
    it "returns listing_star_rating" do
      helper.listing_star_rating(@employee_listing.id).should eq(4.333333333333333)
    end
  end

  describe "#friendliness_grade(@employee_listing.id)" do
    it "returns friendliness_grade rating" do
      helper.friendliness_grade(@employee_listing.id).should eq(5.0)
    end
  end

  describe "#knowledge_n_skills_grade(@employee_listing.id)" do
    it "returns knowledge_n_skills_grade rating" do
      helper.knowledge_n_skills_grade(@employee_listing.id).should eq(5.0)
    end
  end

  describe "#punctuality_grade(@employee_listing.id)" do
    it "returns punctuality_grade rating" do
      helper.punctuality_grade(@employee_listing.id).should eq(4.0)
    end
  end

  describe "#management_skill_grade(@employee_listing.id)" do
    it "returns management_skill_grade rating" do
      helper.management_skill_grade(@employee_listing.id).should eq(5.0)
    end
  end
  
  describe "#professionalism_grade(@employee_listing.id)" do
    it "returns professionalism_grade rating" do
      helper.professionalism_grade(@employee_listing.id).should eq(3.0)
    end
  end

  describe "#communication_grade(@employee_listing.id)" do
    it "returns communication_grade rating" do
      helper.communication_grade(@employee_listing.id).should eq(4.0)
    end
  end
  
end
