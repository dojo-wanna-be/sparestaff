class InboxesController < ApplicationController
  before_action :find_conversation, only: [:show, :create]
  before_action :read_conversation, only: [:show]

  def index
    @conversations = Conversation.where("conversations.sender_id = ? OR conversations.receiver_id = ?", current_user.id, current_user.id).order("updated_at desc")
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
      @address = @transaction.try(:address)
      @listing = @conversation.employee_listing
      @messages = @conversation.messages.order(created_at: :DESC)
    end
    @unread_count = Conversation.joins(:messages).where("(conversations.sender_id =? OR conversations.receiver_id =?) AND messages.read =? AND messages.sender_id !=?", current_user.id, current_user.id, false, current_user.id).distinct.count
  end

  def create
    message = @conversation.messages.new(content: params[:message][:content], sender_id: current_user.id)
    @listing = @conversation.employee_listing
    @sender = @conversation.sender
    @receiver = @conversation.receiver
    if message.save
      if current_user.user_type == "hr"
        MessageMailer.message_email_to_poster(message, @listing.poster, @sender, @receiver).deliver_now!
      else
        MessageMailer.message_email_to_hirer(message, @sender, @receiver).deliver_now!
      end
      @messages = @conversation.messages.order(created_at: :DESC)
    end
  end

  def unread
    @conversations = Conversation.includes(:messages).order(created_at: :DESC).where("conversations.sender_id = ? OR conversations.receiver_id = ?", current_user.id, current_user.id)
    if params[:message] == "unread"
      @conversations = Conversation.joins(:messages).where("(conversations.sender_id =? OR conversations.receiver_id =?) AND messages.read =? AND messages.sender_id !=?", current_user.id, current_user.id, false, current_user.id).distinct
    else
      @conversations
    end
  end

  private

  def find_conversation
    @conversation = Conversation.find_by(id: params[:id])
  end

  def read_conversation
    @conversation.unread_message(@current_user).update_all(read: true) if @conversation.present?
  end
end
