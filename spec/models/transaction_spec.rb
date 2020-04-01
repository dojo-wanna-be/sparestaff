require 'rails_helper'

RSpec.describe Transaction, type: :model do
  before(:each) do
  	@hirer =  FactoryGirl.create(:user)
    @poster = FactoryGirl.create(:user, email: "receiver@sparestaff.com")
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.create(:employee_listing, lister_id: @lister.id)
    @transaction = FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )
  end

  it "is valid with valid attributes" do
    expect(@transaction).to be_valid
  end
  
  describe "Association" do
  	it { should belong_to(:employee_listing)}
  	it { should belong_to(:hirer).class_name('User')}
  	it { should belong_to(:poster).class_name('User')}
	  it { should have_many(:bookings).dependent(:destroy)}
	  it { should have_one(:conversation)}
	  it { should have_many(:stripe_payments)}
	  it { should have_one(:address)}
	  it { should have_many(:payment_receipts)}
	  it { should have_many(:reviews)}
  end

  describe "Enum" do
  	it "Test Enum"do
	    should define_enum_for(:frequency).with(weekly: 0, fortnight: 1)
	    should define_enum_for(:state).with(initialized: 0, created: 1, accepted: 2, rejected: 3, cancelled: 4, expired: 5, completed: 6 )
	    should define_enum_for(:cancelled_by).with(hirer: 0, poster: 1)
    end
  end

   
  describe "#Transaction_calculations" do
  	let(:hirer) {FactoryGirl.create(:user)}
    let(:poster) {FactoryGirl.create(:user, email: "receiver@sparestaff.com")}
    let(:lister)  {FactoryGirl.create(:company)}
    let(:employee_listing) {FactoryGirl.create(:employee_listing, lister_id: @lister.id)}
    let(:transaction) {FactoryGirl.create(:transaction, employee_listing_id: @employee_listing.id, hirer_id: @hirer.id, poster_id: @poster.id )}

  	it "calculate service fee, when is_withholding_tax present" do 
      expect(transaction.service_fee).to be_positive
  	end

    it "calculate total_service_fee" do 
      expect(transaction.total_service_fee).to be_positive
    end

    it "calculate poster_service_fee" do 
      expect(transaction.poster_service_fee).to be_positive
    end

    it "calculate poster_total_service_fee" do 
      expect(transaction.poster_total_service_fee).to be_positive
    end

    it "calculate remaining_tax_withholding" do
      expect(transaction.remaining_tax_withholding(transaction.amount)).to be >= 0
    end

    it "total_tax_withholding" do 
      expect(transaction.total_tax_withholding).to be >=0
    end
    
    it "hirer_weekly_amount" do
    	expect(transaction.hirer_weekly_amount).to be >=0
    end

    it "poster_weekly_amount" do
    	expect(transaction.poster_weekly_amount).to be >=0
    end
  end

end
