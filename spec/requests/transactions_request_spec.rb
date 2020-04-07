require 'rails_helper'
require 'stripe_mock'
include ActiveJob::TestHelper

RSpec.describe TransactionsController, type: :controller do


	def find_or_create_conversation
    conversation = Conversation.between(@transaction.hirer_id, @transaction.poster_id, @transaction.id)
    if conversation.present?
      conversation.first
    else
      Conversation.create!( receiver_id: @transaction.poster_id,
                            sender_id: @transaction.hirer_id,
                            employee_listing_id: @employee_listing.id,
                            transaction_id: @transaction.id
                          )
    end
  end

 	before(:each) do
    @poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
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
	  			patch :initialized, params: {id: @transaction.id, message_text: "test", company_id: @lister.id, company: {"name"=>"test game", "acn"=>"8978", "address_1"=>"Treasury Casino and Hotel Brisban, William Street", "address_2"=>"Treasury Casino and Hotel Brisban, William Street", "city"=>"Brisbane City QLD", "state"=>"NSW", "post_code"=>"", "country"=>"Australia"}, transaction: {probationary_period: "1"} }

	  		# after initialized it goes to payment action
 					get :payment, params: {id: @transaction.id}

 				# after payment action it goes to request_payment	
 				  stripe_helper =  StripeMock.create_test_helper
  			  	customer = Stripe::Customer.create({
				      email: @transaction.hirer.email,
				      source: stripe_helper.generate_card_token
				    })
				  @transaction.update_attribute(:state, "created")
				  message = find_or_create_conversation.messages.last

				# after this it goes to request_sent_successfully
				  get :request_sent_successfully, params: {id: @transaction.id}
				  expect(response.success?).to eq(true)
				  expect(response.status).to eq(200) 
  		end
  	end

  end

end