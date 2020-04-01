require 'rails_helper'

RSpec.describe Company, type: :model do
 before(:each) do
    @lister = FactoryGirl.create(:company)
  end

  it "is valid with valid attributes" do
    expect(@lister).to be_valid
  end
  
  it "is not valid without address" do
  	@lister.update_attribute(:address_2, nil)
  	expect(@lister.address_2).to be_falsey
  end

   it "is not valid without city" do
  	@lister.update_attribute(:city, nil)
  	expect(@lister.city).to be_falsey
  end

   it "is not valid without postal code" do
  	@lister.update_attribute(:post_code, nil)
  	expect(@lister.post_code).to be_falsey
  end

  describe "Association" do 
    it { should have_many(:users)}
    it { should have_many(:employee_listings)}
  end

end
