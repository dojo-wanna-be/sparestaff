class PayoutsController < ApplicationController

	def step_1; end

	def step_2; end

	def stripe_account
		unless request.get?
			account = StripeAccount.new(params, current_user, request.remote_ip).create
      if account[:sucess]
        flash[:notice] = account[:message]
        redirect_to root_path
      else
        flash[:error] = account[:message]
        redirect_to stripe_account_payouts_path
      end
		end
	end
end
