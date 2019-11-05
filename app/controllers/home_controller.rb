class HomeController < ApplicationController
  skip_before_action :authenticate_user!

  def index
    @user = User.new
  end

  def email_availability
    email = User.pluck(:email).include?(params[:user][:email])
    if params[:form].eql?("signup")
      respond_to do |format|
        format.json { render :json => !email}
      end
    elsif params[:form].eql?("login")
      respond_to do |format|
        format.json { render :json => email}
      end
    end
  end
end
