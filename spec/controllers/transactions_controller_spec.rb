require 'rails_helper'
require 'stripe_mock'
include ActiveJob::TestHelper

RSpec.describe TransactionsController, type: :controller do

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
  end

  describe "POST create/:id" do

  	it "when transaction has create" do
  		post :create, params: {transaction: {employee_listing_id: @employee_listing.id, start_date: Date.today + 1.day, end_date:  3.months.from_now, booking_attributes: {"0"=>{"start_time"=>"05:00", "end_time"=>"13:00"}, "1"=>{"start_time"=>"09:00", "end_time"=>"15:00"}, "2"=>{"start_time"=>"12:00", "end_time"=>"15:00"}, "3"=>{"start_time"=>"09:00", "end_time"=>"19:00"}, "4"=>{"start_time"=>"08:00", "end_time"=>"19:00"}, "5"=>{"start_time"=>"08:00", "end_time"=>"16:00"}, "6"=>{"start_time"=>"", "end_time"=>""}} }}
  		@transaction = Transaction.last
  		if @transaction.present?
  		  # It goes to initialized action

          # request.get?
            get :initialized, params: {id: @transaction.id}

          # request.patch?
	  			  patch :initialized, params: {id: @transaction.id, message_text: "test", company_id: @lister.id, company: {"name"=>"test game", "acn"=>"8978", "address_1"=>"Treasury Casino and Hotel Brisban, William Street", "address_2"=>"Treasury Casino and Hotel Brisban, William Street", "city"=>"Brisbane City QLD", "state"=>"NSW", "post_code"=>"", "country"=>"Australia"}, transaction: {probationary_period: "1"} }

	  		# after initialized it goes to payment action
 					get :payment, params: {id: @transaction.id}

 				# after payment action it goes to request_payment
          stripe_helper =  StripeMock.create_test_helper
          patch :request_payment, params: {id: @transaction.id, stripe_token: stripe_helper.generate_card_token}

				# after this it goes to request_sent_successfully
				  get :request_sent_successfully, params: {id: @transaction.id}
				  expect(response.successful?).to eq(true)
				  expect(response.status).to eq(200) 
  		end
  	end

  end


  describe "#check_slot_availability" do
    it "check availability" do
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id, state: "accepted" )
      @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
      get :check_slot_availability, xhr:true, params: {transaction_id: @transaction.id, listing_id: @employee_listing.id, start: Date.today, end: Date.today + 2.days}
      expect(response.successful?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  describe "#ensure_company_owner" do
    it "check private method #ensure_company_owner" do
     @hirer.update_attributes(company_id: @lister.id, user_type: "")
     post :create, params: {transaction: {employee_listing: @employee_listing.id}}
     expect(flash[:error]).to eq("You are not authorised to hire an employee")
    end
  end

end