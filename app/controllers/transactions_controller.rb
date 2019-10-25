class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_company_owner
  before_action :find_transaction, only: [:ensure_not_poster, :initialized]
  before_action :ensure_not_poster, only: [:create, :initialized, :payment]
  before_action :find_company, only: [:initialized]

  def create
    transaction = TransactionService.new(params, current_user).create
    if transaction.present?
      redirect_to initialized_transaction_path(id: transaction.id)
    else
      flash[:error] = "Please check your selected dates and slotes and try again"
      redirect_to employee_path(id: params[:transaction][:employee_listing_id])
    end
  end

  def initialized
    unless request.patch?
      @employee_listing = @transaction.employee_listing
      @slot = ""
      all_bookings = @transaction.bookings
      ListingAvailability::DAYS.map{|k,v| v}.each do |day|
        booking = all_bookings.find_by(day: day)
        if booking.present?
          @slot = @slot + Transaction::DAYS_HASH[:"#{day.downcase}"] + " #{booking.start_time.strftime("%H:%M")} - #{booking.end_time.strftime("%H:%M")}, "
        end
      end
    else
      @company.update(company_params)
      binding.pry
      redirect_to payment_transaction_path(id: @transaction.id)
    end
  end

  def payment
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :acn,
      :address_1,
      :address_2,
      :city,
      :state,
      :post_code,
      :country,
      :contact_no,
      :probationary_period
    )
  end

  def find_company
    @company = current_user.company
  end

  def find_transaction
    @transaction = Transaction.find(params[:id])
  end

  def ensure_company_owner
    unless current_user.is_owner? || current_user.is_hr?
      flash[:error] = "You are not authorised to hire an employee"
      redirect_to employee_index_path
    end
  end

  def ensure_not_poster
    if current_user = @transaction.employee_listing.poster
      flash[:error] = "Invalid request"
      redirect_to employee_index_path
    end
  end
end
