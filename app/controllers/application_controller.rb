class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token

  before_action :authenticate_user!
  before_action :account_suspended
  before_action :unread_message_count
  before_action :footer_links
  before_action :init_gon
  include ApplicationHelper

  def unread_message_count
    if current_user.present?
    # @unread_count = Message.joins(:conversation).where("read =? AND messages.sender_id !=? AND (conversations.sender_id =? OR conversations.receiver_id =?)", false, current_user.id, current_user.id, current_user.id).size
      @unread_count = Conversation.joins(:messages).where("(conversations.sender_id =? OR conversations.receiver_id =?) AND messages.read =? AND messages.sender_id !=?", current_user.id, current_user.id, false, current_user.id).distinct.count
    end
  end

  def footer_links
    @sparestaff_section_links = FooterLink.where(link_type: "sparestaff_section")
    @easy_online_recruitment_section_links = FooterLink.where(link_type: "easy_online_recruitment_section")
    @employee_sharing_hiring_section_links = FooterLink.where(link_type: "employee_sharing_hiring_section")
  end

  def account_suspended
    if current_user&.is_suspended
      flash[:error] = "Sorry, Your account is suspended. Please contact sparestaff support team."
      redirect_to root_path and return
    end
  end

  # def current_user
  #   # NOTE: so that everywehre within the same request can access the current_user
  #   RequestLocals[:current_user] ||= super
  #   super
  # end
  
  protected

  def after_sign_in_path_for(_resource)
    root_path
  end

  def authenticate_user!
    return true if user_signed_in?

    respond_to do |format|
      format.js { render nothing: true, status: :unauthorized } 
      format.html { redirect_to root_path, :alert => 'Need to login.' }
    end
  end

  def ensure_is_admin
    unless current_user.is_admin? || current_user.is_superadmin?
      flash[:error] = "Only Adminstration enter in this area!"
      redirect_to root_path and return
    end
  end

  def init_gon
    gon.push env: Rails.env, env_vars: {}
    gon.push user: current_user if user_signed_in?
  end
end
