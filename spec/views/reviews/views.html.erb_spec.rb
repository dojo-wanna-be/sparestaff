require 'rails_helper'

RSpec.describe "reviews/views", type: :view do

  before(:each) do
    @review = Array.new
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
    2.times do
      @review << FactoryGirl.create(:review, sender_id: @poster.id, receiver_id: @hirer.id, listing_id: @employee_listing.id, transaction_id:   @transaction.id)
    end
    @reviews = Review.new
  end
  

  describe 'reviews/new.html.erb' do
    it 'display all reviews' do
      render :template => "reviews/index.html.erb", locals: {:@reviews => @review}
        expect(rendered).to match /April, 2020/
        expect(rendered).to match /Past Reviews About You/
        expect(rendered).to match /Past Reviews You've Written/
    end
  end

  describe 'reviews/new.html.erb' do
	  it 'display reviews, if current user in hirer' do
	    render :template => "reviews/new.html.erb", locals: {:@review => @reviews, :@transaction => @transaction}
	      expect(rendered).to match /Friendliness/
	      expect(rendered).to match /Was the employee friendly?/
   	    expect(rendered).to match /Punctuality/
        expect(rendered).to match /Was the employee always on-time?/
        expect(rendered).to match /Professionalism/
        expect(rendered).to match /Overall attitude, accountability, teamwork, behaviour, presentability/
	  end

    it 'display reviews, if current user in hirer' do
      @poster.confirmed_at = Time.zone.now
      @poster.save
      sign_in @poster
      render :template => "reviews/new.html.erb", locals: {:@review => @reviews, :@transaction => @transaction, :current_user => @poster}
        expect(rendered).to match /Workplace Environment/
        expect(rendered).to match /Is it a good place to work at?/
        expect(rendered).to match /Suitability/
        expect(rendered).to match /Was the work suitable for the employee?/
        expect(rendered).to match /Communication/
        expect(rendered).to match /How clearly did the hirer communicate their plans, questions, concerns?/
    end
	end  

   describe 'reviews/step_2.html.erb' do
    it 'step_2 of reviews' do
      render :template => "reviews/step_2.html.erb", locals: { :@review => @review.first, :@transaction => @transaction}
        expect(rendered).to match /Is there anything you would like to tell Spare Staff about your experience hiring james clark/
    end
  end

  describe 'reviews/last_step.html.erb' do
    it 'last_step of reviews' do
      render :template => "reviews/last_step.html.erb", locals: {:@transaction => @transaction}
        expect(rendered).to match /Thank you for reviewing/
    end
  end

end
