class InboxesController < ApplicationController
  before_action :find_conversation, only: [:show]

  def index
    @conversations = Conversation.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id)
  end

  def show
    @transaction = @conversation.employee_listing_transaction
    @listing = @conversation.employee_listing
  end

  def create
    #message = @conversation.messages.new(content: params[:message], sender_id: current_user.id)
  end

  private

  def find_conversation
    @conversation = Conversation.find_by(id: params[:id])
  end
end
