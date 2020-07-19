class Users::SessionsController < Devise::SessionsController
  # POST /resource/sign_in
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    yield resource if block_given?
    respond_to do |format|
      format.js
      format.html { respond_with resource, location: after_sign_in_path_for(resource) }
    end
  end
end
