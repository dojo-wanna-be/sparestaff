class Admin::UsersController < Admin::AdminBaseController
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
    per_page = params[:selected_data].present? params[:selected_data].to_i || 50
    @users = User.exclude(current_user).order(id: :desc)
    @users = @users.suspended if suspended_user_search_field || params[:suspended_user].present?
    @users = @users.paginate(page: params[:page], per_page: per_page)
  end

  def emails
  end

  def suspend_or_delete
    users = User.where(id: params[:ids])
    if params[:select_action].eql?("delete_selected")
      users.update(deleted_at: Date.today)
    else
      users.update(is_suspended: true)
    end
  end

  def suspend_or_make_admin_user
    @person = User.find_by(id: params[:id])
    if params[:check_type].eql?("suspend_user")
      @user_type = "suspend_user"
      @person.update_column(:is_suspended, params[:checked])
    elsif params[:check_type].eql?("make_admin")
      @user_type = "make_admin"
      @person.update_column(:is_admin, params[:checked])
    else
      @person.update_column(:deleted_at, params[:checked].eql?("true") ? Date.today : nil)
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    params[:user].delete(:password) if params[:user][:password].blank?
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Updated successfully!"
      redirect_to '/admin'
    else
      flash[:error] = @user.errors.full_messages
      render 'edit'
    end
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


  def upload_csv
     @users = User.all
    respond_to do |format|
      format.html
      format.csv { send_data @users.to_csv, filename: "user_record-#{Date.today}.csv" }
    end
  end

  private
  
  def users
    users = User.exclude(current_user).ransack(first_name_or_last_name_or_email_cont_any: params[:q], id_in: params[:q],company_name_cont_any: params[:q], m: 'or').result(distinct: true)
    @users = users.ransack(created_at_gteq: params[:created_at_gteq], created_at_lteq: params[:created_at_lteq]).result(distinct: true)  
  end
  
  def suspended_user
    User.suspended.order(id: :desc).paginate(:page => params[:page], :per_page => 50)
  end

  def search_fields
    result = (params[:q].present? || params[:created_at_gteq].present? || params[:created_at_lteq].present?)
  end

  def suspended_user_search_field
    result = (params[:data_show] == "Suspend selected accounts")
  end

  def user_params
    params.require(:user).permit(
      :first_name,
      :last_name,
      :location,
      :email,
      :password,
      :phone_number,
      :description,
      :avatar
    )
  end
end