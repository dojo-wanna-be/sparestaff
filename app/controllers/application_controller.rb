class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :account_suspended
  before_action :unread_message_count

  def unread_message_count
    if current_user.present?
    # @unread_count = Message.joins(:conversation).where("read =? AND messages.sender_id !=? AND (conversations.sender_id =? OR conversations.receiver_id =?)", false, current_user.id, current_user.id, current_user.id).size
      @unread_count = Conversation.joins(:messages).where("(conversations.sender_id =? OR conversations.receiver_id =?) AND messages.read =? AND messages.sender_id !=?", current_user.id, current_user.id, false, current_user.id).distinct.count
    end
  end

  def account_suspended
    if current_user.present? && current_user.is_suspended
      flash[:error] = "Sorry, Your account is suspended. Please contact sparestaff support team."
      redirect_to root_path and return
    end
  end
  
  protected

  def after_sign_in_path_for(_resource)
    root_path
  end

  def ensure_is_admin
    unless current_user.is_admin?
      flash[:error] = "Only Adminstration enter in this area!"
      redirect_to root_path and return
    end
  end
end
