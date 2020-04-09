require 'rails_helper'

RSpec.describe "inboxes/views", type: :view do

	before(:each) do
		@conversation = Array.new
		@messages = Array.new
    @sender = FactoryGirl.create(:user, email: "dimcame@gmail.com")
    @receiver = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @receiver.confirmed_at = Time.zone.now
    @receiver.save
    sign_in @receiver
    @lister = FactoryGirl.create(:company)
    @sender.update_attributes(company_id: @lister.id, user_type: "owner")
    @receiver.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @sender.id, poster_id: @receiver.id )
    1.times do 
      @conversation << FactoryGirl.create(:conversation, receiver_id: @receiver.id, sender_id: @sender.id, employee_listing_id: @employee_listing.id, transaction_id: @transaction.id)
    @messages<< FactoryGirl.create(:message, conversation_id: @conversation.last.id, sender_id: @sender.id)
    end
    @conversation_last = @conversation.last
  end

  describe 'inboxes/index.html.erb' do
	  it 'details of conversation' do
	    render :template => "inboxes/index.html.erb", locals: {:@conversations => @conversation, :@unread_count => "1", :@current_user => @receiver }
	      expect(rendered).to match /Test message for sparestaff/
	      expect(rendered).to match /test bugs/
	      expect(rendered).to match /Melbourne/
	      expect(rendered).to match /Australia/
	  end
	end  
  
  describe 'inboxes/show.html.erb' do
	  it 'details of show action' do
	    render :template => "inboxes/show.html.erb", locals: {:@conversation => @conversation_last, :@transaction => @transaction, :@current_user => @receiver, :@listing => @employee_listing }
	      expect(rendered).to match /accept-reservation-popup/
	      expect(rendered).to match /decline-reservation-step-1-popup/
	      expect(rendered).to match /decline-reservation-step-2-popup/
	  end
	end 

  describe 'inboxes/accept-reservation-popup.html.erb' do
	  it 'details of accept-reservation-popup partial' do
	    render :partial => "inboxes/accept-reservation-popup", locals: {:@transaction => @transaction, :@current_user => @receiver, :@listing => @employee_listing }
	      expect(rendered).to match /accept-reservation-popup/
	      expect(rendered).to match /Accept this request/
	      expect(rendered).to match /Type optional message to Hirer/
	  end
	end 

	 describe 'inboxes/accept_or_decline_option.html.erb' do
	  it 'details of accept_or_decline_option partial' do
	    render :partial => "inboxes/accept_or_decline_option", locals: {:@transaction => @transaction, :@current_user => @receiver, :@listing => @employee_listing }
	      expect(rendered).to match /test john requested to hire james clark/
	  end
	end
  
  describe 'inboxes/cancel_hiring_button.html.erb' do
	  it 'details of cancel_hiring_button partial' do
	    render :partial => "inboxes/cancel_hiring_button", locals: {:@transaction => @transaction, :@current_user => @receiver, :@listing => @employee_listing }
	      expect(rendered).to match /Payment is only processed if Poster accepts your request/
	      expect(rendered).to match /Poster has 48 hours to accept or decline your request. Send messages if you have any further questions/
	      expect(rendered).to match /If you need to make changes to this hiring/
	      expect(rendered).to match /cancel this request and create a new one instead/
	  end
	end

end

