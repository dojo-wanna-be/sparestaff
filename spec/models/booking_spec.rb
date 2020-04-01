require 'rails_helper'

RSpec.describe Booking, type: :model do
   before(:each) do
   	@hirer =  FactoryGirl.create(:user)
    @poster = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
  end

  it "is valid with valid attributes" do
    expect(@booking).to be_valid
  end
  
end
