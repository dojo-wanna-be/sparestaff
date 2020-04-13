require 'rails_helper'
require 'stripe_mock'

# Specs in this file have access to a helper object that includes
# the HiringsHelper. For example:
#
# describe HiringsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe HiringsHelper, type: :helper do

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
  	@hirer =  FactoryGirl.create(:user, email: "hirer@gmail.com")
    @poster = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @lister = FactoryGirl.create(:company)
    @poster.update_attributes(company_id: @lister.id, user_type: "owner")
    @hirer.update_attributes(company_id: @lister.id, user_type: "hr")
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
  end

  describe "#transaction_time(@transaction)" do
    it "returns transaction_time" do
      charge_first_time(@transaction.id)
      helper.transaction_time(@transaction).should eql((StripePayment.last.created_at + 7.days).strftime("%eth %b %Y"))
    end
  end

  describe "#transaction_time_day_before(@transaction)" do
    it "returns transaction_time_day_before" do
      charge_first_time(@transaction.id)
      helper.transaction_time_day_before(@transaction).should eql((StripePayment.last.created_at + 7.days - 1.days).strftime("%eth %b %Y"))
    end
  end

end
