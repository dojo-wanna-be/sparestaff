class PayoutsController < ApplicationController

	def step_1; end

	def step_2; end

	def stripe_account
		unless request.get?
			account = StripeAccount.new(params, current_user, request.remote_ip).create
      if account.present?
        stripe_info = current_user.stripe_info.present? ? current_user.stripe_info : current_user.build_stripe_info
        stripe_info.stripe_account_id = account.id
        stripe_info.save
        flash[:notice] = "Account Created Successfully"
        redirect_to root_path
      else
        flash[:error] = "Invalid Request"
        redirect_to stripe_account_payouts_path
      end
		end
	end
end
