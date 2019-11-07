class HiringsController < ApplicationController
  include EmployeeListingsHelper

  before_action :find_transaction, only: [:change_or_cancel,
                                          :change_hiring,
                                          :change_hiring_confirmation,
                                          :changed_successfully,
                                          :cancel_hiring,
                                          :tell_poster,
                                          :cancelled_successfully,
                                          :show
                                         ]

  def index
    hirer_transactions = Transaction.where(hirer_id: current_user.id).order(updated_at: :desc)
    @hired_listing_transactions = hirer_transactions.includes(:employee_listing)
  end

  def show
    @listing = @transaction.employee_listing
  end

  def change_or_cancel
    @listing = @transaction.employee_listing
  end

  def change_hiring
    @old_transaction = @transaction
    @listing = @transaction.employee_listing
    unless request.patch?
      start_date = @transaction.start_date
      end_date = @transaction.end_date

      transactions = @listing
                    .transactions
                    .where(state: "accepted")
                    .where("start_date BETWEEN ? AND ? OR end_date BETWEEN ? AND ?", start_date, end_date, start_date, end_date)

      transaction_ids = transactions.pluck(:id)
      bookings = Booking.where(transaction_id: transaction_ids).group_by(&:day)
      @disabled_time = unavailable_time_slots(bookings)
    else
      @new_transaction = TransactionService.new(params, current_user).create
      if @new_transaction.present?
        redirect_to change_hiring_confirmation_hiring_path(id: @new_transaction.id)
      else
        flash[:error] = "Some error occurred"
        redirect_to change_hiring_hiring_path(id: @old_transaction.id)
      end
    end
  end

  def change_hiring_confirmation
    @listing = @transaction.employee_listing
    unless request.patch?
    else
    end
  end

  def changed_successfully
    @listing = @transaction.employee_listing
    unless request.patch?
    else
    end
  end

  def cancel_hiring
    unless request.patch?
      @listing = @transaction.employee_listing
    else
      @transaction.update_attributes(reason: params[:reason], state: "cancelled")
      redirect_to tell_poster_hiring_path(id: @transaction.id)
    end
  end

  def tell_poster
    @listing = @transaction.employee_listing
    if request.patch?
      conversation = Conversation.between(current_user.id, @listing.poster.id, @listing.id)
      if conversation.present?
        @conversation = conversation.first
      else
        @conversation = Conversation.create!( receiver_id: @listing.poster.id,
                                              sender_id: current_user.id,
                                              listing_id: @listing.id
                                            )
      end
      message = @conversation.messages.build
      message.content = params[:message_text]
      message.sender_id = current_user.id
      message.save
      TransactionMailer.listing_cancelled_successfully(@listing, current_user).deliver!
      redirect_to cancelled_successfully_hirings_path(id: @transaction.id)
    end
  end

  def cancelled_successfully
    @listing = @transaction.employee_listing
    conversation = Conversation.between(current_user.id, @listing.poster.id, @listing.id)
    if conversation.present?
      @conversation = conversation.first
    end
  end

  def send_details
    transaction = Transaction.find_by(id: params[:transaction_id])
    TransactionMailer.send_hiring_details(transaction, params[:email]).deliver!
    flash[:notice] = "Shared successfully"
    redirect_to hirings_path
  end

  private

  def find_transaction
    @transaction = Transaction.find_by(id: params[:id])
  end
end
