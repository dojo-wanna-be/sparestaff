class InboxesController < ApplicationController
  before_action :find_conversation, only: [:show]

  def index
    @conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id)
  end

  def show
    @transaction = Transaction.find_by(id: params[:id])
    @listing = @transaction.employee_listing
  end

  def create
    #message = @conversation.messages.new(content: params[:message], sender_id: current_user.id)
  end

  private

  def find_conversation
    @conversation = Conversation.find_by(id: params[:id])
  end
end
