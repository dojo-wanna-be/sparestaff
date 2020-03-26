class UsersController < ApplicationController
  def profile_photo
    @current_user = current_user
  end

  def trust_and_verification
  end
end
