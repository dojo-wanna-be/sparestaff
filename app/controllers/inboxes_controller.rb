class InboxesController < ApplicationController
  before_action :find_conversation, only: [:show, :create]

  def index
    @conversations = Conversation.includes(:messages).where("conversations.sender_id = ? OR conversations.receiver_id = ?", current_user.id, current_user.id)
  end

  def show
    if(params[:from].present?)
      @listing = EmployeeListing.find(params[:id])
      @conversation = Conversation.between_listing(current_user.id, @listing.poster.id, @listing.id).last
      if(@conversation.present?)
        @messages = @conversation.messages.order(created_at: :DESC)
      else
        @conversation = Conversation.create!( receiver_id: @listing.poster.id,
                    sender_id: current_user.id,
                    employee_listing_id: @listing.id
                  )
        @messages = []
      end
      redirect_to inbox_path(id: @conversation.id) 
    else
      @transaction = @conversation.employee_listing_transaction
      @listing = @conversation.employee_listing
      @messages = @conversation.messages.order(created_at: :DESC)
    end
  end

  def create
    message = @conversation.messages.new(content: params[:message][:content], sender_id: current_user.id)
    if message.save
      @messages = @conversation.messages.order(created_at: :DESC)
    end
  end

  private

  def find_conversation
    @conversation = Conversation.find_by(id: params[:id])
  end
  
end
