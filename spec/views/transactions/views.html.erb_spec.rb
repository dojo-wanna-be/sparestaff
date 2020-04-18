require 'rails_helper'

RSpec.describe "transactions/views", type: :view do

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
  end

  describe 'transactions/initialized.html.erb' do
    it 'display initialized transaction details' do
      render :template => "transactions/initialized.html.erb", locals: {:@transaction => @transaction, :@employee_listing => @transaction.employee_listing, :@company => @lister, :@slot => "" }
        expect(rendered).to match /Company name/
        expect(rendered).to match /test game/
        expect(rendered).to match /ACN/
        expect(rendered).to match /8978/
        expect(rendered).to match /Address line 1/
        expect(rendered).to match /Treasury Casino and Hotel Brisban, William Street/
    end
  end

  describe 'transactions/payment.html.erb' do
    it 'display payment transaction details' do
      render :template => "transactions/payment.html.erb", locals: {:@transaction => @transaction, :@employee_listing => @transaction.employee_listing, :@company => @lister, :@slot => "" }
        expect(rendered).to match /Confirm and payment/
        expect(rendered).to match /You won't be charged until test john has accepted your hiring request/
    end
  end


  describe 'transactions/request_sent_successfully.html.erb' do
    it 'display request detail of hiring' do
      render :template => "transactions/request_sent_successfully.html.erb", locals: {:@transaction => @transaction, :@employee_listing => @transaction.employee_listing, :@company => @lister, :@slot => "" }
        expect(rendered).to match /Hiring Request Sent/
        expect(rendered).to match /This is not a confirmed hiring - at least not yet. You'll get a response within 48 hours./
        expect(rendered).to match /james clark/
        expect(rendered).to match /test bugs/
    end
  end

  describe 'transactions/right_listing_details.html.erb' do
    it 'display request detail of hiring' do
      render :partial => "transactions/right_listing_details", locals: {:@transaction => @transaction, :@employee_listing => @transaction.employee_listing, :@company => @lister, :@slot => "" }
        expect(rendered).to match /james clark/
        expect(rendered).to match /test bugs/
    end
  end

end

