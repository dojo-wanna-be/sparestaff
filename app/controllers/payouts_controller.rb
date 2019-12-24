class PayoutsController < ApplicationController

	def step_1; end

	def step_2; end

	def stripe_account; end

	def create
		@account = StripeAccount.new(params, current_user, request.remote_ip).create
    if @account[:success]
      flash[:notice] = @account[:message]
      redirect_to root_path
    else
      @error = @account[:message]
      render action: "stripe_account"
    end
	end
end
