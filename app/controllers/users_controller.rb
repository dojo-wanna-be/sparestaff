class UsersController < ApplicationController
  before_action :find_user, only: [:show,
                                    :show_all_listings,
                                    :show_all_poster_reviews,
                                    :show_all_hirer_reviews]
  def profile_photo
    @current_user = current_user
  end

  def trust_and_verification
  end

  def show
    @reviews = Review.where(receiver_id: @person.id)
    @employee_listings = @person.employee_listings.paginate(:page => params[:page], :per_page => 2)
    @reviews_by_hirer = show_all_hirer_reviews
    @reviews_by_poster = show_all_poster_reviews
  end

  def show_all_listings
    @employee_listings = @person.employee_listings
  end

  def show_all_poster_reviews
    reviews = Review.where(receiver_id: @person.id)
    review_by_poster_ids = []
    reviews.each do |review|
      tx = Transaction.find_by(id: review.transaction_id)
      if tx.hirer.eql?(@person) && (tx.reviews.count.eql?(2) || tx.end_date + 14.days <= Date.today)
        review_by_poster_ids << review.id
      end
    end
    @reviews_by_poster = Review.where(id: review_by_poster_ids)
  end

  def show_all_hirer_reviews
    reviews = Review.where(receiver_id: @person.id)
    review_by_hirer_ids = []
    reviews.each do |review|
      tx = Transaction.find_by(id: review.transaction_id)
      if tx.poster.eql?(@person) && (tx.reviews.count.eql?(2) || tx.end_date + 14.days <= Date.today)
        review_by_hirer_ids << review.id
      end
    end
    @reviews_by_hirer = Review.where(id: review_by_hirer_ids)
  end

  def find_user
    @person = User.find_by(id: params[:id])
  end
end
