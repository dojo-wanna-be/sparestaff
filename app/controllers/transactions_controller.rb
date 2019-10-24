class TransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_company_owner

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
    @company = current_user.company
  end

  def payment
  end

  private

  def ensure_company_owner
    unless current_user.is_owner? || current_user.is_hr?
      flash[:error] = "You are not authorised to hire an employee"
      redirect_to employee_index_path
    end
  end
end
