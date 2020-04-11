require 'rails_helper'

RSpec.describe User, type: :model do

  before(:each) do
    @user = FactoryGirl.build(:user, email: "testgrip@gmail.com")
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

end
