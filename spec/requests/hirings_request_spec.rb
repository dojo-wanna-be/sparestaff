require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe HiringsController, type: :controller do
  
  def find_or_create_conversation
    conversation = Conversation.between(controller.current_user.id, @transaction.poster_id, @transaction.id)
    if conversation.present?
      conversation.first
    else
       Conversation.create!( receiver_id: @transaction.poster_id,
          sender_id: controller.current_user.id,
          employee_listing_id: @transaction.employee_listing_id,
          transaction_id: @transaction.id
        )
    end
  end

  def create_message
    conversation = find_or_create_conversation
    message = conversation.messages.create(content: "Hiring has been declined by Hirer", sender_id: controller.current_user.id)
  end
    
   
  before(:each) do
    @poster = FactoryGirl.create(:user, email: "poster123@gmail.com")
  	@hirer =  FactoryGirl.create(:user, email: "sparestaffhirer@gmail.com")
    @hirer.confirmed_at = Time.zone.now
    @hirer.save
    sign_in @hirer
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
    @booking = FactoryGirl.create(:booking, transaction_id: @transaction.id)
  end

  describe "GET #index" do

	  it "has a 200 status code" do
	     get :index
       expect(response.status).to eq(200)
       expect(response.success?).to eq(true)
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
      HiringMailer.employee_hire_confirmation_email_to_poster(@employee_listing, @poster, @transaction).deliver_later!	     
		  }.to have_enqueued_job.on_queue('mailers')
  		mail = ActionMailer::Base.deliveries.first
  		expect(mail.to[0]).to eq @poster.email
		end

		it 'if transaction accepted mail send to hirer' do
		  ActiveJob::Base.queue_adapter = :test
		  expect {
      HiringMailer.employee_hire_confirmation_email_to_hirer(@employee_listing, @hirer, @transaction).deliver_later!	     
		  }.to have_enqueued_job.on_queue('mailers')
  		mail = ActionMailer::Base.deliveries.last
  		expect(mail.to[0]).to eq (@hirer.email)
		end
  end

  describe 'decline_request when current user hirer' do 
    it 'create message ater update decline reason' do
      @transaction.update_attribute(:reason, "Hirer decline hiring request")
      create_message
      expect(Message.last.content).to eq("Hiring has been declined by Hirer")
      expect(response.success?).to eq(true)
    end

    it "Ater successfully submit decline , it goes to Hiring#decline/:id" do
    	@transaction.update_attribute(:state, "rejected")
      message = create_message
    # Mail goes to poster
      ActiveJob::Base.queue_adapter = :test
		  expect {
      HiringMailer.employee_hire_declined_email_to_Poster(@employee_listing, @poster, @transaction, message).deliver_later!	     
		  }.to have_enqueued_job.on_queue('mailers')
  		mail = ActionMailer::Base.deliveries.first
  		expect(mail.to[0]).to eq @poster.email

  	#Mail goes to hirer
  	  ActiveJob::Base.queue_adapter = :test
		  expect {
      HiringMailer.employee_hire_declined_email_to_Hirer(@employee_listing, @hirer, @transaction, message).deliver_later!	     
		  }.to have_enqueued_job.on_queue('mailers')
  		mail = ActionMailer::Base.deliveries.last
  		expect(mail.to[0]).to eq @hirer.email
    end

  end

  describe "Hirer cancelled hiring" do 
 		
 		it "when hirer cancel the hiring" do
     patch :tell_poster, params: {id: @transaction.id}
	    if expect(request.patch?).to eq(true)
        @transaction.update_attributes(reason: "I want to cancel hiring now", cancelled_by: "hirer", state: "cancelled", cancelled_at: Date.today)
        message = create_message
        expect(message.present?).to eq(true)
      
        #Mail goes to poster
	        ActiveJob::Base.queue_adapter = :test
				  expect {
          TransactionMailer.hiring_cancelled_email_to_poster(@employee_listing, @employee_listing.poster, @transaction, controller.current_user).deliver_later!	     
				  }.to have_enqueued_job.on_queue('mailers')
		  		mail = ActionMailer::Base.deliveries.first
		  		expect(mail.to[0]).to eq @poster.email 

		  	#Mail goes to hirer
		  	  ActiveJob::Base.queue_adapter = :test
				  expect {
          TransactionMailer.hiring_cancelled_email_to_hirer(@employee_listing, controller.current_user, @transaction).deliver_later!	     
				  }.to have_enqueued_job.on_queue('mailers')
		  		mail = ActionMailer::Base.deliveries.last
		  		expect(mail.to[0]).to eq @hirer.email

        #Mail goes to poster for review
          ActiveJob::Base.queue_adapter = :test
          expect {
          TransactionMailer.write_review_mail_to_poster(@transaction).deliver_later!      
          }.to have_enqueued_job.on_queue('mailers')
          mail = ActionMailer::Base.deliveries.first
          expect(mail.to[0]).to eq @poster.email

        #Mail goes to hirer for review
          ActiveJob::Base.queue_adapter = :test
          expect {
          TransactionMailer.write_review_mail_to_hirer(@transaction).deliver_later!       
          }.to have_enqueued_job.on_queue('mailers')
          mail = ActionMailer::Base.deliveries.last
          expect(mail.to[0]).to eq @hirer.email      
	    end
 		end

    it "Ater successfully cancel it goes to hiring#cancelled_successfully" do
      get :cancelled_successfully, params: {id: @transaction.id, current_user: controller.current_user}
      expect(response.success?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  # describe "PATCH hiring#change_hiring" do
  #   it "when hirer changed hiring schedule" do
  #     patch :change_hiring, params: {id: @transaction.id, transaction: {employee_listing_id: @transaction.employee_listing, start_date: Date.today, end_date:  3.months.from_now} } 
  #   end
  # end

end
