class HiringsController < ApplicationController
  before_action :find_transaction, only: [:change_or_cancel, :cancel_hiring, :tell_poster, :cancelled_successfully]

  def index
    hirer_transactions = Transaction.where(hirer_id: current_user.id)
    @hired_listing_transactions = hirer_transactions.includes(:employee_listing)
  end

  def change_or_cancel
    @listing = @transaction.employee_listing
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
