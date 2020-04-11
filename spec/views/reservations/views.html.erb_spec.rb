require 'rails_helper'

RSpec.describe "reservations/views", type: :view do

  before(:each) do
  	@transaction = Array.new
  	@complete_transaction = Array.new
    @poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
    @poster.confirmed_at = Time.zone.now
    @poster.save
    sign_in @poster
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @first_transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id:  @first_transaction.id)
    @conversation_first = FactoryGirl.create(:conversation, receiver_id: @poster.id, sender_id: @hirer.id, employee_listing_id: @employee_listing.id, transaction_id: @first_transaction.id)
    @message = FactoryGirl.create(:message, conversation_id: @conversation_first.id, sender_id: @poster.id)
    1.times do
      @transaction << FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
      @complete_transaction << FactoryGirl.create(:transaction, state: "completed", start_date: Date.today.beginning_of_month , end_date: Date.today.beginning_of_month + 3.days , employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    end
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.first.id)
    @conversation = FactoryGirl.create(:conversation, receiver_id: @poster.id, sender_id: @hirer.id, employee_listing_id: @employee_listing.id, transaction_id: @transaction.first.id)
    @conversation = FactoryGirl.create(:conversation, receiver_id: @hirer.id, sender_id: @poster.id, employee_listing_id: @employee_listing.id, transaction_id: @complete_transaction.first.id)
  end

  describe 'reservation/index.html.erb' do
	  it 'displays all reservations' do
	    render :template => "reservations/index.html.erb", locals: {:@posted_listing_transactions => @transaction, :@completed_listing_transactions  => @complete_transaction}

	    #pending listing
	      expect(rendered).to match /Pending/

	    #complete listings
	      expect(rendered).to match /Completed/
	  end
	end
  
  describe 'reservations/show.html.erb' do
	  it 'display reservations details' do
	    render :template => "reservations/show.html.erb", locals: {:@transaction => @first_transaction, :@listing => @employee_listing, :@declined_listing_transactions => @decline_listing }
	      expect(rendered).to match /Friday/
	  end
	end

	describe 'reservations/change_or_cancel.html.erb' do
	  it 'display hiring details' do
	    render :template => "reservations/change_or_cancel.html.erb", locals: {:@transaction => @first_transaction, :@listing => @employee_listing }
	      expect(rendered).to match /Change or cancel test john's hiring reservation/
	  end
	end
  
  describe 'inboxes/accept-reservation-popup' do
	  it 'poster accept hiring' do
	    render :partial => "inboxes/accept-reservation-popup", locals: {:@transaction => @first_transaction, :@listing => @employee_listing }
	      expect(rendered).to match /accept-reservation-popup/
	  end
	end
  
  describe 'inboxes/accept_or_decline_option' do
	  it 'poster decline request hiring step 2' do
	    render :partial => "inboxes/accept_or_decline_option", locals: {:@transaction => @first_transaction, :@listing => @employee_listing }
	      expect(rendered).to match /decline-reservation-step-1-popup/
	  end
	end

	describe 'inboxes/decline-reservation-step-2-popup' do
	  it 'poster decline request hiring step 2' do
	    render :partial => "inboxes/decline-reservation-step-2-popup", locals: {:@transaction => @first_transaction, :@listing => @employee_listing }
	      expect(rendered).to match /decline-reservation-step-2-popup/
	  end
	end

	describe 'hiring/change_reservation.html.erb' do
	  it 'display change_hiring details' do
	    render :template => "reservations/change_reservation.html.erb", locals: {:@transaction => @first_transaction, :@listing => @employee_listing, :@old_transaction => @first_transaction, :@weekly_hourly_total => 0.0 }
	      expect(rendered).to match /20.0/
	  end
	end


	describe 'hiring/cancel_reservation.html.erb' do
	  it 'display reservations details' do
	    render :template => "reservations/cancel_reservation.html.erb", locals: {:@transaction => @first_transaction, :@listing => @employee_listing, :@old_transaction => @first_transaction, :@poster_recieve => 0.0}
	      expect(rendered).to match /My listed employee is no longer available/
	      expect(rendered).to match /I’m looking for a different price or date and time/
	  end
	end

  describe 'hiring/tell_poster.html.erb' do
    it 'after cancel request it goes to tell poster action' do
      render :template => "reservations/tell_hirer.html.erb", locals: {:@transaction => @first_transaction, :@listing => @employee_listing,  :@total_amount => 0.0}
        expect(rendered).to match /Cancelling hiring reservation now can disrupt their plan and have serious implication on their business and work flow/
    end
  end

end
