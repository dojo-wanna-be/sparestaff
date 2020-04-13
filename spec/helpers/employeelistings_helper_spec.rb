require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the EmployeelistingsHelper. For example:
#
# describe EmployeelistingsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe EmployeeListingsHelper, type: :helper do

  before(:each) do
  	@booking = Array.new
  	@poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
    @poster.confirmed_at = Time.zone.now
    @poster.save
    sign_in @poster
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @listing_availability = FactoryGirl.create(:listing_availability, employee_listing_id: @employee_listing.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    3.times do |index|
    	if index == 0
        @booking << FactoryGirl.create(:booking, transaction_id: @transaction.id)
      elsif index == 1
        @booking << FactoryGirl.create(:booking, transaction_id: @transaction.id, day: "monday")
      else index == 2
        @booking << FactoryGirl.create(:booking, transaction_id: @transaction.id, day: "tuesday")
      end
    end 
    @bookings = Booking.where(transaction_id: @transaction.id).group_by(&:day)
  end


  describe "#selected_start_time(@employee_listing,day)" do
    it "returns selected_start_time" do
      helper.selected_start_time(@employee_listing, "sunday").should eq((Date.today + 4.hours).strftime("%H:%M"))
    end
  end

  describe "#selected_end_time(@employee_listing,day)" do
    it "returns selected_end_time" do
      helper.selected_end_time(@employee_listing, "sunday").should eq((Date.today + 10.hours).strftime("%H:%M"))
    end
  end

  describe "#start_time_range(@listing_availability)" do
    it "returns start_time_range" do
      helper.start_time_range(@listing_availability).include?((Date.today + 4.hours).strftime("%H:%M"))
    end
  end

  describe "#end_time_range(@listing_availability)" do
    it "returns end_time_range" do
      helper.end_time_range(@listing_availability).include?((Date.today + 10.hours).strftime("%H:%M"))
    end
  end

  describe "#minimum_price(@employee_listing)" do
    it "returns minimum_price" do
      helper.minimum_price(@employee_listing).should eq(0.2e2)
    end
  end

  describe "#unavailable_time_slots(@bookings)" do
    it "returns unavailable start_time and end_time slots" do
      helper.unavailable_time_slots(@bookings).include?(:start_time_slots)
      helper.unavailable_time_slots(@bookings).include?(:end_time_slots)
    end
  end
end
