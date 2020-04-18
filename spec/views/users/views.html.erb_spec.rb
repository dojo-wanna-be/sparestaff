require 'rails_helper'

RSpec.describe "users/views", type: :view do

	def show_all_poster_reviews
    reviews = Review.where(receiver_id: @hirer.id)
    review_by_poster_ids = []
    reviews.each do |review|
      tx = Transaction.find_by(id: review.transaction_id)
      if tx.hirer.eql?(@hirer) && (tx.reviews.count.eql?(2) || tx.end_date + 14.days <= Date.today)
        review_by_poster_ids << review.id
      end
    end
    @reviews_by_poster = Review.where(id: review_by_poster_ids)
  end

  def show_all_hirer_reviews
    reviews = Review.where(receiver_id: @hirer.id)
    review_by_hirer_ids = []
    reviews.each do |review|
      tx = Transaction.find_by(id: review.transaction_id)
      if tx.poster.eql?(@hirer) && (tx.reviews.count.eql?(2) || tx.end_date + 14.days <= Date.today)
        review_by_hirer_ids << review.id
      end
    end
    @reviews_by_hirer = Review.where(id: review_by_hirer_ids)
  end

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
  end

  describe 'users/profile_photo.html.erb' do
    it 'display profile_photo action details' do
      render :template => "users/profile_photo.html.erb", locals: {:@user_profile => User.new, :@current_user => @hirer}
        expect(rendered).to match /Profile Photo/
        expect(rendered).to match /A profile photo about you is important to earn credibility and trust from other users in our community/
    end
  end

  describe 'users/destroy_profile_photo.js.erb' do
    it 'destroy_profile_photo request' do
      render :template => "users/destroy_profile_photo.js.erb", locals: {:@user => @hirer}
        expect(response).to eq("$('.user_image').attr('src', \"http://test.host/assets/no-image-020db5296a797b2972d1a71761303fba2ce6692d45f15b109e682c5c7d9fd019.jpg\")")
    end
  end

  describe 'users/trust_and_verification.html.erb' do
    it 'display trust_and_verification action details' do
      render :template => "users/trust_and_verification.html.erb", locals: {:@current_user => @hirer}
        expect(rendered).to match /You have confirmed your email/
    end
  end


  describe 'users/show.html.erb' do

    it 'display  show action details' do
    	@reviews = Review.where(receiver_id: @hirer.id)
    	@employee_listings = @hirer.employee_listings.paginate(:page => params[:page], :per_page => 2)
      @reviews_by_hirer = show_all_hirer_reviews
      @reviews_by_poster = show_all_poster_reviews
      render :template => "users/show.html.erb", locals: {:@person => @hirer, :@reviews => @reviews, :@employee_listings => @employee_listings, :@reviews_by_hirer => @reviews_by_hirer, :@reviews_by_poster => @reviews_by_poster }
        expect(rendered).to match /test john/
        expect(rendered).to match /April, 2020/
    end
  end

end

