class Admin::HiringsController < Admin::AdminBaseController
  skip_before_action :verify_authenticity_token, only: :profile_photo
  before_action :find_user, only: [:show,
                                    :show_all_listings,
                                    :show_all_poster_reviews,
                                    :show_all_hirer_reviews]

  def show
    @reviews = Review.where(receiver_id: @person.id)
    @employee_listings = @person.employee_listings.paginate(:page => params[:page], :per_page => 2)
    @reviews_by_hirer = show_all_hirer_reviews
    @reviews_by_poster = show_all_poster_reviews
  end

  def index
    @q = Transaction.search(params[:q])
    @hirings_transactions = Transaction.order(updated_at: :desc).paginate(:page => params[:page], :per_page => 50)
    # @hirings = @hirings.where(state: [:created, :accepted, :cancelled]).includes(:employee_listing)
  end

  def hiring_details
    @transaction = Transaction.find(params[:id])
    @listing = EmployeeListing.find(@transaction.poster.id)
    @conversation = @transaction.conversation
    @messages = @conversation.messages.order(created_at: :DESC)
  end

  def search
    @q = Transaction.search(params[:q])
    q = {}
    if params[:keyword_search].present?
      q[:employee_listings_id_or_employee_listings_name_or_employee_listings_poster_name_or_employee_listings_title_eq] = params[:keyword_search]
    end
    if params[:start_date].present?
      q[:start_date_gteq] = params[:start_date].to_date
    end
    if params[:end_date].present?
      q[:start_date_lteq] = params[:end_date].to_date
    end
    @hirings_transactions = Transaction.includes(:employee_listing).ransack(q).result(distinct: true)
    @hirings_transactions = @hirings_transactions.order(updated_at: :desc).paginate(:page => params[:page], :per_page => params[:show_per_page])
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