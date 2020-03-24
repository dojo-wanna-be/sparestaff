class PayoutsController < ApplicationController

	def step_1; end

	def step_2; end

	def index
		@payment_method = current_user.stripe_info
		begin
			@stripe_account = Stripe::Account.retrieve('acct_1FolrxE4u5g7rNqu') if(@payment_method.present?  && @payment_method.stripe_account_id)
		rescue e
			@stripe_account = nil
		end
	end

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

	def change_prefrence
	end
end
