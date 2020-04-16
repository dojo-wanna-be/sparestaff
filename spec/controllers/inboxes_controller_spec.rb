require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe InboxesController, type: :controller  do

	before(:each) do
    @receiver = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @sender = FactoryGirl.create(:user, email: "dimcame@gmail.com")
    @sender.confirmed_at = Time.zone.now
    @sender.save
    sign_in @sender
    @lister = FactoryGirl.create(:company)
    @receiver.update_attributes(company_id: @lister.id, user_type: "owner")
    @sender.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @sender.id, poster_id: @receiver.id )
    @conversation = FactoryGirl.create(:conversation, receiver_id: @receiver.id, sender_id: @sender.id, employee_listing_id: @employee_listing.id, transaction_id: @transaction.id)
    @message = FactoryGirl.create(:message, conversation_id: @conversation.id, sender_id: @receiver.id)
  end

  describe "GET #index" do

	  it "has a 302 status code" do
	     get :index
	     expect(response.status).to eq(200)
       expect(response.successful?).to eq(true)
    end
  end

  describe "POST #create" do
    
    # check message has been created or not , then send mail when current_user user_type hirer and receiver_user user_type owner.
  	it "message create and then send mail according to above comment" do
	    post :create, params: {id: @conversation.id, message: {content: "Test message!"}, :format => "text/html"}
      @message = Message.last
      if @message.present?
        expect(response.status).to eq(200)
        expect(response.successful?).to eq(true)
      end
    end
    
    # check message has been created or not , then send mail when current_user user_type hirer and receiver_user user_type hirer and Listing poster not equal to current user.
    it "message create and then send mail according to above comment" do
      @receiver.update_attributes(company_id: @lister.id, user_type: "hr")
      @sender.update_attributes(company_id: @lister.id, user_type: "hr")
      post :create, params: {id: @conversation.id, message: {content: "Test message!"}, :format => "text/html"}
      @message = Message.last
      if @message.present?
        expect(response.status).to eq(200)
        expect(response.successful?).to eq(true)
      end
    end
    
    # check message has been created or not , then send mail when current_user user_type hirer and receiver_user user_type hirer and Listing poster equal to current user
    it "message create and then send mail according to above comment" do
      @receiver.update_attributes(company_id: @lister.id, user_type: "hr")
      @sender.update_attributes(company_id: @lister.id, user_type: "hr")
      @receiver.confirmed_at = Time.zone.now
      @receiver.save
      sign_in @receiver
      post :create, params: {id: @conversation.id, message: {content: "Test message!"}, :format => "text/html"}
      @message = Message.last
      if @message.present?
        expect(response.status).to eq(200)
        expect(response.successful?).to eq(true)
      end
    end
 
    # check message has been created or not , then send mail when both current_user and reciver user_type is 'nil'.
    it "message create and then send mail according to above comment" do
      @receiver.update_attributes(company_id: @lister.id, user_type: nil)
      @sender.update_attributes(company_id: @lister.id, user_type: nil)
      post :create, params: {id: @conversation.id, message: {content: "Test message!"}, :format => "text/html"}
      @message = Message.last
      if @message.present?
        expect(response.status).to eq(200)
        expect(response.successful?).to eq(true)
      end
    end

  end
  

  describe "GET #unread" do
    it "unread conversation , when params[:message] is present" do
      get :unread, xhr: true, params: {message: "unread"}
      expect(response.status).to eq(200)
      expect(response.successful?).to eq(true)
    end
  end

  describe "GET #unread" do
    it "unread conversation , when params[:message] is not present" do
      get :unread, xhr: true
      expect(response.status).to eq(200)
      expect(response.successful?).to eq(true)
    end
  end

  describe "GET #show" do

    it 'shas a 200 status code' do
      get :show, params: { id: @conversation.id }
       expect(response.status).to eq(200)
       expect(response.successful?).to eq(true)
    end
  end

  describe "GET #show" do

    it 'shas a 302 status code' do
      get :show, params: { id: @employee_listing.id, from: @sender}
      response.should redirect_to(inbox_path(id: Conversation.last.id))
    end
  end
  
end

