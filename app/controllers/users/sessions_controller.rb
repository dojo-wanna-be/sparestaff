class Users::SessionsController < Devise::SessionsController
  skip_before_action :verify_authenticity_token, only: :destroy

  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    set_flash_message!(:notice, :signed_in)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_to do |format|
      format.js
      format.html { respond_with resource, location: after_sign_in_path_for(resource) }
    end
  end
end
