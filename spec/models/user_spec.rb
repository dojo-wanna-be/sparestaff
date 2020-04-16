require 'rails_helper'

RSpec.describe User, type: :model do

  before(:each) do
    @user = FactoryGirl.build(:user, email: "testgrip@gmail.com")
    @lister = FactoryGirl.create(:company)
    @user.update_attributes(company_id: @lister.id, user_type: "owner")
  end

  it "is valid with valid attributes" do
    expect(@user).to be_valid
  end

  context "Associations" do
	  it { should belong_to(:company)}
	  it { should have_many(:employee_listings).dependent(:destroy) }
	  it { should have_many(:conversations).class_name('Conversation') }
	  it { should have_many(:messages).class_name('Message') }
	  it { should have_one(:notification_setting)}
	  it { should have_one(:stripe_info)}
	  it {should accept_nested_attributes_for(:company)}
	end

  context "Enum" do
    it { should define_enum_for(:user_type) }
  end
  
  it "#active_for_authentication?" do
    expect(@user.active_for_authentication?).to eq(true)
  end

  it "#inactive_message" do
    expect(@user.inactive_message).to eq("Sorry, Your account is suspended. Please contact sparestaff support team.")
  end

  it "#is_individual?" do
    expect(@user.is_individual?).to eq(false)
  end

  it "#is_owner?" do
    expect(@user.is_owner?).to eq(true)
  end

  it "#is_hr?" do
    expect(@user.is_hr?).to eq(false)
  end
  it "#name" do
    expect(@user.name).to eq("test john")
  end
end
