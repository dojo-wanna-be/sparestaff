require 'rails_helper'

RSpec.describe Review, type: :model do

  before(:each) do
    @poster = FactoryGirl.create(:user)
  	@hirer =  FactoryGirl.create(:user)
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
    @review = FactoryGirl.create(:review, sender_id: @poster.id, receiver_id: @hirer.id, listing_id: @employee_listing.id, transaction_id:   @transaction.id)
  end

  it "is valid with valid attributes" do
    expect(@review).to be_valid
  end
end
