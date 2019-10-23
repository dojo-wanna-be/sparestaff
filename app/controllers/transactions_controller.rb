class TransactionsController < ApplicationController
  def create
    transaction = Transaction.new(transaction_params)
    # if transaction.save
    # else
    # end
  end

  private

  def transaction_params
    params.require(:transaction).permit(
      :employee_listing_id,
      :frequency,
      :start_date,
      :end_date
    )
  end
end
