class HomeController < ApplicationController
  def index
    @user = User.new
  end

  # def email_availability
  #   binding.pry
  #  @email = User.pluck(:email)
	 #  respond_to do |format|
	 #    format.json { render :json => !@email}
	 #  end 
  # end
end
