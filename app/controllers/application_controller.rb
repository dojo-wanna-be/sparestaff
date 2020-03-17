class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :conversationcount

  def conversationcount
    if current_user.present?
    	@conversations = Conversation.includes(:messages).order(created_at: :DESC).where("conversations.sender_id = ? OR conversations.receiver_id = ?", current_user.id, current_user.id)
      @conversationsc = @conversations.where(read: false)
      @conversationsc
    end
  end
  
  protected

  def after_sign_in_path_for(_resource)
    root_path
  end

end
