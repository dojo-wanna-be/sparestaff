require 'rails_helper'

RSpec.describe ListingAvailability, type: :model do
  before(:each) do
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @listing_availability = FactoryGirl.create(:listing_availability, employee_listing_id: @employee_listing.id)
  end

  it "is valid with valid attributes" do
    expect(@listing_availability).to be_valid
  end
end
