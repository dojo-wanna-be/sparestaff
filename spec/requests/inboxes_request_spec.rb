require 'rails_helper'

RSpec.describe InboxesController, type: :controller  do

	before(:each) do
    @sender = FactoryGirl.create(:user, email: "dimcame@gmail.com")
    @receiver = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @sender.id, poster_id: @receiver.id )
    @conversation = FactoryGirl.create(:conversation, receiver_id: @receiver.id, sender_id: @sender.id, employee_listing_id: @employee_listing.id, transaction_id: @transaction.id)
    @conversations = Conversation.where("conversations.sender_id = ? OR conversations.receiver_id = ?", @sender.id, @sender.id).order("updated_at desc")
    @message = FactoryGirl.create(:message, conversation_id: @conversation.id, sender_id: @sender.id)
  end

  describe "GET #index" do

	  it "has a 302 status code" do
	     get :index
	     expect(@conversations.count).to be >=0
       expect(response.status).to eq(302)
    end
  end

  describe "POST #create" do

  	it "check message has been created or not" do
  		message = Message.where(id: @message.id)
	    post :create
	    expect(message.count).to be > 0
      expect(response.status).to eq(302)
    end
  end
  
  describe "GET #show" do

    it 'shas a 302 status code' do
      get :show, params: { id: @conversation.id }
      expect(response.status).to eq(302)
    end
  end
  
end

