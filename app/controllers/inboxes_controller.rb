class InboxesController < ApplicationController
  before_action :authenticate_user!, only: [:show]
  before_action :find_conversation, only: [:show, :create]
  before_action :read_conversation, only: [:show]

  def index
    @conversations = Conversation.where("conversations.sender_id = ? OR conversations.receiver_id = ?", current_user.id, current_user.id).order("updated_at desc")
  end

  def show
    if(params[:from].present?)
      @listing = EmployeeListing.find(params[:id])
      @conversation = Conversation.between_listing(current_user.id, @listing.poster.id, @listing.id).last
      @reviews_all_star = listing_star_rating(@listing.id)
      @reviews_all = listing_all_reviews(@listing.id)
      if false#(@conversation.present?)
        @messages = @conversation.messages.order(created_at: :DESC)
      else
        begin
          @conversation = Conversation.create!(receiver_id: @listing.poster.id,
                    sender_id: current_user.id,
                    employee_listing_id: @listing.id
                  )
          @messages = []
          redirect_to inbox_path(id: @conversation.id)
        rescue => e
          flash[:error] = e.message
          redirect_to employee_path(id: @listing.id)
        end
      end
    else
      @transaction = @conversation.employee_listing_transaction
      @address = @transaction.try(:address)
      @listing = @conversation.employee_listing
      @reviews_all_star = listing_star_rating(@listing.id)
      @reviews_all = listing_all_reviews(@listing.id)
      @messages = @conversation.messages.order(created_at: :DESC)
    end
    @unread_count = Conversation.joins(:messages).where("(conversations.sender_id =? OR conversations.receiver_id =?) AND messages.read =? AND messages.sender_id !=?", current_user.id, current_user.id, false, current_user.id).distinct.count
  end

  def create
    message = @conversation.messages.new(content: params[:message][:content], sender_id: current_user.id)
    @listing = @conversation.employee_listing
    # @sender = @conversation.sender
    # @receiver = @conversation.receiver
    if message.save
      flash[:notice] = "Message sent successfully."
      @sender = User.where(id: current_user.id)
      if current_user.id.eql?(@conversation.sender_id)
        @receiver = User.find(@conversation.receiver_id)
      else
        @receiver = User.find(@conversation.sender_id)
      end
      if current_user.user_type == "hr" && @receiver.user_type == "hr"
        if @listing.poster.eql?(@sender.first)
          MessageMailer.message_email_to_hirer(message,@sender,@receiver,@conversation).deliver_later!
        else
          MessageMailer.message_email_to_poster(message,@sender,@receiver,@conversation).deliver_later!
        end
      elsif @sender.first.user_type == "hr"
          MessageMailer.message_email_to_poster(message,@sender,@receiver,@conversation).deliver_later!
      # elsif @listing.poster.eql?(@sender.first)
      else
        MessageMailer.message_email_to_hirer(message,@sender,@receiver,@conversation).deliver_later!
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
