require 'rails_helper'

RSpec.describe HiringsController, type: :controller do
      
  before(:each) do
    @poster = FactoryGirl.create(:user)
  	@hirer =  FactoryGirl.create(:user)
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
    @conversation = FactoryGirl.create(:conversation, receiver_id: @poster.id, sender_id: @hirer.id, employee_listing_id: @employee_listing.id, transaction_id: @transaction.id)
  end

  describe "GET #index" do

	  it "has a 200 status code" do
	     get :index
       expect(response.status).to eq(200)
       expect(response.successful?).to eq(true)
    end
  end

  describe "GET show/:id" do
    it "show hirings" do
      get :show, params: {id: @transaction.id}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  describe "DELETE #destroy_transaction" do

    it "has a 200 status code" do
       delete :destroy_transaction, xhr:true, params: {id: @transaction.id}
       expect(response.successful?).to eq(true)
       expect(response.status).to eq(200)
    end
  end

  describe "DELETE #destroy_transaction" do

    it "return" do
       transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
       delete :destroy_transaction, xhr:false, params: {id: transaction.id, old_id: @transaction.id}
    end
  end

  describe "GET change_or_cancel/:id" do
    it "change_or_cancel the hiring" do
      get :change_or_cancel, params: {id: @transaction.id}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end
  
  describe "GET get_receipt/:id" do
    it "get_receipt of hiring" do
      get :get_receipt, params: {id: @transaction.id}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  describe "GET #receipt_details" do
    it "when PaymentReceipt is present?" do
      ChargeForListing.new(@transaction.id).charge_first_time
      @transaction.update_attribute(:state, "accepted")
      #captured_true
      if @transaction.accepted
        start_date = Date.today - (@transaction.frequency.eql?("weekly") ? 7.days : 14.days)
        end_date = Date.today - 1
        Stripe.api_key = ENV['STRIPE_SECRET_KEY']
        stripe_payment = StripePayment.find(StripePayment.last.id)
        charge = Stripe::Charge.retrieve(stripe_payment.stripe_charge_id)
        result = charge.capture
        stripe_payment.update_attributes(capture: true)
        payment_receipt = PaymentReceipt.create(transaction_id: @transaction.id, start_date: start_date, end_date: end_date, tx_price: @transaction.hirer_weekly_amount)
        get :receipt_details, params: {id: @transaction.id, receipt_id: payment_receipt.id}
        expect(response.successful?).to eq(true)
        expect(response.status).to eq(200)
      end
    end
  end

  describe "PATCH accept/:id" do
  	it "check transaction accepted" do 
      get :accept, params: {id: @transaction.id}
      response.should redirect_to(inbox_path(id: @transaction.conversation.id))
	  end
  end

  describe 'decline_request when current user hirer' do 
    it 'create message ater update decline reason' do
      patch :decline_request, params: {id: @transaction.id, reason: "I want to decline now", message_text: "I want not work with yo",:format => "text/html"}
      if response.success?
        patch :decline, params: {id: @transaction.id, message_text: "I want not work with this employee"}
        response.should redirect_to(inbox_path(id: Transaction.last.conversation.id))
      end
    end
  end

  describe "Cancel hiring" do
    it "when hirer cancel the hiring scheduled" do
      # if request.get?
        get :cancel_hiring, params: {id: @transaction.id}
      # if request.patch?
        patch :tell_poster, params: {id: @transaction.id, reason: "I wnat to cancel hiring now"}
      if (response.should redirect_to cancelled_successfully_hirings_path(id: Transaction.last.id))
        get :cancelled_successfully, params: {id: Transaction.last.id}
        expect(response.successful?).to eq(true)
        expect(response.status).to eq(200)
      end
    end
  end

  describe "#cancel" do
    it "#cancel transaction" do
      patch :cancel, params: {id: @transaction.id}
    end 
  end

  describe "#send_details" do
    it "#send_details transaction" do
      patch :send_details, params: {transaction_id: @transaction.id, email: @hirer.email}
      expect(flash[:notice]).to eq("Shared successfully")
    end 
  end

  describe "PATCH hiring#change_hiring" do

    it "when hirer changed hiring schedule" do
      ChargeForListing.new(@transaction.id).charge_first_time
      patch :change_hiring, params: {id: @transaction.id, transaction: {employee_listing_id: @transaction.employee_listing, start_date: Date.today + 1.day, end_date:  3.months.from_now, booking_attributes: {"0"=>{"start_time"=>"05:00", "end_time"=>"13:00"}, "1"=>{"start_time"=>"09:00", "end_time"=>"15:00"}, "2"=>{"start_time"=>"12:00", "end_time"=>"15:00"}, "3"=>{"start_time"=>"09:00", "end_time"=>"19:00"}, "4"=>{"start_time"=>"08:00", "end_time"=>"19:00"}, "5"=>{"start_time"=>"08:00", "end_time"=>"16:00"}, "6"=>{"start_time"=>"", "end_time"=>""}} }}
      @new_transaction = Transaction.last
      if @new_transaction.present?
        FactoryGirl.create(:booking, transaction_id: @new_transaction.id)
        @new_transaction.update_attributes(start_date: Date.today + 2.days, frequency: "weekly")
        patch :change_hiring_confirmation, params: {id: @new_transaction.id, old_id: @transaction.id}
        get :changed_successfully, params: {id: @new_transaction.id, old_id: @transaction.id} if flash[:notice] = 'Card charged successfully.'
        expect(response.successful?).to eq(true)
        expect(response.status).to eq(200)
      end
    end
  end

  describe "#check_slot_availability" do
    it "check availability" do
      @transaction.update_attribute(:state, "accepted")
      @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
      get :check_slot_availability, xhr:true, params: {transaction_id: @transaction.id, listing_id: @employee_listing.id, start: Date.today, end: Date.today + 2.days}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

end
