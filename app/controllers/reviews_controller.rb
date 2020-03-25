class ReviewsController < ApplicationController

	def new
		@transaction = Transaction.find_by(id: params[:tx_id])
		@review = Review.new	
	end

	def index
		@reviews = Review.all
	end

	def create
		tx = Transaction.find_by(id: params[:review][:transaction_id])
		@review = Review.new(reviews_params)
		if @review.save
			if tx.poster.eql?(current_user)
				@review.update(sender_id: current_user.id, receiver_id: tx.hirer.id, listing_id: tx.employee_listing.id)
			else
				@review.update(sender_id: current_user.id, receiver_id: tx.poster.id, listing_id: tx.employee_listing.id)
			end
			redirect_to step_2_reviews_path(id: @review.id)
		else
			render :new
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

	private
	def reviews_params
		params.require(:review).permit!
	end
end
