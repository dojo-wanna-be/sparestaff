require 'rails_helper'

RSpec.describe EmployeeListing, type: :model do
  
  before(:each) do
    @lister = FactoryGirl.create(:company)
    @employee_listing = FactoryGirl.build(:employee_listing, lister_id: @lister.id)
  end

  it "is valid with valid attributes" do
    expect(@employee_listing).to be_valid
  end

  describe "Association" do
  	it { should belong_to(:lister)}
  	it { should belong_to(:classification)}
	  it { should have_many(:employee_listing_languages)}
	  it { should have_many(:languages).through(:employee_listing_languages) }
	  it { should have_many(:listing_availabilities)}
	  it { should have_many(:employee_listing_slots)}
	  it { should have_many(:slots).through(:employee_listing_slots)}
	  it { should have_many(:relevant_documents)}
	  it { should have_many(:employee_skills)}
	  it { should have_many(:transactions)}
	  it { should have_many(:bookings).through(:transactions)}
	  it { should have_many(:conversations).dependent(:destroy)}
	  it { should have_many(:messages).through(:conversations)}
  end
  
  describe "#listing_visibility" do
    let(:lister) {FactoryGirl.create(:company)}
    let(:employee_listing) { FactoryGirl.create(:employee_listing, lister_id: lister.id) }

     it "is visible, if employee_listing is  published" do
        employee_listing.update_attribute(:published, true)
     	  expect(employee_listing.published).to be_truthy
     end

     it "is visible, if employee_listing is deactivate false" do
        expect(employee_listing.deactivated).to be_falsey
     end

      it "is not visible, if employee_listing is published false" do
        employee_listing.update_attribute(:published, false)
        expect(employee_listing.published).to be_falsey
      end

      it "use method for display first and last name of listing" do
        emp_name = employee_listing.name
        expect(emp_name).to eq("james clark")
      end
  end

end
