require 'rails_helper'
require 'stripe_mock'
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

  def charge_first_time(transaction_id)
    transaction = Transaction.find(transaction_id)
    stripe_payment = create_charge(transaction, 'first_time')
    # if transaction.frequency == 'weekly'
    #   PaymentWorker.perform_in((transaction.start_date + 1.week).to_datetime, @transaction_id, "weekly") if Date.today + 6.days < transaction.end_date
    # elsif transaction.frequency == 'fortnight'
    #   PaymentWorker.perform_in((transaction.start_date + 2.weeks).to_datetime, @transaction_id, "fortnight") if Date.today + 13.days < transaction.end_date
    # end 
    # if transaction.frequency == 'weekly'
    #   diff = (transaction.end_date - Date.today).to_i > 6 ? 7 : (transaction.end_date - Date.today).to_i + 1
    #   StripeCaptureWorker.perform_in((transaction.start_date + diff.days).to_datetime, @transaction_id, stripe_payment.id)
    # elsif transaction.frequency == 'fortnight'
    #   diff = (transaction.end_date - Date.today).to_i > 13 ? 14 : (transaction.end_date - Date.today).to_i + 1
    #   StripeCaptureWorker.perform_in((transaction.start_date + diff.days).to_datetime, @transaction_id, stripe_payment.id)
    # end
  end

  def create_charge(transaction, from=nil)
    stripe_helper =  StripeMock.create_test_helper
    hirer = transaction.hirer
    poster = transaction.poster
    Stripe.api_key = ENV['STRIPE_SECRET_KEY']
    cutsomer_id = Stripe::Customer.create({
      email: hirer.email,
      source: stripe_helper.generate_card_token
    }).id
    amount = total_amount(transaction, from)
    amount_with_hirer_service_fee = amount + transaction.service_fee - transaction.tax_withholding_amount
    fee = poster_service_fee(amount - transaction.tax_withholding_amount)
    poster_fee = amount - transaction.tax_withholding_amount - fee
    charge = Stripe::Charge.create(
      customer:  cutsomer_id,
      amount:    (amount_with_hirer_service_fee * 100).to_i,
      description: description(transaction),
      currency:    'aud',
      capture: false,
      destination: {
        account: "acct_1GQpmyGvKuGbFYqf",
        amount: (poster_fee*100).to_i
      }
    )
    StripePayment.create!(transaction_id: transaction.id, amount: amount, poster_service_fee: poster_fee, stripe_charge_id: charge.id, status: charge.status)
      # Some other error; display an error message.
  end

  def total_amount(transaction, from = nil)
    if transaction.frequency == 'weekly'
      if(from.present?)
        diff = (transaction.end_date - transaction.start_date).to_i > 6 ? 6 : (transaction.end_date - Date.today).to_i + 1
        calculate_amount(transaction, transaction.start_date, diff)
      else
        begining_day = get_beginning_day(transaction)
        diff = (transaction.end_date - Date.today).to_i > 6 ? 6 : (transaction.end_date - Date.today).to_i + 1
        calculate_amount(transaction, begining_day, diff)
      end
    elsif transaction.frequency == 'fortnight'
      if(from.present?)
        diff = (transaction.end_date - transaction.start_date).to_i > 13 ? 13 : (transaction.end_date - Date.today).to_i + 1
        calculate_amount(transaction, transaction.start_date, diff)
      else
        begining_day = get_beginning_day(transaction)
        diff = (transaction.end_date - Date.today).to_i > 13 ? 13 : (transaction.end_date - Date.today).to_i + 1
        calculate_amount(transaction, begining_day, diff)
      end
    end
  end

  def poster_service_fee amount
      amount * 0.1
  end
  
  def description(transaction)
    "#{transaction.poster.name.titleize} charged #{transaction.hirer.company.name} for #{transaction.start_date.strftime('%-m/%-d')}"
  end

  def calculate_amount(transaction, begining_day, diff) 
    weekday_hours = 0
    weekend_hours = 0
    transaction.bookings.where(booking_date: (begining_day..begining_day + diff).to_a).each do |booking|
      if ["monday", "tuesday", "wednesday", "thursday", "friday"].include?(booking.day)
        weekday_hours += (booking.end_time - booking.start_time)/3600
      elsif ["sunday", "saturday"].include?(booking.day)
        weekend_hours += (booking.end_time - booking.start_time)/3600
      end
    end
    (weekday_hours * transaction.employee_listing.weekday_price.to_f) + (weekend_hours * transaction.employee_listing.weekend_price.to_f)
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

  describe "GET show/:id" do
    it "show hirings" do
      get :show, params: {id: @transaction.id}
      expect(response.success?).to eq(true)
      expect(response.status).to eq(200)
    end
  end

  describe "GET change_or_cancel/:id" do
    it "change_or_cancel the hiring" do
      get :change_or_cancel, params: {id: @transaction.id}
      expect(response.success?).to eq(true)
      expect(response.status).to eq(200)
    end
  end
  
  describe "GET get_receipt/:id" do
    it "get_receipt of hiring" do
      get :get_receipt, params: {id: @transaction.id}
      expect(response.success?).to eq(true)
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

    it "create charge after accept transactio" do
      charge_first_time(@transaction.id)
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

  describe "PATCH hiring#change_hiring" do

    it "when hirer changed hiring schedule" do
      charge_first_time(@transaction.id)
      patch :change_hiring, params: {id: @transaction.id, transaction: {employee_listing_id: @transaction.employee_listing, start_date: Date.today + 1.day, end_date:  3.months.from_now, booking_attributes: {"0"=>{"start_time"=>"05:00", "end_time"=>"13:00"}, "1"=>{"start_time"=>"09:00", "end_time"=>"15:00"}, "2"=>{"start_time"=>"12:00", "end_time"=>"15:00"}, "3"=>{"start_time"=>"09:00", "end_time"=>"19:00"}, "4"=>{"start_time"=>"08:00", "end_time"=>"19:00"}, "5"=>{"start_time"=>"08:00", "end_time"=>"16:00"}, "6"=>{"start_time"=>"", "end_time"=>""}} }}
      @new_transaction = Transaction.last
      if @new_transaction.present?
        get :change_hiring_confirmation, params: {id: @new_transaction.id, old_id: @new_transaction.id - 1}
      expect(response.success?).to eq(true)
      expect(response.success?).to eq(true)
      end
    end
  end

end
