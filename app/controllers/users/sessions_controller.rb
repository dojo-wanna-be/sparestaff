class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: :destroy

  # POST /resource/sign_in
  def create
    self.resource = User.find_by(email: sign_in_params[:email])
    @success = true
    if resource and resource.valid_password?(sign_in_params[:password])
      sign_in(resource_name, resource)
      yield resource if block_given?
      if request.xhr?
        render 'home/login.js.erb'
      else
        respond_with resource, location: after_sign_in_path_for(resource)
      end
    else
      @success = false
      render 'home/login.js.erb'
    end
  end
end
