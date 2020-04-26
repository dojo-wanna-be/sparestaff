class ReviewsController < ApplicationController
  def new
    @transaction = Transaction.find_by(id: params[:tx_id])
    @review = Review.new
  end

  def index
    @reviews = Review.all
  end

  def create
    @reviews = Review.all
    tx = Transaction.find_by(id: params[:review][:transaction_id])
    @review = Review.new(reviews_params)
    already_create_review = @reviews.where(transaction_id: @review.transaction_id, sender_id: current_user.id)
    if (already_create_review).blank?
      if @review.save
        if tx.poster.eql?(current_user)
          @review.update(sender_id: current_user.id, receiver_id: tx.hirer.id, listing_id: tx.employee_listing.id)
        else
          @review.update(sender_id: current_user.id, receiver_id: tx.poster.id, listing_id: tx.employee_listing.id)
          tx.employee_listing.update(rating_count: listing_star_rating(tx.employee_listing.id).round(2))
        end
        redirect_to step_2_reviews_path(id: @review.id)
      else
        render :new
      end
    else
      redirect_to step_2_reviews_path(id: already_create_review.last.id)
    end
  end

  def step_2
    @review = Review.find_by(id: params[:id])
    @transaction = Transaction.find_by(id: @review.transaction_id)
  end

  def update
    @review = Review.find_by(id: params[:id])
    @review.update_column(:spare_staff_experience, params[:review][:spare_staff_experience])
    redirect_to last_step_reviews_path(id: @review.transaction_id)
  end

  def last_step
    @transaction = Transaction.find_by(id: params[:id])
  end

  def profile_photo
    @current_user = current_user
  end

  private
  def reviews_params
    params.require(:review).permit!
  end
end
