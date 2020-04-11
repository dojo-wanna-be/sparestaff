require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe InboxesController, type: :controller  do

	before(:each) do
    @sender = FactoryGirl.create(:user, email: "dimcame@gmail.com")
    @receiver = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @sender.confirmed_at = Time.zone.now
    @sender.save
    sign_in @sender
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @sender.id, poster_id: @receiver.id )
    @conversation = FactoryGirl.create(:conversation, receiver_id: @receiver.id, sender_id: @sender.id, employee_listing_id: @employee_listing.id, transaction_id: @transaction.id)
  end

  describe "GET #index" do

	  it "has a 302 status code" do
	     get :index
	     expect(response.status).to eq(200)
       expect(response.success?).to eq(true)
    end
  end

  describe "POST #create" do

  	it "check message has been created or not" do
	    post :create, params: {id: @conversation.id, message: {content: "Test message!"}, :format => "text/html"}
      @message = Message.last
      if @message.present?
        expect(response.status).to eq(200)
        expect(response.success?).to eq(true)
      end
    end
  end
  
  describe "GET #show" do

    it 'shas a 302 status code' do
      get :show, params: { id: @conversation.id }
       expect(response.status).to eq(200)
       expect(response.success?).to eq(true)
    end
  end
  
end

