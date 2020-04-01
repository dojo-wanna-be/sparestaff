require 'rails_helper'

RSpec.describe Conversation, type: :model do
 
  before(:each) do
  	@sender = FactoryGirl.create(:user)
    @receiver = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @sender.id, poster_id: @receiver.id )
    @conversation = FactoryGirl.create(:conversation, receiver_id: @receiver.id, sender_id: @sender.id, employee_listing_id: @employee_listing.id, transaction_id: @transaction.id)
  end

  it "is valid with valid attributes" do
    expect(@conversation).to be_valid
  end

  it "is not validate without sender" do
  	@conversation.sender = nil
  	expect(@conversation).not_to be_valid
  end
  
   it "is not validate without receiver" do
  	@conversation.receiver = nil
  	expect(@conversation).not_to be_valid
  end
  
  describe "Association" do 
    it { should belong_to(:employee_listing)}
    it { should belong_to(:sender).class_name('User')}
    it { should belong_to(:receiver).class_name('User')}
    it { should belong_to(:employee_listing_transaction).class_name('Transaction')}
	end
  
end
