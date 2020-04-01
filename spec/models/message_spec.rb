require 'rails_helper'

RSpec.describe Message, type: :model do
 
  before(:each) do
    @sender = FactoryGirl.create(:user)
  	@receiver = FactoryGirl.create(:user, id: 7, email: "receiver@sparestaff.com")
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @conversation = FactoryGirl.create(:conversation, receiver_id: @receiver.id, sender_id: @sender.id, employee_listing_id: @employee_listing.id )
    @message = FactoryGirl.create(:message, conversation_id: @conversation.id, sender_id: @sender.id)
  end
   
  it "is valid with valid attributes" do
    expect(@message).to be_valid
  end

  it "is not valid without sender" do
    @message.sender = nil
    expect(@message).not_to be_valid
  end

  describe "Association" do 
    it { should belong_to(:sender).class_name('User')}
    it { should belong_to(:conversation).touch(true)}
  end

end
