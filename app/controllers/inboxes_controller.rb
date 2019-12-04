class InboxesController < ApplicationController
  before_action :find_transaction, only: [:show]

  def index
    @conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id)
  end

  def show
    @listing = @transaction.employee_listing
  end

  private

  def find_transaction
    @transaction = Transaction.find_by(id: params[:id])
  end

  def find_conversation
    @conversation = Conversation.find_by(id: params[:id])
  end
end
