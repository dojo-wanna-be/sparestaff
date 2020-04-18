require 'rails_helper'

RSpec.describe ReservationsController, type: :controller do
   
  before(:each) do
    @poster = FactoryGirl.create(:user)
  	@hirer =  FactoryGirl.create(:user)
    @poster.confirmed_at = Time.zone.now
    @poster.save
    sign_in @poster
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "hr")
    @hirer.update_attributes(company_id: @lister.id, user_type: "owner")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
  end

  describe "GET #index" do

	  it "has a 200 status code" do
	     get :index
       expect(response.successful?).to eq(true)
       expect(response.status).to eq(200)
    end
  end

  describe "GET #show" do

    it "has a 200 status code" do
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

  describe "PATCH #accept" do

  	it "check transaction accepted" do
      get :accept, params: {id: @transaction.id}
      response.should redirect_to(inbox_path(id: @transaction.conversation.id))      
    end
  end


  describe 'decline_request when current user poster' do 
    it 'create message ater update decline reason' do
      patch :decline_request, params: {id: @transaction.id, reason: "I want to decline now", message_text: "I want not work with yo",:format => "text/html"}
      if response.success?
        patch :decline, params: {id: @transaction.id, message_text: "I want not work with this employee"}
        response.should redirect_to(inbox_path(id: Transaction.last.conversation.id))
      end
    end
  end

  describe "PATCH hiring#change_reservation" do

    it "when hirer changed hiring schedule" do
      patch :change_reservation, params: {id: @transaction.id, transaction: {employee_listing_id: @transaction.employee_listing, start_date: Date.today + 1.day, end_date:  3.months.from_now, booking_attributes: {"0"=>{"start_time"=>"05:00", "end_time"=>"13:00"}, "1"=>{"start_time"=>"09:00", "end_time"=>"15:00"}, "2"=>{"start_time"=>"12:00", "end_time"=>"15:00"}, "3"=>{"start_time"=>"09:00", "end_time"=>"19:00"}, "4"=>{"start_time"=>"08:00", "end_time"=>"19:00"}, "5"=>{"start_time"=>"08:00", "end_time"=>"16:00"}, "6"=>{"start_time"=>"", "end_time"=>""}} }}
      @new_transaction = Transaction.last
      if @new_transaction.present?
        get :change_reservation_confirmation, params: {id: @new_transaction.id, old_id: @transaction.id}
        redirect_to(changed_successfully_reservation_path(params: {id: @new_transaction.id, old_id: @transaction.id}))
        get :changed_successfully, params: {id: @new_transaction.id, old_id: @transaction.id}
        expect(response.successful?).to eq(true)
        expect(response.status).to eq(200)
      end
    end
  end

  describe "Cancel reservations" do
    it "when poster cancel reservations" do
      #if request.get?
      get :cancel_reservation, params: {id: @transaction.id}

      #if request.patch?
      patch :cancel_reservation, params: {id: @transaction.id, reason: "I want to cancel now"}
      response.should redirect_to (tell_hirer_reservation_path(id: @transaction.id))

      #if reason present?
      patch :tell_hirer, params: {id: @transaction.id, reason: "I wnat to cancel hiring now"}
      if (response.should redirect_to (cancelled_successfully_reservations_path(id: Transaction.last.id)))
        get :cancelled_successfully, params: {id: Transaction.last.id}
        expect(response.successful?).to eq(true)
        expect(response.status).to eq(200)
      end
      #if reason is not present?
      patch :tell_hirer, params: {id: @transaction.id}
      if (response.should redirect_to (cancelled_successfully_reservations_path(id: Transaction.last.id)))
        get :cancelled_successfully, params: {id: Transaction.last.id}
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
  
  describe "reservations_view_invoice_list" do
    it "reservation list" do
      get :reservations_view_invoice_list, params: {id: @transaction.id}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

end

