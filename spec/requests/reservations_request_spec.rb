require 'rails_helper'
include Warden::Test::Helpers
include ActiveJob::TestHelper

RSpec.describe ReservationsController, type: :controller do

  def find_or_create_conversation
    conversation = Conversation.between(controller.current_user.id, @transaction.hirer_id, @transaction.id)
    if conversation.present?
      conversation.first
    else
       Conversation.create!( receiver_id: @transaction.hirer_id,
                            sender_id: controller.current_user.id,
                            employee_listing_id: @transaction.employee_listing_id,
                            transaction_id: @transaction.id
                          )
    end
  end


  def create_message
    conversation = find_or_create_conversation
    # conversation.update_attributes(read: false)
    message = conversation.messages.create(content: "Poster message to hirer", sender_id: controller.current_user.id)
  end
   
  before(:each) do
  	@hirer =  FactoryGirl.create(:user, email: "hireremail@sparestaff.com")
    @poster = FactoryGirl.create(:user, email: "poster@sparestaff.com")
    @poster.confirmed_at = Time.zone.now
    @poster.save
    sign_in @poster
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
  end

  describe "GET #index" do

	  it "has a 200 status code" do
	     get :index
       expect(response.status).to eq(200)
    end
  end
  
  describe "PATCH accept/:id" do
  	it "check transaction accepted" do 
      @transaction.update_attributes(state: "accepted")
	    if(@transaction.old_transaction.present?)
	      old_transaction = Transaction.find(@transaction.old_transaction)
	      old_transaction.update_attributes(state: "completed", status: false)
	    end
	  end
    
    it 'if transaction accepted mail send to poster' do
		  ActiveJob::Base.queue_adapter = :test
		  expect {
		    ReservationMailer.employee_hire_confirmation_email_to_poster(@employee_listing, @poster, @transaction).deliver_later!	     
		  }.to have_enqueued_job.on_queue('mailers')
  		mail = ActionMailer::Base.deliveries.last
  		expect(mail.to[0]).to eq @poster.email
		end

		it 'if transaction accepted mail send to hirer' do
		  ActiveJob::Base.queue_adapter = :test
		  expect {
      ReservationMailer.employee_hire_confirmation_email_to_hirer(@employee_listing, @hirer, @transaction).deliver_later!	     
		  }.to have_enqueued_job.on_queue('mailers')
  		mail = ActionMailer::Base.deliveries.first
  		expect(mail.to[0]).to eq (@hirer.email)
		end
  end


  describe 'decline_request when current user poster' do 
    it 'create message ater update decline reason' do
      @transaction.update_attribute(:reason, "Poster decline hirer request")
      create_message
      expect(Message.last.content).to eq("Poster message to hirer")
      expect(response.success?).to eq(true)
    end
  end

end

